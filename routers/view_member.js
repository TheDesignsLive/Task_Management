const express = require('express');
const router = express.Router();
const con = require('../config/db');

router.get('/', async (req, res) => {
    if (!req.session.role) return res.redirect('/');
    
    try {
        let users = [];
        let members = [];
        let roles = [];
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

            const [adminUsers] = await con.query(
                `SELECT users.*, roles.role_name 
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
                "SELECT id, role_name FROM roles WHERE admin_id=?",
                [adminId]
            );
            roles = roleRows;
        }

        // 2️⃣ USER LOGIN
        else if (req.session.role === 'user') {
            const adminId = req.session.adminId;
            const [roleRows] = await con.query(
                "SELECT id, role_name FROM roles WHERE admin_id=?",
                [adminId]
            );
            roles = roleRows;
            
            const [userRows] = await con.query(
                "SELECT admin_id FROM users WHERE id=?",
                [req.session.userId]
            );

            if (userRows.length > 0) {
                const adminId = userRows[0].admin_id;

                const [adminRows] = await con.query(
                    "SELECT name FROM admins WHERE id=?",
                    [adminId]
                );

                if (adminRows.length > 0) {
                    adminName = adminRows[0].name;
                }

                const [companyUsers] = await con.query(
                     `SELECT users.*, roles.role_name 
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
        }

        // 3️⃣ Render
        res.render('view_member', {
            users,
            members,
            roles,
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