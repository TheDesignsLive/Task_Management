// routers/repeat.routes.js desktop
const express = require('express');
const router = express.Router();
const con = require('../config/db');
const { notifyMobile } = require('../utils/notifyMobile');

// Set repeat type on a task
router.post('/set-repeat', async (req, res) => {
    if (!req.session.role) return res.status(401).json({ success: false });
    try {
        const { task_id, repeat_type } = req.body; // 'none','daily','weekly','monthly'

        // Update the task itself
        await con.query(
            'UPDATE tasks SET repeat_type=? WHERE id=?',
            [repeat_type, task_id]
        );

        if (repeat_type === 'none') {
            // Remove template if turning off
          await con.query('DELETE FROM task_templates WHERE id=?', [task_id]);
            req.io.emit('update_tasks');
            notifyMobile();
            return res.json({ success: true });
        }

        // Get task details to build the template
        const [rows] = await con.query('SELECT * FROM tasks WHERE id=?', [task_id]);
        if (rows.length === 0) return res.json({ success: false });
        const task = rows[0];

        // Upsert template (delete old + insert new)
        await con.query('DELETE FROM task_templates WHERE id=?', [task_id]);
        await con.query(
            `INSERT INTO task_templates 
             (id, admin_id, title, description, priority, assigned_to, assigned_by, who_assigned, section, repeat_type, original_date, last_spawned)
             VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
            [
                task_id,
                task.admin_id,
                task.title,
                task.description,
                task.priority,
                task.assigned_to,
                task.assigned_by,
                task.who_assigned,
                task.section,
                repeat_type,
                task.due_date
                    ? (typeof task.due_date === 'string'
                        ? task.due_date.split('T')[0]
                        : task.due_date.toISOString().split('T')[0])
                    : new Date().toISOString().split('T')[0],
                null
            ]
        );

        // ✅ CREATE CLONE TASK (IMPORTANT FIX)
if (repeat_type !== 'none') {
    let nextDate = new Date(task.due_date || new Date());

    if (repeat_type === 'daily') nextDate.setDate(nextDate.getDate() + 1);
    if (repeat_type === 'weekly') nextDate.setDate(nextDate.getDate() + 7);
    if (repeat_type === 'monthly') nextDate.setMonth(nextDate.getMonth() + 1);

    const nextDateStr = nextDate.toISOString().split('T')[0];

    await con.query(
        `INSERT INTO tasks 
        (title, description, priority, due_date, status, section, assigned_by, assigned_to, who_assigned, admin_id)
        VALUES (?, ?, ?, ?, 'PENDING', ?, ?, ?, ?, ?)`,
        [
            task.title,
            task.description,
            task.priority,
            nextDateStr,
            task.section,
            task.assigned_by,
            task.assigned_to,
            task.who_assigned,
            task.admin_id
        ]
    );
}
    } catch (err) {
        console.error('set-repeat error:', err);
        return res.status(500).json({ success: false });
    }
});

module.exports = router;