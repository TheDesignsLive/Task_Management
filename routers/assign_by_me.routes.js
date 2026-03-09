const express = require('express');
const router = express.Router();
const con = require('../config/db');

router.get('/', async (req, res) => {

    if (!req.session.role) {
        return res.redirect('/');
    }

    let members = [];
    let adminName = null;
    let openTasks = [];
    let completedTasks = [];
    let adminId = req.session.adminId;
    const sessionRole = req.session.role;
    const sessionUserId = req.session.userId;

    try {
        // Fetch admin name (Exactly like notification router)
        const [aRows] = await con.query("SELECT name FROM admins WHERE id=?", [adminId]);
        if (aRows.length > 0) adminName = aRows[0].name;

        // ================= NAVBAR DROPDOWN (MEMBERS) LOGIC =================
        if (sessionRole === "admin") {
            const [mRows] = await con.query(
                "SELECT id, name FROM users WHERE admin_id=? AND status='ACTIVE'", 
                [adminId]
            );
            members = mRows;
        } else {
            // User view: No self, No admin in Navbar
            const [mRows] = await con.query(
                "SELECT id, name FROM users WHERE admin_id=? AND status='ACTIVE' AND id != ?", 
                [adminId, sessionUserId]
            );
            members = mRows;
        }

        // ================= ADMIN TASKS =================
        if (sessionRole === "admin") {
            const [rows] = await con.query(`
                SELECT 
                    t.id, t.title, t.description, t.priority, t.status, t.due_date, t.created_at, t.assigned_to AS assignee_id,
                    COALESCE(u.name, CONCAT(a.name, ' (Admin)')) AS assigned_to
                FROM tasks t
                LEFT JOIN users u ON t.assigned_to = u.id AND t.assigned_to != 0
                LEFT JOIN admins a ON t.admin_id = a.id AND t.assigned_to = 0
                WHERE t.who_assigned='admin' AND t.assigned_by=? AND t.assigned_to != 0
                ORDER BY t.due_date ASC
            `, [adminId]);

            rows.forEach(task => {
                if (task.status === 'COMPLETED') completedTasks.push(task);
                else openTasks.push(task);
            });
        }
        // ================= USER TASKS =================
        else if (sessionRole === "user") {
            const [rows] = await con.query(`
                SELECT 
                    t.id, t.title, t.description, t.priority, t.status, t.due_date, t.created_at, t.assigned_to AS assignee_id,
                    COALESCE(u.name, CONCAT(a.name, ' (Admin)')) AS assigned_to
                FROM tasks t
                LEFT JOIN users u ON t.assigned_to = u.id AND t.assigned_to != 0
                LEFT JOIN admins a ON t.admin_id = a.id AND t.assigned_to = 0
                WHERE t.who_assigned='user' AND t.assigned_by=? AND t.assigned_to != ?
                ORDER BY t.due_date ASC
            `, [sessionUserId, sessionUserId]);

            rows.forEach(task => {
                if (task.status === 'COMPLETED') completedTasks.push(task);
                else openTasks.push(task);
            });
        }

        res.render('assign_by_me', {
            members,
            adminName,
            openTasks,
            completedTasks,
            session: req.session
        });

    } catch (err) {
        console.error(err);
        res.send("Error loading Assign By Me");
    }
});

/* ================= UPDATE ASSIGNEE ================= */
router.post('/update-assignee', async (req, res) => {
    if (!req.session.role) return res.status(401).json({ success: false, message: 'Unauthorized' });

    const { taskId, newAssigneeId } = req.body;

    try {
        await con.query(
            "UPDATE tasks SET assigned_to = ? WHERE id = ?",
            [newAssigneeId, taskId]
        );
        req.io.emit('abm_assignee_changed', { id: taskId, newAssigneeId });
        res.json({ success: true, message: 'Assignee updated' });
    } catch (err) {
        console.error(err);
        res.status(500).json({ success: false, message: 'Database Error' });
    }
});

/* ================= DELETE SINGLE TASK ================= */
router.post('/delete-task/:id', async (req, res) => {
    if (!req.session.role) return res.status(401).json({ success: false, message: 'Unauthorized' });

    try {
        await con.query("DELETE FROM tasks WHERE id = ?", [req.params.id]);
        req.io.emit('abm_task_deleted', req.params.id); 
        res.json({ success: true });
    } catch (err) {
        console.error(err);
        res.status(500).json({ success: false });
    }
});

/* ================= DELETE ALL COMPLETED ================= */
router.post('/delete-all-completed', async (req, res) => {
    if (!req.session.role) return res.status(401).json({ success: false, message: 'Unauthorized' });
    
    try {
        if (req.session.role === 'admin') {
            await con.query(`
                DELETE FROM tasks 
                WHERE admin_id=? AND who_assigned='admin' AND assigned_by=? AND assigned_to != 0 AND status='COMPLETED'
            `, [req.session.adminId, req.session.adminId]);
        } else if (req.session.role === 'user') {
            await con.query(`
                DELETE FROM tasks 
                WHERE who_assigned='user' AND assigned_by=? AND assigned_to != ? AND status='COMPLETED'
            `, [req.session.userId, req.session.userId]);
        }
        
        req.io.emit('abm_completed_deleted'); 
        res.json({ success: true });
    } catch (err) {
        console.error(err);
        res.status(500).json({ success: false });
    }
});

module.exports = router;