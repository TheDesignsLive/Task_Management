// assignbyme.routes.js desktop
const express = require('express');
const router = express.Router();
const con = require('../config/db');
const { notifyMobile } = require('../utils/notifyMobile');

router.get('/', async (req, res) => {
    if (!req.session.role) return res.redirect('/');

    let members = [], adminName = null, openTasks = [], completedTasks = [], teams = [];
    let adminId = req.session.adminId;
    const sessionRole = req.session.role;
    const sessionUserId = req.session.userId;

    try {
        const [aRows] = await con.query("SELECT name FROM admins WHERE id=?", [adminId]);
        if (aRows.length > 0) adminName = aRows[0].name;

        // ✅ Fetch Teams
        const [tRows] = await con.query("SELECT id, name FROM teams WHERE admin_id=? ORDER BY name ASC", [adminId]);
        teams = tRows;

        // ✅ Fetch Members with team_id from roles table (Admin OR Owner)
        if (sessionRole === "admin" || sessionRole === "owner") {
            const [mRows] = await con.query(
                "SELECT u.id, u.name, r.team_id FROM users u LEFT JOIN roles r ON u.role_id = r.id WHERE u.admin_id=? AND u.status='ACTIVE'", 
                [adminId]
            );
            members = mRows;
        } else {
            const [mRows] = await con.query(
                "SELECT u.id, u.name, r.team_id FROM users u LEFT JOIN roles r ON u.role_id = r.id WHERE u.admin_id=? AND u.status='ACTIVE' AND u.id != ?", 
                [adminId, sessionUserId]
            );
            members = mRows;
        }

        // ✅ Admin & Owner see tasks they assigned, Users see tasks they assigned
const taskQuery = (sessionRole === "admin") 
    ? `SELECT t.id, t.title, t.description, t.priority, t.status, t.due_date, t.section, 
              t.assigned_to AS assignee_id, 
              COALESCE(u.name, CONCAT(a.name, ' (Admin)')) AS assigned_to 
       FROM tasks t 
       LEFT JOIN users u ON t.assigned_to = u.id AND t.assigned_to != 0 
       LEFT JOIN admins a ON t.admin_id = a.id AND t.assigned_to = 0 
       WHERE t.who_assigned='admin' 
         AND t.assigned_by=? 
         AND t.assigned_to != 0 
       ORDER BY t.due_date ASC`

    : (sessionRole === "owner")
    ? `SELECT t.id, t.title, t.description, t.priority, t.status, t.due_date, t.section, 
              t.assigned_to AS assignee_id, 
              COALESCE(u.name, CONCAT(a.name, ' (Admin)')) AS assigned_to 
       FROM tasks t 
       LEFT JOIN users u ON t.assigned_to = u.id AND t.assigned_to != 0 
       LEFT JOIN admins a ON t.admin_id = a.id AND t.assigned_to = 0 
       WHERE t.who_assigned='owner' 
         AND t.assigned_by=? 
         AND t.assigned_to != ?   -- ✅ MAIN FIX (exclude self)
       ORDER BY t.due_date ASC`

    : `SELECT t.id, t.title, t.description, t.priority, t.status, t.due_date, t.section, 
              t.assigned_to AS assignee_id, 
              COALESCE(u.name, CONCAT(a.name, ' (Admin)')) AS assigned_to 
       FROM tasks t 
       LEFT JOIN users u ON t.assigned_to = u.id AND t.assigned_to != 0 
       LEFT JOIN admins a ON t.admin_id = a.id AND t.assigned_to = 0 
       WHERE t.who_assigned='user' 
         AND t.assigned_by=? 
         AND t.assigned_to != ? 
       ORDER BY t.due_date ASC`;

        // If admin/owner, they pass adminId (since owner acts as admin). If user, pass userId.
const queryParams = (sessionRole === "admin") 
    ? [adminId]
    : (sessionRole === "owner")
    ? [sessionUserId, sessionUserId]   // ✅ exclude self
    : [sessionUserId, sessionUserId];
        const [rows] = await con.query(taskQuery, queryParams);

        rows.forEach(task => {
            if (task.status === 'COMPLETED') completedTasks.push(task);
            else openTasks.push(task);
        });

        if (req.xhr || req.headers.accept.indexOf('json') > -1) {
            return res.json({ success: true, openTasks, completedTasks, members, teams });
        }

        res.render('assign_by_me', { teams, members, adminName, openTasks, completedTasks, session: req.session, activePage: "assign_by_me" });
    } catch (err) {
        console.error(err);
        res.status(500).send("Error loading Assign By Me");
    }
});

router.post('/update-status', async (req, res) => {
    if (!req.session.role) return res.status(401).json({ success: false });
    const { id, status } = req.body;
    if (!id || !status) return res.status(400).json({ success: false });
    try {
        await con.query('UPDATE tasks SET status=? WHERE id=?', [status, id]);
        req.io.emit('update_tasks');
        notifyMobile();
        res.json({ success: true });
    } catch (err) {
        console.error('[update-status]', err);
        res.status(500).json({ success: false });
    }
});

