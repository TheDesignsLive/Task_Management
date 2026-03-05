const express = require('express');
const router = express.Router();
const con = require('../config/db');

// TOGGLE ACTIVE <-> SUSPEND
router.get('/suspend-member/:id', async (req, res) => {
     if (!req.session.role) return res.status(401).json({ success: false, message: 'Unauthorized' });
     
    const userId = req.params.id;

    try {
        // 1. Get current status
        const [rows] = await con.query(
            "SELECT status FROM users WHERE id = ?",
            [userId]
        );

        if (rows.length === 0) {
            return res.json({ success: false, message: 'User not found' });
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
         // 🔴 AUTO REFRESH FOR ALL USERS (ROLE UPDATED)
    req.io.emit('update_members');
        // 4. Return JSON
        res.json({ success: true, message: 'Member status updated successfully' });

    } catch (err) {
        console.error(err);
        res.status(500).json({ success: false, message: 'Database error' });
    }
});

module.exports = router;