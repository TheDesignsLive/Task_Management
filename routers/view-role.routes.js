const express = require('express');
const router = express.Router();
const con = require('../config/db');

router.get('/', async (req, res) => {

    if (!req.session.role) {
        return res.redirect('/');
    }

    let show_sidebar = "Usersidebar";
    let members = [];
    let roles = [];
    let adminId = null;

    try {

        // ================= ADMIN =================
        if (req.session.role === "admin") {

            show_sidebar = "sidebar";
            adminId = req.session.adminId;

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
                const role_id = userRows[0].role_id;

                // check permission
                const [roleRows] = await con.query(
                    "SELECT can_manage_members FROM roles WHERE id=?",
                    [role_id]
                );

                if (roleRows.length > 0 && roleRows[0].can_manage_members == 1) {
                    show_sidebar = "sidebar";
                }

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
            show_sidebar,
            session: req.session
        });

    } catch (err) {
        console.error(err);
        res.send("Error loading roles");
    }
});

module.exports = router;
