const express = require('express');
const router = express.Router();
const con = require('../config/db');

router.get('/', async (req, res) => {

    if (!req.session.role) {
        return res.redirect('/');
    }

    let show_sidebar = "Usersidebar";
    let members = [];
    let adminName = null;
    let adminId = null;

    try {

        // ================= ADMIN =================
        if (req.session.role === "admin") {

            show_sidebar = "sidebar";
            adminId = req.session.adminId;

            const [mRows] = await con.query(
                "SELECT id, name FROM users WHERE admin_id=? AND status='ACTIVE'",
                [adminId]
            );
            members = mRows;

            const [aRows] = await con.query(
                "SELECT name FROM admins WHERE id=?",
                [adminId]
            );
            if (aRows.length > 0) adminName = aRows[0].name;
        }

        // ================= USER =================
        else if (req.session.role === "user") {

            const [uRows] = await con.query(
                "SELECT role_id, admin_id FROM users WHERE id=?",
                [req.session.userId]
            );

            if (uRows.length > 0) {

                adminId = uRows[0].admin_id;
                const roleId = uRows[0].role_id;

                const [rRows] = await con.query(
                    "SELECT can_manage_members FROM roles WHERE id=?",
                    [roleId]
                );

                if (rRows.length > 0 && rRows[0].can_manage_members == 1) {
                    show_sidebar = "sidebar";
                } else {
                    show_sidebar = "Usersidebar";
                }
            }
        }

        res.render('settings', {
            members,
            adminName,
            show_sidebar,
            session: req.session
        });

    } catch (err) {
        console.error(err);
        res.send("Error loading settings");
    }
});

module.exports = router;
