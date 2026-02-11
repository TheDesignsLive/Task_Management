const express = require('express');
const router = express.Router();
const con = require('../config/db');   // DB connection

router.get("/home", async (req, res) => {
    if (req.session.userId) {

        

        let show_sidebar = "Usersidebar";   // default

        // ================= ADMIN =================
        if (req.session.role === "admin") {
            show_sidebar = "sidebar";
        }

        // ================= USER =================
        else if (req.session.role === "user") {

            try {
                // get user's role_id
                const [userRows] = await con.query(
                    "SELECT role_id FROM users WHERE id=?",
                    [req.session.userId]
                );

                if (userRows.length > 0) {
                    const role_id = userRows[0].role_id;

                    // check can_manage_members from roles table
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
        return res.render("home", { show_sidebar });   // send variable
        
    }

    res.redirect("/");
});

module.exports = router;
