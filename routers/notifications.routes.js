const express = require('express');
const router = express.Router();
const con = require('../config/db');

router.get('/notifications', async (req, res) => {

    if (!req.session.role) {
        return res.redirect('/');
    }

    let show_sidebar = "Usersidebar";
    let members = [];
    let adminName = null;
    let adminId = null;
    let memberRequests = [];

    try {

        // ================= ADMIN =================
        if (req.session.role === "admin") {

            show_sidebar = "sidebar";
            adminId = req.session.adminId;

            // members
            const [mRows] = await con.query(
                "SELECT id, name FROM users WHERE admin_id=? AND status='ACTIVE'",
                [adminId]
            );
            members = mRows;

            // admin name
            const [aRows] = await con.query(
                "SELECT name FROM admins WHERE id=?",
                [adminId]
            );
            if (aRows.length > 0) adminName = aRows[0].name;

            // ✅ UPDATED FETCH WITH JOINS
            const [reqRows] = await con.query(`
                SELECT 
                    mr.id,
                    mr.name,
                    mr.email,
                    mr.phone,
                    mr.profile_pic,
                    mr.created_at,
                    r.role_name,
                    u.name AS requested_by_name
                FROM member_requests mr
                JOIN roles r ON r.id = mr.role_id
                JOIN users u ON u.id = mr.requested_by
                WHERE mr.admin_id=? AND mr.status='PENDING'
                ORDER BY mr.created_at 
            `, [adminId]);

            memberRequests = reqRows;
        }

        // ================= USER =================
        else if (req.session.role === "user") {
            // DO NOTHING
        }

        res.render('notifications', {
            members,
            adminName,
            show_sidebar,
            memberRequests,
            session: req.session
        });

    } catch (err) {
        console.error(err);
        res.send("Error loading notifications");
    }
});

module.exports = router;
