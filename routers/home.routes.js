const express = require('express');
const router = express.Router();
const con = require('../config/db');

router.get("/home", async (req, res) => {

    if (!req.session.role) {
        return res.redirect("/");
    }

    console.log("SESSION:", req.session);

    let show_sidebar = "Usersidebar";
    let members = [];
    let adminId = null;

    try {

        // ============================
        // 1️⃣ ADMIN LOGIN
        // ============================
        if (req.session.role === "admin") {

            show_sidebar = "sidebar";
            adminId = req.session.adminId;

            // Get all company users
            const [rows] = await con.query(
                "SELECT id, name FROM users WHERE admin_id=? AND status='ACTIVE'",
                [adminId]
            );

            members = rows;
        }

        // ============================
        // 2️⃣ USER LOGIN
        // ============================
        else if (req.session.role === "user") {

            // Get user's role + admin_id
            const [userRows] = await con.query(
                "SELECT role_id, admin_id FROM users WHERE id=?",
                [req.session.userId]
            );

            if (userRows.length > 0) {

                const role_id = userRows[0].role_id;
                adminId = userRows[0].admin_id;

                // Check permission
                const [roleRows] = await con.query(
                    "SELECT can_manage_members FROM roles WHERE id=?",
                    [role_id]
                );

                if (roleRows.length > 0 && roleRows[0].can_manage_members == 1) {
                    show_sidebar = "sidebar";
                } else {
                    show_sidebar = "Usersidebar";
                }

                // Get company users except himself
                const [rows] = await con.query(
                    "SELECT id, name FROM users WHERE admin_id=? AND status='ACTIVE' AND id != ?",
                    [adminId, req.session.userId]
                );

                members = rows;
            }
        }

        // ============================
        // 3️⃣ Render Home
        // ============================
        return res.render("home", {
            show_sidebar,
            members,
            session: req.session
        });

    } catch (err) {
        console.error(err);
        res.send("Error loading home");
    }
});

module.exports = router;
