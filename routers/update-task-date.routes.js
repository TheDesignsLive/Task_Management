const express = require('express');
const router = express.Router();
const con = require('../config/db');

router.post('/update-task-date', (req, res) => {
    const { id, due_date } = req.body;

    if (!id || !due_date) {
        return res.json({ success: false });
    }

    const sql = "UPDATE tasks SET due_date = ? WHERE id = ?";
    con.query(sql, [due_date, id], (err, result) => {
        if (err) {
            console.log(err);
            return res.json({ success: false });
        }
          // 🔴 AUTO REFRESH FOR ALL USERS (ROLE UPDATED)
    req.io.emit('update_tasks');
        res.json({ success: true });
    });
});

module.exports = router;
