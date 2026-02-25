const express = require('express');
const router = express.Router();
const con = require('../config/db');

router.get('/', async (req, res) => {

    if (!req.session.role) {
        return res.redirect('/');
    }

    let members = [];
    let roles = [];
    let adminId = null;
    let adminName = null; // ✅ Added to prevent EJS error

    try {
        // ================= ADMIN =================
        if (req.session.role === "admin") {
            adminId = req.session.adminId;

            // Get admin name
            const [aRows] = await con.query("SELECT name FROM admins WHERE id=?", [adminId]);
            if (aRows.length > 0) adminName = aRows[0].name;

            // get members
            const [mRows] = await con.query(
                "SELECT id, name FROM users WHERE admin_id=? AND status='ACTIVE'",
                [adminId]
            );
            members = mRows;

            // get roles
            const [rRows] = await con.query(
                "SELECT * FROM roles WHERE admin_id=? ORDER BY id ASC",
                [adminId]
            );
            roles = rRows;
        }

        // ================= USER =================
        else if (req.session.role === "user") {
            const [userRows] = await con.query(
                "SELECT role_id, admin_id FROM users WHERE id=?",
                [req.session.userId]
            );

            if (userRows.length > 0) {
                adminId = userRows[0].admin_id;

                // ✅ Get Admin name for the user's navbar
                const [aRows] = await con.query("SELECT name FROM admins WHERE id=?", [adminId]);
                if (aRows.length > 0) adminName = aRows[0].name;

                // members
                const [mRows] = await con.query(
                    "SELECT id, name FROM users WHERE admin_id=? AND status='ACTIVE' AND id!=?",
                    [adminId, req.session.userId]
                );
                members = mRows;

                // roles
                const [rRows] = await con.query(
                    "SELECT * FROM roles WHERE admin_id=? ORDER BY id DESC",
                    [adminId]
                );
                roles = rRows;
            }
        }

        res.render('view_role', {
            roles,
            members,
            adminName, // ✅ Now passed to EJS
            session: req.session
        });

    } catch (err) {
        console.error(err);
        res.send("Error loading roles");
    }
});

module.exports = router;