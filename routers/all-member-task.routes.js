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
        let roles = [];
        let adminName = null;
        let tasks = [];

        const selectedUser = req.query.user_id || 'all';
        const adminId = req.session.adminId;
        const sessionRole = req.session.role;
        const sessionUserId = req.session.userId;

        // ================= GET ADMIN NAME =================

        const [adminRows] = await con.query(
            "SELECT name FROM admins WHERE id=?",
            [adminId]
        );

        if (adminRows.length > 0) {
            adminName = adminRows[0].name;
        }

        // ================= ROLE BASED USER LIST =================

        if (sessionRole === "admin") {

            const [userRows] = await con.query(
                "SELECT id, name FROM users WHERE admin_id=? AND status='ACTIVE'",
                [adminId]
            );

            users = userRows;
            members = userRows;

        } else if (sessionRole === "user") {

            const [currentUser] = await con.query(
                "SELECT role_id FROM users WHERE id=?",
                [sessionUserId]
            );

            const roleId = currentUser[0].role_id;

            const [roleData] = await con.query(
                "SELECT control_type FROM roles WHERE id=?",
                [roleId]
            );

            const controlType = roleData[0].control_type;

            if (controlType === "ADMIN") {

                const [userRows] = await con.query(
                    "SELECT id, name FROM users WHERE admin_id=? AND status='ACTIVE'",
                    [adminId]
                );

                users = userRows;
                members = userRows;

            } else if (controlType === "PARTIAL") {

                const [userRows] = await con.query(`
                    SELECT u.id, u.name
                    FROM users u
                    JOIN roles r ON u.role_id = r.id
                    WHERE u.admin_id = ?
                    AND r.control_type IN ('PARTIAL','NONE')
                    AND u.status='ACTIVE'
                `, [adminId]);

                users = userRows;
                members = userRows;

            } else {
                users = [];
                members = [];
            }
        }

        // ============================================================
        // ================= SINGLE TASK QUERY (NO DUPLICATE) =========
        // ============================================================

        let taskQuery = `
            SELECT 
                t.*,
                CASE
                    WHEN t.status = 'COMPLETED' THEN 'COMPLETED'
                    WHEN t.assigned_to != t.assigned_by THEN 'OTHERS'
                    ELSE t.section
                END AS section,
                u1.name AS assigned_to_name,
                CASE 
                    WHEN t.who_assigned = 'admin' THEN a.name
                    ELSE u2.name
                END AS assigned_by_name
            FROM tasks t
            JOIN users u1 ON t.assigned_to = u1.id
            LEFT JOIN users u2 ON t.assigned_by = u2.id
            LEFT JOIN admins a ON t.assigned_by = a.id
            WHERE t.admin_id = ?
        `;

        let params = [adminId];

        // Dropdown filter
        if (selectedUser !== 'all') {
            taskQuery += " AND t.assigned_to = ?";
            params.push(selectedUser);
        }

        taskQuery += " ORDER BY t.due_date ASC";

        const [taskRows] = await con.query(taskQuery, params);

        tasks = taskRows;

        // ================= RENDER =================

        res.render('all-member-task', {
            session: req.session,
            users,
            members,
            roles,
            adminName,
            tasks,
            selected_user: selectedUser
        });

    } catch (err) {
        console.error(err);
        res.send("Database Error");
    }
});

module.exports = router;