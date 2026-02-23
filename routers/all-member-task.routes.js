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

        // ===============================
        // 1️⃣ ADMIN LOGIN
        // ===============================
        if (req.session.role === 'admin') {

            const adminId = req.session.adminId;

            // Get Admin Name
            const [adminRows] = await con.query(
                "SELECT name FROM admins WHERE id=?",
                [adminId]
            );

            if (adminRows.length > 0) {
                adminName = adminRows[0].name;
            }

            // Users table (if needed)
            const [adminUsers] = await con.query(
                "SELECT id, name FROM users WHERE admin_id=?",
                [adminId]
            );
            users = adminUsers;

            // Members dropdown (navbar use)
            const [memberRows] = await con.query(
                "SELECT id, name FROM users WHERE admin_id=? AND status='ACTIVE'",
                [adminId]
            );
            members = memberRows;

            // Roles (if navbar needs)
            const [roleRows] = await con.query(
                "SELECT id, role_name FROM roles WHERE admin_id=?",
                [adminId]
            );
            roles = roleRows;

            // Tasks
            let taskQuery = `
                SELECT *
                FROM tasks
                WHERE admin_id = ?
            `;

            let params = [adminId];

            if (selectedUser !== 'all') {
                taskQuery += " AND assigned_to = ?";
                params.push(selectedUser);
            }

            const [taskRows] = await con.query(taskQuery, params);
            tasks = taskRows;
        }

        // ===============================
        // 2️⃣ USER LOGIN
        // ===============================
        else if (req.session.role === 'user') {

            const adminId = req.session.adminId;

            // Get Admin Name
            const [adminRows] = await con.query(
                "SELECT name FROM admins WHERE id=?",
                [adminId]
            );

            if (adminRows.length > 0) {
                adminName = adminRows[0].name;
            }

            // Members dropdown (exclude himself)
            const [memberRows] = await con.query(
                "SELECT id, name FROM users WHERE admin_id=? AND status='ACTIVE' AND id!=?",
                [adminId, req.session.userId]
            );
            members = memberRows;

            // Roles
            const [roleRows] = await con.query(
                "SELECT id, role_name FROM roles WHERE admin_id=?",
                [adminId]
            );
            roles = roleRows;

            // Users list
            const [companyUsers] = await con.query(
                "SELECT id, name FROM users WHERE admin_id=?",
                [adminId]
            );
            users = companyUsers;

            // Tasks (only assigned to him)
            let taskQuery = `
                SELECT *
                FROM tasks
                WHERE admin_id = ?
                AND assigned_to = ?
            `;

            let params = [adminId, req.session.userId];

            if (selectedUser !== 'all') {
                taskQuery += " AND assigned_to = ?";
                params.push(selectedUser);
            }

            const [taskRows] = await con.query(taskQuery, params);
            tasks = taskRows;
        }

        // ===============================
        // 3️⃣ RENDER
        // ===============================
        res.render('all-member-task', {
            session: req.session,
            users,
            members,     // ✅ IMPORTANT
            roles,       // ✅ IMPORTANT
            adminName,   // ✅ IMPORTANT
            tasks,
            selected_user: selectedUser
        });

    } catch (err) {
        console.error(err);
        res.send("Database Error");
    }

});

module.exports = router;