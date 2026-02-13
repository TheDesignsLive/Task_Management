const express = require('express');
const router = express.Router();
const con = require('../config/db');

router.get('/view_member', async (req, res) => {
    try {

        let users = [];
        let members = [];
        let roles = [];

        // ===============================
        // 1️⃣ ADMIN LOGIN
        // ===============================
        if (req.session.role === 'admin') {

            const adminId = req.session.adminId;

            // Show only this admin's users
            const [adminUsers] = await con.query(
                "SELECT * FROM users WHERE admin_id=?",
                [adminId]
            );
            users = adminUsers;

            // Dropdown members (optional)
            const [rows] = await con.query(
                "SELECT id, name FROM users WHERE admin_id=? AND status='ACTIVE'",
                [adminId]
            );
            members = rows;

            // Roles dropdown
            const [roleRows] = await con.query(
                "SELECT id, role_name FROM roles WHERE admin_id=?",
                [adminId]
            );
            roles = roleRows;
        }

        // ===============================
        // 2️⃣ USER LOGIN
        // ===============================
        else if (req.session.role === 'user') {

            // Get admin_id of logged-in user
            const [userRows] = await con.query(
                "SELECT admin_id FROM users WHERE id=?",
                [req.session.userId]
            );

            if (userRows.length > 0) {

                const adminId = userRows[0].admin_id;

                // Show company users in table
                const [companyUsers] = await con.query(
                    "SELECT * FROM users WHERE admin_id=?",
                    [adminId]
                );
                users = companyUsers;

                // Dropdown → show other members except himself
                const [rows] = await con.query(
                    "SELECT id, name FROM users WHERE admin_id=? AND status='ACTIVE' AND id!=?",
                    [adminId, req.session.userId]
                );
                members = rows;
            }
        }

        // ===============================
        // 3️⃣ Render
        // ===============================
        res.render('view_member', {
            users,
            members,
            roles,
            session: req.session
        });

    } catch (err) {
        console.error(err);
        res.send("Error fetching members");
    }
});

module.exports = router;
