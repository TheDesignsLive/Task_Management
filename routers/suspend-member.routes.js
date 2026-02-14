const express = require('express');
const router = express.Router();
const con = require('../config/db');

// TOGGLE ACTIVE <-> SUSPEND
router.get('/suspend-member/:id', async (req, res) => {
    const userId = req.params.id;

    try {
        // 1. Get current status
        const [rows] = await con.query(
            "SELECT status FROM users WHERE id = ?",
            [userId]
        );

        if (rows.length === 0) {
            return res.send("<script>alert('User not found'); window.history.back();</script>");
        }

        const currentStatus = rows[0].status;

        // 2. Toggle status
        let newStatus = "ACTIVE";
        if (currentStatus === "ACTIVE") {
            newStatus = "SUSPEND";
        } else if (currentStatus === "SUSPEND") {
            newStatus = "ACTIVE";
        }

        // 3. Update status
        await con.query(
            "UPDATE users SET status = ? WHERE id = ?",
            [newStatus, userId]
        );

        // 4. Redirect back
        res.redirect('/view_member');

    } catch (err) {
        console.error(err);
        res.send("<script>alert('Database error'); window.history.back();</script>");
    }
});

module.exports = router;
