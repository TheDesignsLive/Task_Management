const express = require('express');
const router = express.Router();
const con = require('../config/db'); // for callback routes
const db = require('../config/db');  // for promise routes

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

            const [adminRows] = await db.query("SELECT name FROM admins WHERE id=?", [adminId]);
            if (adminRows.length > 0) adminName = adminRows[0].name;

            const [rows] = await db.query("SELECT id, name FROM users WHERE admin_id=? AND status='ACTIVE'", [adminId]);
            members = rows;

            const [taskRows] = await db.query(
                `SELECT id, title, description, priority, due_date, status, section
                 FROM tasks
                 WHERE admin_id=? AND assigned_to=0 AND who_assigned='admin'
                 ORDER BY due_date ASC, CASE priority WHEN 'HIGH' THEN 1 WHEN 'MEDIUM' THEN 2 WHEN 'LOW' THEN 3 ELSE 4 END ASC`,
                [adminId]
            );
            tasks = taskRows;

            const [otherTaskRows] = await db.query(
                `SELECT t.id, t.title, t.description, t.priority, t.due_date, t.status, 'OTHERS' AS section, u.name AS assigned_by_name
                 FROM tasks t JOIN users u ON t.assigned_by = u.id
                 WHERE t.admin_id=? AND t.assigned_to=0 AND t.who_assigned='user'
                 ORDER BY due_date ASC, CASE priority WHEN 'HIGH' THEN 1 WHEN 'MEDIUM' THEN 2 WHEN 'LOW' THEN 3 ELSE 4 END ASC`,
                [adminId]
            );
            tasks = [...tasks, ...otherTaskRows];
        } else if (req.session.role === "user") {
            adminId = req.session.adminId;

            const [userRoleRows] = await db.query("SELECT role_id FROM users WHERE id=?", [req.session.userId]);
            if (userRoleRows.length > 0) {
                const roleId = userRoleRows[0].role_id;
                const [roleRows] = await db.query("SELECT control_type FROM roles WHERE id=?", [roleId]);
                if (roleRows.length > 0) {
                    req.session.control_type = roleRows[0].control_type;
                }
            }

            const [adminRows] = await db.query("SELECT name FROM admins WHERE id=?", [adminId]);
            if (adminRows.length > 0) adminName = adminRows[0].name;

            const [rows] = await db.query("SELECT id, name FROM users WHERE admin_id=? AND status='ACTIVE' AND id!=?", [adminId, req.session.userId]);
            members = rows;

            const [adminTasksRows] = await db.query(
                `SELECT t.id, t.title, t.description, t.priority, t.due_date, t.status, 'OTHERS' AS section, a.name AS assigned_by_name
                 FROM tasks t JOIN admins a ON t.assigned_by = a.id
                 WHERE t.admin_id=? AND t.assigned_to=? AND t.who_assigned='admin'
                 ORDER BY due_date ASC, CASE priority WHEN 'HIGH' THEN 1 WHEN 'MEDIUM' THEN 2 WHEN 'LOW' THEN 3 ELSE 4 END ASC`,
                [adminId, req.session.userId]
            );

            const [userTasksRows] = await db.query(
                `SELECT id, title, description, priority, due_date, status, section
                 FROM tasks
                 WHERE admin_id=? AND assigned_to=? AND who_assigned='user'
                 ORDER BY due_date ASC, CASE priority WHEN 'HIGH' THEN 1 WHEN 'MEDIUM' THEN 2 WHEN 'LOW' THEN 3 ELSE 4 END ASC`,
                [adminId, req.session.userId]
            );

            const [otherUserTasksRows] = await db.query(
                `SELECT t.id, t.title, t.description, t.priority, t.due_date, t.status, 'OTHERS' AS section, u.name AS assigned_by_name
                 FROM tasks t JOIN users u ON t.assigned_by = u.id
                 WHERE t.admin_id=? AND t.assigned_to=? AND t.who_assigned='user' AND t.assigned_by != ? 
                 ORDER BY due_date ASC, CASE priority WHEN 'HIGH' THEN 1 WHEN 'MEDIUM' THEN 2 WHEN 'LOW' THEN 3 ELSE 4 END ASC`,
                [adminId, req.session.userId, req.session.userId]
            );

            tasks = [...userTasksRows, ...adminTasksRows, ...otherUserTasksRows];
        }

        res.render("home", { members, adminName, tasks, session: req.session });
    } catch (err) {
        console.error(err);
        res.send("Error loading home");
    }
});

