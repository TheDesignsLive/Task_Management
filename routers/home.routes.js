const express = require('express');
const router = express.Router();
const con = require('../config/db'); // DB connection


// ================= HOME =================
router.get("/home", async (req, res) => {

    if (req.session.userId || req.session.adminId) {

        console.log("SESSION:", req.session);

        let show_sidebar = "Usersidebar";   // default

        // ================= ADMIN =================
        if (req.session.role === "admin") {
            show_sidebar = "sidebar";
        }

        // ================= USER =================
        else if (req.session.role === "user") {
            try {
                const [userRows] = await con.query(
                    "SELECT role_id FROM users WHERE id=?",
                    [req.session.userId]
                );

                if (userRows.length > 0) {
                    const role_id = userRows[0].role_id;

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

        return res.render("home", { 
            show_sidebar,
            session: req.session
        });
    }

    res.redirect("/");
});


// ================= API FOR NAVBAR DROPDOWN =================
router.get("/get-members", async (req, res) => {
    try {

        if (!(req.session.userId || req.session.adminId)) {
            return res.json([]);
        }

        let adminId = null;

        if (req.session.role === "admin") {
            adminId = req.session.adminId;
        } else {
            const [rows] = await con.query(
                "SELECT admin_id FROM users WHERE id=?",
                [req.session.userId]
            );
            if (rows.length > 0) adminId = rows[0].admin_id;
        }

        if (!adminId) return res.json([]);

        const [members] = await con.query(
            "SELECT id, name FROM users WHERE admin_id=? AND status='ACTIVE'",
            [adminId]
        );

        res.json(members);

    } catch (err) {
        console.error(err);
        res.json([]);
    }
});

module.exports = router;
