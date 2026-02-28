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

    try {
        let adminId = req.session.adminId;

        // Fetch members for editing dropdown
        const [mRows] = await con.query(
            "SELECT id, name FROM users WHERE admin_id=? AND status='ACTIVE'",
            [adminId]
        );
        
        // Fetch admin name
        const [aRows] = await con.query("SELECT id, name FROM admins WHERE id=?", [adminId]);
        if (aRows.length > 0) adminName = aRows[0].name;

        // Logic for Dropdown Members
        if (req.session.role === "admin") {
            // Admin sees all employees, but we don't include admin in this specific dropdown logic
            members = mRows; 
        } else {
            // User sees Admin (with tag) and all other employees except themselves
            const adminObj = { id: 0, name: `${aRows[0].name} (Admin)` };
            const otherEmployees = mRows.filter(m => m.id != req.session.userId);
            members = [adminObj, ...otherEmployees];
        }

        // ================= ADMIN =================
        if (req.session.role === "admin") {
            const [rows] = await con.query(`
                SELECT 
                    t.id, t.title, t.description, t.priority, t.status, t.due_date, t.created_at, t.assigned_to AS assignee_id,
                    COALESCE(u.name, CONCAT(a.name, ' (Admin)')) AS assigned_to
                FROM tasks t
                LEFT JOIN users u ON t.assigned_to = u.id AND t.assigned_to != 0
                LEFT JOIN admins a ON t.admin_id = a.id AND t.assigned_to = 0
                WHERE t.who_assigned='admin' AND t.assigned_by=? AND t.assigned_to != 0
                ORDER BY t.due_date ASC
            `, [req.session.adminId]);

            rows.forEach(task => {
                if (task.status === 'COMPLETED') completedTasks.push(task);
                else openTasks.push(task);
            });
        }
        // ================= USER =================
        else if (req.session.role === "user") {
            const [rows] = await con.query(`
                SELECT 
                    t.id, t.title, t.description, t.priority, t.status, t.due_date, t.created_at, t.assigned_to AS assignee_id,
                    COALESCE(u.name, CONCAT(a.name, ' (Admin)')) AS assigned_to
                FROM tasks t
                LEFT JOIN users u ON t.assigned_to = u.id AND t.assigned_to != 0
                LEFT JOIN admins a ON t.admin_id = a.id AND t.assigned_to = 0
                WHERE t.who_assigned='user' AND t.assigned_by=? AND t.assigned_to != ?
                ORDER BY t.due_date ASC
            `, [req.session.userId, req.session.userId]);

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
    if (!req.session.role) return res.status(401).json({ success: false });

    const { taskId, newAssigneeId } = req.body;

    try {
        await con.query(
            "UPDATE tasks SET assigned_to = ? WHERE id = ?",
            [newAssigneeId, taskId]
        );
            // 🔴 AUTO REFRESH FOR ALL USERS (TASK UPDATED)
        req.io.emit('update_tasks');

        res.json({ success: true });
    } catch (err) {
        console.error(err);
        res.status(500).json({ success: false });
    }
});

module.exports = router;