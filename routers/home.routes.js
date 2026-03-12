const express = require('express');
const router = express.Router();
const con = require('../config/db');

/* ===============================
    NEW API ENDPOINT FOR NO-RELOAD
================================ */
router.get('/api/get-all-tasks', async (req, res) => {
    if (!req.session.role) return res.status(401).json({ success: false });
    const adminId = req.session.adminId;
    const userId = req.session.userId;
    let tasks = [];

    try {
        if (req.session.role === "admin") {
            const [taskRows] = await con.query(
                "SELECT id, title, description, priority, due_date, status, section FROM tasks WHERE admin_id=? AND assigned_to=0 AND who_assigned='admin' ORDER BY due_date ASC",
                [adminId]
            );
            const [otherTaskRows] = await con.query(
                "SELECT t.id, t.title, t.description, t.priority, t.due_date, t.status, 'OTHERS' AS section, u.name AS assigned_by_name FROM tasks t JOIN users u ON t.assigned_by = u.id WHERE t.admin_id=? AND t.assigned_to=0 AND t.who_assigned='user' ORDER BY due_date ASC",
                [adminId]
            );
            tasks = [...taskRows, ...otherTaskRows];
        } else {
            const [adminTasksRows] = await con.query(
                "SELECT t.id, t.title, t.description, t.priority, t.due_date, t.status, 'OTHERS' AS section, a.name AS assigned_by_name FROM tasks t JOIN admins a ON t.assigned_by = a.id WHERE t.admin_id=? AND t.assigned_to=? AND t.who_assigned='admin' ORDER BY due_date ASC",
                [adminId, userId]
            );
           // ✅ Tasks assigned by this user to self
            const [userOwnTasksRows] = await con.query(
                "SELECT id, title, description, priority, due_date, status, section FROM tasks WHERE admin_id=? AND assigned_to=? AND who_assigned='user' AND assigned_by=? ORDER BY due_date ASC",
                [adminId, userId, userId]
            );

            // ✅ Tasks assigned by this user to other users -> OTHERS
            const [userToOthersTasksRows] = await con.query(
                "SELECT t.id, t.title, t.description, t.priority, t.due_date, t.status, 'OTHERS' AS section, u.name AS assigned_by_name FROM tasks t JOIN users u ON t.assigned_by = u.id WHERE t.admin_id=? AND t.assigned_to=? AND who_assigned='user' AND assigned_by != ? ORDER BY due_date ASC",
                [adminId, userId, userId]
            );
   tasks = [...userOwnTasksRows, ...adminTasksRows, ...userToOthersTasksRows]; // ✅ use correct variable names
        }
        res.json({ success: true, tasks });
    } catch (err) { res.status(500).json({ success: false }); }
});

