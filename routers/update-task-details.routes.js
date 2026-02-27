const express = require('express');
const router = express.Router();
const db = require('../config/db');

// POST /update-task-details
router.post('/', async (req, res) => {
    // Basic authentication check
    if (!req.session.role) return res.status(401).json({ success: false, error: "Unauthorized" });

    try {
        const { id, title, description, priority, due_date } = req.body;

        // Ensure description isn't literally "null" string if user cleared it
        const finalDesc = (description === "" || description === null) ? null : description;

        const sql = `
            UPDATE tasks 
            SET title = ?, description = ?, priority = ?, due_date = ? 
            WHERE id = ?
        `;

        await db.execute(sql, [title, finalDesc, priority.toUpperCase(), due_date, id]);

        res.json({ success: true });
    } catch (err) {
        console.error(err);
        res.status(500).json({ success: false, error: 'Database error' });
    }
});

// // POST /delete-task/:id (Bonus: matching the delete button in your menu)
// router.post('/delete-task/:id', async (req, res) => {
//     if (!req.session.role) return res.status(401).send("Unauthorized");
//     try {
//         await db.execute("DELETE FROM tasks WHERE id = ?", [req.params.id]);
//         res.json({ success: true });
//     } catch (err) {
//         console.error(err);
//         res.status(500).send("Error deleting task");
//     }
// });

module.exports = router;