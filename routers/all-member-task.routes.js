const express = require('express');
const router = express.Router();
const con = require('../config/db');

router.get('/all-member-task', async (req, res) => {
    if (!req.session.role) {
        return res.redirect('/');
    }

    try {
        let users = [];
        let members = [];
        let adminName = null;
        let tasks = [];
        let controlType = null;
        let teamId = null;

        const selectedUser = req.query.user_id || 'all';
        const adminId = req.session.adminId;
        const sessionRole = req.session.role;
        const sessionUserId = req.session.userId;

        // ================= ADMIN NAME =================
        const [adminRows] = await con.query(
            "SELECT name FROM admins WHERE id=?", 
            [adminId]
        );
        if (adminRows.length > 0) adminName = adminRows[0].name;

        // ================= ROLE & TEAM FETCH =================
        if (sessionRole === "admin") {
            controlType = "OWNER"; // Treat admin and owner identically as top tier
        } else {
            const [uData] = await con.query(
                "SELECT role_id FROM users WHERE id=?", 
                [sessionUserId]
            );
            const roleId = uData[0].role_id;

            const [rData] = await con.query(
                "SELECT control_type, team_id FROM roles WHERE id=?",
                [roleId]
            );

            controlType = rData.length > 0 ? rData[0].control_type : "NONE";
            teamId = rData.length > 0 ? rData[0].team_id : null;
        }

        // ================= NAVBAR MEMBERS =================
        if (controlType === "OWNER") {
            if (sessionRole !== "admin") {
                members.push({ id: 0, name: adminName + ' (Admin)' });
            }
            const [mRows] = await con.query(`
                SELECT u.id, 
                CASE WHEN r.control_type = 'OWNER' THEN CONCAT(u.name, ' (Admin)') ELSE u.name END AS name 
                FROM users u 
                LEFT JOIN roles r ON u.role_id = r.id 
                WHERE u.admin_id=? AND u.status='ACTIVE' AND u.id != ?
            `, [adminId, sessionRole === 'admin' ? -1 : sessionUserId]);
            members = members.concat(mRows);
        } else {
            const [mRows] = await con.query(
                "SELECT id, name FROM users WHERE admin_id=? AND status='ACTIVE' AND id != ?",
                [adminId, sessionUserId]
            );
            members = mRows;
        }

        // ================= USERS DROPDOWN (4-LAYER HIERARCHY) =================
        if (controlType === "OWNER") {
            // LAYER 1: Admin/Owner sees EVERYONE
            if (sessionRole !== "admin") {
                users.push({ id: 0, name: adminName + ' (Admin)' });
            }
            const [userRows] = await con.query(`
                SELECT u.id, 
                CASE WHEN r.control_type = 'OWNER' THEN CONCAT(u.name, ' (Admin)') ELSE u.name END AS name 
                FROM users u 
                LEFT JOIN roles r ON u.role_id = r.id 
                WHERE u.admin_id=? AND u.status='ACTIVE' AND u.id != ?
            `, [adminId, sessionRole === 'admin' ? -1 : sessionUserId]);
            users = users.concat(userRows);

        } else if (controlType === "ADMIN") {
            // LAYER 2: Admin Control sees Admin, Partial, None inside SAME TEAM
            const [userRows] = await con.query(`
                SELECT u.id, u.name 
                FROM users u
                JOIN roles r ON u.role_id = r.id
                WHERE u.admin_id = ?
                AND r.control_type IN ('ADMIN', 'PARTIAL', 'NONE')
                AND (r.team_id = ? OR (? IS NULL AND r.team_id IS NULL))
                AND u.status='ACTIVE'
                AND u.id != ?
            `, [adminId, teamId, teamId, sessionUserId]);
            users = userRows;

        } else if (controlType === "PARTIAL") {
            // LAYER 3: Partial Control sees Partial, None inside SAME TEAM
            const [userRows] = await con.query(`
                SELECT u.id, u.name 
                FROM users u
                JOIN roles r ON u.role_id = r.id
                WHERE u.admin_id = ?
                AND r.control_type IN ('PARTIAL', 'NONE')
                AND (r.team_id = ? OR (? IS NULL AND r.team_id IS NULL))
                AND u.status='ACTIVE'
                AND u.id != ?
            `, [adminId, teamId, teamId, sessionUserId]);
            users = userRows;

        } else if (controlType === "NONE") {
            // LAYER 4: None Control sees only None inside SAME TEAM
            const [userRows] = await con.query(`
                SELECT u.id, u.name 
                FROM users u
                JOIN roles r ON u.role_id = r.id
                WHERE u.admin_id = ?
                AND r.control_type = 'NONE'
                AND (r.team_id = ? OR (? IS NULL AND r.team_id IS NULL))
                AND u.status='ACTIVE'
                AND u.id != ?
            `, [adminId, teamId, teamId, sessionUserId]);
            users = userRows;
        }

        // ================= TASK FETCH =================
        if (controlType !== "NONE" || controlType === "NONE") { 

            let taskQuery = `
                SELECT t.*, 
                CASE 
                    WHEN t.status = 'COMPLETED' THEN 'COMPLETED'
                    WHEN t.assigned_to = 0 AND (t.who_assigned = 'user' OR t.who_assigned = 'owner') THEN 'OTHERS'
                    WHEN t.assigned_to = 0 AND t.who_assigned = 'admin' THEN t.section
                    WHEN t.assigned_to != t.assigned_by THEN 'OTHERS'
                    ELSE t.section
                END AS section,
                CASE 
                    WHEN t.assigned_to = 0 THEN CONCAT(COALESCE(a.name, 'Admin'), ' (Admin)')
                    WHEN r1.control_type = 'OWNER' THEN CONCAT(u1.name, ' (Admin)')
                    ELSE COALESCE(u1.name, 'Unknown')
                END AS assigned_to_name,
                CASE 
                    WHEN t.who_assigned = 'admin' THEN CONCAT(COALESCE(a.name, 'Admin'), ' (Admin)')
                    WHEN t.who_assigned = 'owner' OR r2.control_type = 'OWNER' THEN CONCAT(u2.name, ' (Admin)')
                    ELSE COALESCE(u2.name, 'Unknown')
                END AS assigned_by_name
                FROM tasks t
                LEFT JOIN users u1 ON t.assigned_to = u1.id
                LEFT JOIN roles r1 ON u1.role_id = r1.id
                LEFT JOIN users u2 ON t.assigned_by = u2.id
                LEFT JOIN roles r2 ON u2.role_id = r2.id
                LEFT JOIN admins a ON t.admin_id = a.id
                WHERE t.admin_id = ?
            `;

            let params = [adminId];

            // ================= FILTER =================
            if (controlType === "OWNER") {

                if (selectedUser !== 'all') {
                    taskQuery += " AND t.assigned_to = ?";
                    params.push(selectedUser);
                } else {
                    // Exclude own tasks from the "all" view
                    if (sessionRole === "admin") {
                        taskQuery += " AND t.assigned_to != 0";
                    } else {
                        taskQuery += " AND t.assigned_to != ?";
                        params.push(sessionUserId);
                    }
                }

            } else { // Layer 2, 3, 4

                const allowedIds = users.map(u => u.id);

                if (allowedIds.length === 0) {
                    taskQuery += " AND 1=0"; // Render nothing safely
                } else {

                    if (selectedUser !== 'all') {

                        if (allowedIds.includes(parseInt(selectedUser))) {
                            taskQuery += " AND t.assigned_to = ?";
                            params.push(selectedUser);
                        } else {
                            taskQuery += " AND 1=0";
                        }

                    } else {
                        taskQuery += " AND t.assigned_to IN (?)";
                        params.push(allowedIds);
                        
                        // Exclude own tasks from the "all" view
                        taskQuery += " AND t.assigned_to != ?";
                        params.push(sessionUserId);
                    }
                }
            }

            taskQuery += " ORDER BY t.due_date ASC";

            const [taskRows] = await con.query(taskQuery, params);
            tasks = taskRows;
        }

        const renderData = {
            session: req.session,
            users,
            members,
            adminName,
            tasks,
            selected_user: selectedUser,
            activePage: "allmembers"
        };

        if (req.xhr || req.headers['x-requested-with'] === 'XMLHttpRequest') {
            res.render('all-member-task', { ...renderData, layout: false });
        } else {
            res.render('all-member-task', renderData);
        }

    } catch (err) {
        console.error(err);
        res.send("Database Error");
    }
});

module.exports = router;