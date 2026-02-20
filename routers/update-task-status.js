
const express = require('express');
const router = express.Router();
const db = require('../config/db');

// POST /update-task-status
router.post('/update-task-status', async (req, res) => {
     if (!req.session.role) return res.redirect('/');
     
    try {
        let { id, status, section } = req.body;

        //  Fix: If status is null or 'OPEN', treat as OPEN
        if (!status || status === null) status = 'OPEN';

        //  Fix: If section is null or undefined, default to TASK
        if (!section || section === null) section = 'TASK';

        await db.execute(
            `UPDATE tasks SET status = ?, section = ? WHERE id = ?`,
            [status, section, id]
        );

        //  Send back updated status and section so frontend can update tasks array
        res.json({ success: true, status, section });
    } catch (err) {
        console.error(err);
        res.status(500).json({ success: false, error: 'Database error' });
    }
});

module.exports = router;
