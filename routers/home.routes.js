const express = require('express');
const router = express.Router();
const con = require('../config/db'); // DB connection

router.get("/home", async (req, res) => {

    if (req.session.userId || req.session.adminId) {

        console.log("SESSION:", req.session);

        let show_sidebar = "Usersidebar";   // default
        let members = [];                  // for dropdown
        let adminId = null;

        // ================= ADMIN =================
        if (req.session.role === "admin") {
            show_sidebar = "sidebar";
            adminId = req.session.adminId;
        }

        // ================= USER =================
        else if (req.session.role === "user") {
            try {
                const [userRows] = await con.query(
                    "SELECT role_id, admin_id FROM users WHERE id=?",
                    [req.session.userId]
                );

                if (userRows.length > 0) {
                    const role_id = userRows[0].role_id;
                    adminId = userRows[0].admin_id;

                    // check permission
                    const [roleRows] = await con.query(
                        "SELECT can_manage_members FROM roles WHERE id=?",
                        [role_id]
                    );

                    if (roleRows.length > 0 && roleRows[0].can_manage_members == 1) {
                        show_sidebar = "sidebar";
                    } else {
                        show_sidebar = "Usersidebar";
                    }
                }

            } catch (err) {
                console.error(err);
            }
        }

        // ================= GET MEMBERS FOR DROPDOWN =================
        try {
            if (adminId) {
                const [rows] = await con.query(
                    "SELECT id, name FROM users WHERE admin_id=? AND status='ACTIVE'",
                    [adminId]
                );
                members = rows; // send to navbar
            }
        } catch (err) {
            console.error(err);
        }

        return res.render("home", { 
            show_sidebar,
            members,
            session: req.session
        });
    }

    res.redirect("/");
});

module.exports = router;
