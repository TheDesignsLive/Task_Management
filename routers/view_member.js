const express = require('express');
const router = express.Router();
const con = require('../config/db'); // MySQL connection

// GET route to view all members
router.get('/view_member', async (req, res) => {
    try {
        // fetch all users
        const [users] = await con.execute("SELECT * FROM users");

        // for dropdown like home page
        let members = [];
        let adminId = null;

        if (req.session.userId || req.session.adminId) {
            if (req.session.role === 'admin') {
                adminId = req.session.adminId;
            } else if (req.session.role === 'user') {
                const [userRows] = await con.query(
                    "SELECT admin_id FROM users WHERE id=?",
                    [req.session.userId]
                );
                if (userRows.length > 0) {
                    adminId = userRows[0].admin_id;
                }
            }

            if (adminId) {
                const [rows] = await con.query(
                    "SELECT id, name FROM users WHERE admin_id=? AND status='ACTIVE' AND id!=?",
                    [adminId, req.session.userId]
                );
                members = rows;
            }
        }

        // ==============================
        // ADD THIS (roles dropdown data)
        // ==============================
        const adminIdForRoles = req.session.adminId;

        let roles = [];
        if (adminIdForRoles) {
            const [roleRows] = await con.query(
                "SELECT id, role_name FROM roles WHERE admin_id=?",
                [adminIdForRoles]
            );
            roles = roleRows;
        }
        // ==============================
        res.render('view_member', { 
            users,         // for table
            members,       // for dropdown
            roles,         // <-- added
            session: req.session 
        });

    } catch (err) {
        console.error(err);
        res.send("Error fetching members");
    }
});

module.exports = router;