/* ===============================
    HOME PAGE (ADMIN + USER)
================================ */
router.get('/home', async (req, res) => {
    if (!req.session.role) return res.redirect('/');
    let members = [];
    let adminName = null;
    let tasks = [];
    let adminId;
    try {
        if (req.session.role === "admin") {
            adminId = req.session.adminId;
            req.session.control_type = 'ADMIN';
            const [adminRows] = await con.query("SELECT name FROM admins WHERE id=?", [adminId]);
            if (adminRows.length > 0) adminName = adminRows[0].name;
            const [rows] = await con.query("SELECT id, name FROM users WHERE admin_id=? AND status='ACTIVE'", [adminId]);
            members = rows;
            const [taskRows] = await con.query(`SELECT id, title, description, priority, due_date, status, section FROM tasks WHERE admin_id=? AND assigned_to=0 AND who_assigned='admin' ORDER BY due_date ASC, CASE priority WHEN 'HIGH' THEN 1 WHEN 'MEDIUM' THEN 2 WHEN 'LOW' THEN 3 ELSE 4 END ASC`, [adminId]);
            tasks = taskRows;
            const [otherTaskRows] = await con.query(`SELECT t.id, t.title, t.description, t.priority, t.due_date, t.status, 'OTHERS' AS section, u.name AS assigned_by_name FROM tasks t JOIN users u ON t.assigned_by = u.id WHERE t.admin_id=? AND t.assigned_to=0 AND t.who_assigned='user' ORDER BY due_date ASC, CASE priority WHEN 'HIGH' THEN 1 WHEN 'MEDIUM' THEN 2 WHEN 'LOW' THEN 3 ELSE 4 END ASC`, [adminId]);
            tasks = [...tasks, ...otherTaskRows];
        } else if (req.session.role === "user") {
            adminId = req.session.adminId;
            const [userRoleRows] = await con.query("SELECT role_id FROM users WHERE id=?", [req.session.userId]);
            if (userRoleRows.length > 0) {
                const roleId = userRoleRows[0].role_id;
                const [roleRows] = await con.query("SELECT control_type FROM roles WHERE id=?", [roleId]);
                if (roleRows.length > 0) req.session.control_type = roleRows[0].control_type;
            }
            const [adminRows] = await con.query("SELECT name FROM admins WHERE id=?", [adminId]);
            if (adminRows.length > 0) adminName = adminRows[0].name;
            const [rows] = await con.query("SELECT id, name FROM users WHERE admin_id=? AND status='ACTIVE' AND id!=?", [adminId, req.session.userId]);
            members = rows;
            const [adminTasksRows] = await con.query(`SELECT t.id, t.title, t.description, t.priority, t.due_date, t.status, 'OTHERS' AS section, a.name AS assigned_by_name FROM tasks t JOIN admins a ON t.assigned_by = a.id WHERE t.admin_id=? AND t.assigned_to=? AND t.who_assigned='admin' ORDER BY due_date ASC`, [adminId, req.session.userId]);
              // ✅ Tasks assigned by this user to self
            const [userOwnTasksRows] = await con.query(`SELECT id, title, description, priority, due_date, status, section FROM tasks WHERE admin_id=? AND assigned_to=? AND who_assigned='user' AND assigned_by=? ORDER BY due_date ASC`, [adminId, req.session.userId, req.session.userId]);

            // ✅ Tasks assigned by this user to other users -> OTHERS
            const [userToOthersTasksRows] = await con.query(`SELECT t.id, t.title, t.description, t.priority, t.due_date, t.status, 'OTHERS' AS section, u.name AS assigned_by_name FROM tasks t JOIN users u ON t.assigned_by = u.id WHERE t.admin_id=? AND t.assigned_to=? AND who_assigned='user' AND assigned_by != ? ORDER BY due_date ASC`, [adminId, req.session.userId, req.session.userId]);

            tasks = [...userOwnTasksRows, ...adminTasksRows, ...userToOthersTasksRows]; // ✅ use correct variable names
        }
        res.render("home", { members, adminName, tasks, session: req.session });
    } catch (err) { res.send("Error loading home"); }
});

/* ===============================
    TASK ACTIONS (WITH EMIT)
================================ */
router.post('/update-task-date', async (req, res) => {
    const { id, due_date } = req.body;
    try {
        await con.query("UPDATE tasks SET due_date=? WHERE id=?", [due_date, id]);
        req.io.emit('update_tasks'); 
        res.json({ success: true });
    } catch (err) { res.status(500).json({ success: false }); }
});

router.post('/update-task-status', async (req, res) => {
    const { id, status } = req.body;
    try {
        await con.query("UPDATE tasks SET status=? WHERE id=?", [status, id]);
        req.io.emit('update_tasks');
        res.json({ success: true });
    } catch (err) { res.status(500).json({ success: false }); }
});

router.post('/update-task-section', async (req, res) => {
    const { id, section } = req.body;
    try {
        await con.query("UPDATE tasks SET section=? WHERE id=?", [section, id]);
        req.io.emit('update_tasks');
        res.json({ success: true });
    } catch (err) { res.status(500).json({ success: false }); }
});

router.post('/edit-task-details', async (req, res) => {
    const { id, title, description, priority, due_date } = req.body;
    try {
        await con.query("UPDATE tasks SET title=?, description=?, priority=?, due_date=? WHERE id=?", [title, description, priority, due_date, id]);
        req.io.emit('update_tasks');
        res.json({ success: true });
    } catch (err) { res.status(500).json({ success: false }); }
});

router.post('/delete-task/:id', async (req, res) => {
    try {
        await con.query("DELETE FROM tasks WHERE id=?", [req.params.id]);
        req.io.emit('update_tasks');
        res.json({ success: true });
    } catch (err) { res.status(500).json({ success: false }); }
});

router.post('/delete-completed-tasks', async (req, res) => {
    try {
        const adminId = req.session.adminId;
        await con.query("DELETE FROM tasks WHERE admin_id=? AND status='COMPLETED'", [adminId]);
        req.io.emit('update_tasks');
        res.json({ success: true });
    } catch (err) { res.status(500).json({ success: false }); }
});

module.exports = router;