/* ===============================
   ADD TASK (POST /)
================================ */
router.post('/', async (req, res) => {
  try {
     if (!req.session.role) return res.json({ success: false, message: 'Unauthorized' });
     const { title, description, date, priority, assignedTo } = req.body;

    if (!req.session.adminId && !req.session.userId) {
      return res.status(401).json({ success: false, message: 'Unauthorized' });
    }

    const assigned_by = req.session.role === 'admin' ? req.session.adminId : req.session.userId;
    const who_assigned = req.session.role;

    let admin_id;
    if (req.session.role === 'admin') {
      admin_id = req.session.adminId;
    } else {
      const [rows] = await db.execute("SELECT admin_id FROM users WHERE id=?", [req.session.userId]);
      if (rows.length === 0) return res.status(400).json({ success: false, message: 'User not found' });
      admin_id = rows[0].admin_id;
    }

    let finalAssignedTo = assignedTo;
    if (req.session.role === 'admin' && parseInt(assignedTo) === req.session.adminId) {
      finalAssignedTo = 0;
    }

    let finalDate;
    if (!date) {
      const today = new Date();
      const year = today.getFullYear();
      const month = String(today.getMonth() + 1).padStart(2, '0');
      const day = String(today.getDate()).padStart(2, '0');
      finalDate = `${year}-${month}-${day} 00:00:00`;
    } else {
      finalDate = date;
    }
          
    const [result] = await db.execute(
      `INSERT INTO tasks (admin_id, title, description, priority, due_date, assigned_to, assigned_by, who_assigned, section, status) 
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, 'TASK', 'OPEN')`,
      [admin_id, title, description || null, priority.toUpperCase(), finalDate, finalAssignedTo, assigned_by, who_assigned]
    );

    // Fetch the newly added task to send to clients!
    const [newTaskRows] = await db.execute(`
        SELECT t.*, u.name AS assigned_by_name 
        FROM tasks t LEFT JOIN users u ON t.assigned_by = u.id 
        WHERE t.id = ?`, [result.insertId]
    );

    req.io.emit('task_added', newTaskRows[0]);
    res.json({ success: true, message: 'Task added successfully' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false, message: 'Error adding task' });
  }
});

/* ===============================
   GET SINGLE TASK (FOR EDIT)
================================ */
router.get('/get-task/:id', (req, res) => {
  const { id } = req.params;
  con.query(
    `SELECT id, title, description, priority, DATE_FORMAT(due_date, '%Y-%m-%d') AS due_date FROM tasks WHERE id = ?`,
    [id],
    (err, result) => {
      if (err) return res.status(500).json({ success: false });
      if (result.length === 0) return res.json({ success: false });
      res.json({ success: true, task: result[0] });
    }
  );
});

/* ===============================
   UPDATE FULL TASK
================================ */
router.post('/update-task-details', (req, res) => {
  const { id, title, description, priority, due_date } = req.body;
  const finalDesc = (description === "" || description === null) ? null : description;

  con.query(
    "UPDATE tasks SET title=?, description=?, priority=?, due_date=? WHERE id=?",
    [title, finalDesc, priority.toUpperCase(), due_date || null, id],
    (err) => {
      if (err) return res.status(500).json({ success: false });
      req.io.emit('task_edited', { id, title, description: finalDesc, priority: priority.toUpperCase(), due_date });
      res.json({ success: true });
    }
  );
});

/* ===============================
   UPDATE ONLY DATE
================================ */
router.post('/update-task-date', (req, res) => {
  const { id, due_date } = req.body;
  if (!id || !due_date) return res.json({ success: false });

  con.query("UPDATE tasks SET due_date=? WHERE id=?", [due_date, id], (err) => {
      if (err) return res.json({ success: false });
      req.io.emit('task_date_changed', { id, due_date });
      res.json({ success: true });
  });
});

/* ===============================
   UPDATE TASK STATUS
================================ */
router.post('/update-task-status', (req, res) => {
  let { id, status, section } = req.body;
  if (!status || status === null) status = 'OPEN';
  if (!section || section === null) section = 'TASK';

  con.query("UPDATE tasks SET status=?, section=? WHERE id=?", [status, section, id], (err) => {
      if (err) return res.status(500).json({ success: false });
      req.io.emit('task_status_changed', { id, status, section });
      res.json({ success: true, status, section });
  });
});

/* ===============================
   UPDATE TASK SECTION (DRAG)
================================ */
router.post('/update-task-section', (req, res) => {
  const { id, section } = req.body;
  con.query("UPDATE tasks SET section=? WHERE id=?", [section, id], (err) => {
      if (err) return res.status(500).json({ success: false });
      req.io.emit('task_section_changed', { id, section });
      res.json({ success: true });
  });
});

/* ===============================
   DELETE TASK
================================ */
router.post('/delete-task/:id', (req, res) => {
  const { id } = req.params;
  con.query("DELETE FROM tasks WHERE id = ?", [id], (err, result) => {
    if (err) return res.status(500).json({ success: false });
    req.io.emit('task_deleted', id);
    return res.status(200).json({ success: true });
  });
});

/* ===============================
   DELETE COMPLETED TASKS
================================ */
router.post('/api/delete-completed-tasks', async (req, res) => {
  try {
    const role = req.session.role;
    const adminId = req.session.adminId;
    const userId = req.session.userId;

    if (!role) return res.status(401).json({ success: false, message: 'Unauthorized' });

    let query = '';
    let params = [];

    if (role === 'admin') {
      query = "DELETE FROM tasks WHERE admin_id = ? AND assigned_to = 0 AND status = 'COMPLETED'";
      params = [adminId];
    } else if (role === 'user') {
      query = "DELETE FROM tasks WHERE admin_id = ? AND assigned_to = ? AND status = 'COMPLETED'";
      params = [adminId, userId];
    } else {
      return res.status(403).json({ success: false, message: 'Forbidden' });
    }

    const [result] = await db.query(query, params);

    if (result.affectedRows > 0) {
      req.io.emit('completed_deleted');
    }

    return res.json({
      success: result.affectedRows > 0,
      message: result.affectedRows > 0 ? 'Completed tasks deleted successfully' : 'No completed tasks found to delete'
    });

  } catch (err) {
    console.error('Error deleting completed tasks:', err);
    return res.status(500).json({ success: false, message: 'Server error' });
  }
});

module.exports = router;