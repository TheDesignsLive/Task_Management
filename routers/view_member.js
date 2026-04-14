const express = require('express');
const router = express.Router();
const con = require('../config/db');

router.get('/', async (req, res) => {
    if (!req.session.role) return res.redirect('/');
    
    try {
        let users = [];
        let members = [];
        let roles = [];
        let teams = []; // ✅ Added to hold teams for the dropdown
        let adminName = null;   

        // 1️⃣ ADMIN LOGIN
        if (req.session.role === 'admin') {
            const adminId = req.session.adminId;

            const [adminRows] = await con.query(
                "SELECT name FROM admins WHERE id=?",
                [adminId]
            );

            if (adminRows.length > 0) {
                adminName = adminRows[0].name;
            }

            const [teamRows] = await con.query("SELECT id, name FROM teams WHERE admin_id=? ORDER BY name ASC", [adminId]);
            teams = teamRows;

            const [adminUsers] = await con.query(
                `SELECT users.*, roles.role_name, roles.team_id 
                 FROM users 
                 JOIN roles ON users.role_id = roles.id
                 WHERE users.admin_id=?`,
                [adminId]
            );
            users = adminUsers;

            const [rows] = await con.query(
                "SELECT id, name FROM users WHERE admin_id=? AND status='ACTIVE'",
                [adminId]
            );
            members = rows;

            const [roleRows] = await con.query(
                "SELECT id, role_name, team_id FROM roles WHERE admin_id=?",
                [adminId]
            );
            roles = roleRows;
        }

        // 2️⃣ USER LOGIN
        else if (req.session.role === 'user' || req.session.role === 'owner') {
            
            const [userRows] = await con.query(
                "SELECT u.admin_id, r.control_type, r.team_id FROM users u JOIN roles r ON u.role_id = r.id WHERE u.id=?",
                [req.session.userId]
            );

            if (userRows.length > 0) {
                const adminId = userRows[0].admin_id;
                const controlType = userRows[0].control_type;
                const teamId = userRows[0].team_id;

                const [adminRows] = await con.query(
                    "SELECT name FROM admins WHERE id=?",
                    [adminId]
                );

                if (adminRows.length > 0) {
                    adminName = adminRows[0].name;
                }

                // If user has 'ADMIN' control, they see everything (just like a real admin)
                if (controlType === 'ADMIN' || controlType === 'OWNER') {
                    const [teamRows] = await con.query("SELECT id, name FROM teams WHERE admin_id=? ORDER BY name ASC", [adminId]);
                    teams = teamRows;

                    const [roleRows] = await con.query(
                        "SELECT id, role_name, team_id FROM roles WHERE admin_id=?",
                        [adminId]
                    );
                    roles = roleRows;

                    const [companyUsers] = await con.query(
                         `SELECT users.*, roles.role_name, roles.team_id 
                          FROM users 
                          JOIN roles ON users.role_id = roles.id
                          WHERE users.admin_id=?`,
                        [adminId]
                    );
                    users = companyUsers;

                    const [rows] = await con.query(
                        "SELECT id, name FROM users WHERE admin_id=? AND status='ACTIVE' AND id!=?",
                        [adminId, req.session.userId]
                    );
                    members = rows;
                } 
                // If user is 'PARTIAL' or 'NONE', restrict them to their specific Team
                else {
                    if (teamId) {
                        const [teamRows] = await con.query("SELECT id, name FROM teams WHERE id=?", [teamId]);
                        teams = teamRows;

                        // User HAS a team -> Show only roles and members in that team
                        const [roleRows] = await con.query(
                            "SELECT id, role_name, team_id FROM roles WHERE admin_id=? AND team_id=?",
                            [adminId, teamId]
                        );
                        roles = roleRows;

                        const [companyUsers] = await con.query(
                             `SELECT users.*, roles.role_name, roles.team_id 
                              FROM users 
                              JOIN roles ON users.role_id = roles.id
                              WHERE users.admin_id=? AND roles.team_id=?`,
                            [adminId, teamId]
                        );
                        users = companyUsers;

                        const [rows] = await con.query(
                            `SELECT u.id, u.name 
                             FROM users u 
                             JOIN roles r ON u.role_id = r.id 
                             WHERE u.admin_id=? AND u.status='ACTIVE' AND u.id!=? AND r.team_id=?`,
                            [adminId, req.session.userId, teamId]
                        );
                        members = rows;
                    } else {
                        // User has NO team -> Show only themselves
                        teams = [];
                        roles = []; // No roles to assign to others
                        
                        const [companyUsers] = await con.query(
                             `SELECT users.*, roles.role_name, roles.team_id 
                              FROM users 
                              JOIN roles ON users.role_id = roles.id
                              WHERE users.id=?`,
                            [req.session.userId]
                        );
                        users = companyUsers;

                        members = []; // Nobody else to see
                    }
                }
            }
        }

        // 3️⃣ Render
        res.render('view_member', {
            users,
            members,
            roles,
            teams, // ✅ Passed teams to the EJS template
            adminName,
            session: req.session,
            activePage:"view_member"
        });

    } catch (err) {
        console.error(err);
        res.status(500).send("Error fetching members");
    }
});

module.exports = router;