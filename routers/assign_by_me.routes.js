const express = require('express');
const router = express.Router();
const con = require('../config/db');

router.get('/', async (req, res) => {
    if (!req.session.role) return res.redirect('/');

    let members = [], adminName = null, openTasks = [], completedTasks = [];
    let adminId = req.session.adminId;
    const sessionRole = req.session.role;
    const sessionUserId = req.session.userId;

    try {
        const [aRows] = await con.query("SELECT name FROM admins WHERE id=?", [adminId]);
        if (aRows.length > 0) adminName = aRows[0].name;

        if (sessionRole === "admin") {
            const [mRows] = await con.query("SELECT id, name FROM users WHERE admin_id=? AND status='ACTIVE'", [adminId]);
            members = mRows;
        } else {
            const [mRows] = await con.query("SELECT id, name FROM users WHERE admin_id=? AND status='ACTIVE' AND id != ?", [adminId, sessionUserId]);
            members = mRows;
        }

        const taskQuery = sessionRole === "admin" 
            ? `SELECT t.id, t.title, t.description, t.priority, t.status, t.due_date, t.assigned_to AS assignee_id, COALESCE(u.name, CONCAT(a.name, ' (Admin)')) AS assigned_to 
               FROM tasks t LEFT JOIN users u ON t.assigned_to = u.id AND t.assigned_to != 0 LEFT JOIN admins a ON t.admin_id = a.id AND t.assigned_to = 0 
               WHERE t.who_assigned='admin' AND t.assigned_by=? AND t.assigned_to != 0 ORDER BY t.due_date ASC`
            : `SELECT t.id, t.title, t.description, t.priority, t.status, t.due_date, t.assigned_to AS assignee_id, COALESCE(u.name, CONCAT(a.name, ' (Admin)')) AS assigned_to 
               FROM tasks t LEFT JOIN users u ON t.assigned_to = u.id AND t.assigned_to != 0 LEFT JOIN admins a ON t.admin_id = a.id AND t.assigned_to = 0 
               WHERE t.who_assigned='user' AND t.assigned_by=? AND t.assigned_to != ? ORDER BY t.due_date ASC`;

        const queryParams = sessionRole === "admin" ? [adminId] : [sessionUserId, sessionUserId];
        const [rows] = await con.query(taskQuery, queryParams);

        rows.forEach(task => {
            if (task.status === 'COMPLETED') completedTasks.push(task);
            else openTasks.push(task);
        });

        if (req.xhr || req.headers.accept.indexOf('json') > -1) {
            return res.json({ success: true, openTasks, completedTasks });
        }

        res.render('assign_by_me', { members, adminName, openTasks, completedTasks, session: req.session });
    } catch (err) {
        console.error(err);
        res.status(500).send("Error loading Assign By Me");
    }
});

router.post('/update-assignee', async (req, res) => {
    if (!req.session.role) return res.status(401).json({ success: false });
    try {
        await con.query("UPDATE tasks SET assigned_to = ? WHERE id = ?", [req.body.newAssigneeId, req.body.taskId]);
        req.io.emit('update_tasks');
        res.json({ success: true });
    } catch (err) { res.status(500).json({ success: false }); }
});

router.post('/delete-task/:id', async (req, res) => {
    if (!req.session.role) return res.status(401).json({ success: false });
    try {
        await con.query("DELETE FROM tasks WHERE id = ?", [req.params.id]);
        req.io.emit('update_tasks');
        res.json({ success: true });
    } catch (err) { res.status(500).json({ success: false }); }
});

router.post('/delete-all-completed', async (req, res) => {
    if (!req.session.role) return res.status(401).json({ success: false });
    try {
        if (req.session.role === 'admin') {
            await con.query("DELETE FROM tasks WHERE admin_id=? AND who_assigned='admin' AND assigned_by=? AND assigned_to != 0 AND status='COMPLETED'", [req.session.adminId, req.session.adminId]);
        } else {
            await con.query("DELETE FROM tasks WHERE who_assigned='user' AND assigned_by=? AND assigned_to != ? AND status='COMPLETED'", [req.session.userId, req.session.userId]);
        }
        req.io.emit('update_tasks');
        res.json({ success: true });
    } catch (err) { res.status(500).json({ success: false }); }
});

module.exports = router;