router.post('/update-assignee', async (req, res) => {
    if (!req.session.role) return res.status(401).json({ success: false });
    try {
        const { taskId, newAssigneeId } = req.body;
        const adminId = req.session.adminId;
        const sessionRole = req.session.role;
        const sessionUserId = req.session.userId;

        // ✅ HANDLE "ALL MEMBERS"
        if (newAssigneeId === 'all') {
            const [tasks] = await con.query("SELECT * FROM tasks WHERE id = ?", [taskId]);
            if (tasks.length > 0) {
                const task = tasks[0];
                await con.query("DELETE FROM tasks WHERE id = ?", [taskId]);
                
                const [users] = await con.query("SELECT id FROM users WHERE admin_id=?", [adminId]);
                for (let user of users) {
                    if ((sessionRole === 'admin' && user.id === req.session.adminId) ||
                        (sessionRole !== 'admin' && user.id === req.session.userId)) continue;
                    await con.query("INSERT INTO tasks (admin_id, title, description, priority, due_date, assigned_to, assigned_by, who_assigned, section, status) VALUES (?, ?, ?, ?, ?, ?, ?, ?, 'OTHERS', ?)", [task.admin_id, task.title, task.description, task.priority, task.due_date, user.id, task.assigned_by, task.who_assigned, task.status]);
                }
                // Assign to admin
                await con.query("INSERT INTO tasks (admin_id, title, description, priority, due_date, assigned_to, assigned_by, who_assigned, section, status) VALUES (?, ?, ?, ?, ?, 0, ?, ?, 'OTHERS', ?)", [task.admin_id, task.title, task.description, task.priority, task.due_date, task.assigned_by, task.who_assigned, task.status]);
            }
        } 
        // ✅ HANDLE "ALL TEAM MEMBERS"
        else if (String(newAssigneeId).startsWith("team_")) {
            const teamId = newAssigneeId.split("_")[1];
            const [tasks] = await con.query("SELECT * FROM tasks WHERE id = ?", [taskId]);
            if (tasks.length > 0) {
                const task = tasks[0];
                await con.query("DELETE FROM tasks WHERE id = ?", [taskId]);
                
                const [users] = await con.query("SELECT u.id FROM users u JOIN roles r ON u.role_id = r.id WHERE u.admin_id=? AND r.team_id=? AND u.status='ACTIVE'", [adminId, teamId]);
                for (let user of users) {
                    if ((sessionRole === 'admin' && user.id === req.session.adminId) ||
                        (sessionRole !== 'admin' && user.id === req.session.userId)) continue;
                    await con.query("INSERT INTO tasks (admin_id, title, description, priority, due_date, assigned_to, assigned_by, who_assigned, section, status) VALUES (?, ?, ?, ?, ?, ?, ?, ?, 'OTHERS', ?)", [task.admin_id, task.title, task.description, task.priority, task.due_date, user.id, task.assigned_by, task.who_assigned, task.status]);
                }
            }
        } 
        // ✅ HANDLE SINGLE MEMBER
        else {
            let finalAssignedTo = newAssigneeId;
            if (sessionRole === 'admin' && parseInt(newAssigneeId) === req.session.adminId) finalAssignedTo = 0;
            if ((sessionRole === 'user' || sessionRole === 'owner') && (newAssigneeId === 'admin' || parseInt(newAssigneeId) === adminId)) finalAssignedTo = 0;

            let sectionValue = 'TASK';
            if ((sessionRole === 'admin' || sessionRole === 'owner') && parseInt(finalAssignedTo) !== 0) sectionValue = 'OTHERS';
            if (sessionRole !== 'admin' && sessionRole !== 'owner' && parseInt(finalAssignedTo) !== parseInt(sessionUserId)) sectionValue = 'OTHERS';

            await con.query("UPDATE tasks SET assigned_to = ?, section = IF(status='COMPLETED', section, ?) WHERE id = ?", [finalAssignedTo, sectionValue, taskId]);
        }

req.io.emit('update_tasks');
        notifyMobile();
        res.json({ success: true });
    } catch (err) { 
        console.error(err); 
        res.status(500).json({ success: false }); 
    }
});

router.post('/delete-task/:id', async (req, res) => {
    if (!req.session.role) return res.status(401).json({ success: false });
    try {
        await con.query("DELETE FROM tasks WHERE id = ?", [req.params.id]);
        req.io.emit('update_tasks');
        notifyMobile();
        res.json({ success: true });
    } catch (err) { res.status(500).json({ success: false }); }
});

router.post('/delete-all-completed', async (req, res) => {
    if (!req.session.role) return res.status(401).json({ success: false });
    try {
        if (req.session.role === 'admin' || req.session.role === 'owner') {
            const assignerId = req.session.role === 'admin' ? req.session.adminId : req.session.userId;
            const whoAssigned = req.session.role;
            await con.query("DELETE FROM tasks WHERE admin_id=? AND who_assigned=? AND assigned_by=? AND assigned_to != 0 AND status='COMPLETED'", [req.session.adminId, whoAssigned, assignerId]);
        } else {
            await con.query("DELETE FROM tasks WHERE who_assigned='user' AND assigned_by=? AND assigned_to != ? AND status='COMPLETED'", [req.session.userId, req.session.userId]);
        }
        req.io.emit('update_tasks');
        notifyMobile();
        res.json({ success: true });
    } catch (err) { res.status(500).json({ success: false }); }
});


router.post('/edit-task', async (req, res) => {
    try {
        const { id, title, description, priority, due_date } = req.body;

        let fields = [];
        let values = [];

        if (title !== null) {
            fields.push("title=?");
            values.push(title);
        }

        if (description !== null) {
            fields.push("description=?");
            values.push(description);
        }

        if (priority !== null) {
            fields.push("priority=?");
            values.push(priority);
        }

        if (due_date !== null) {
            fields.push("due_date=?");
            values.push(due_date);
        }

        if (fields.length === 0) {
            return res.json({ success: true });
        }

        values.push(id);

        await con.query(
            `UPDATE tasks SET ${fields.join(", ")} WHERE id=?`,
            values
        );

        req.io.emit('update_tasks');
        notifyMobile();

        res.json({ success: true });
    } catch (err) {
        console.error(err);
        res.status(500).json({ success: false });
    }
});

module.exports = router;
