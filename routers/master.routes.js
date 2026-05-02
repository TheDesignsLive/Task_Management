const express = require('express');
const router = express.Router();
const con = require('../config/db');
const db = require('../config/db');
const { notifyMobile } = require('../utils/notifyMobile');

// ==============================
// ADD TASK
// ==============================
router.post('/add-task', async (req, res) => {
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
      const [rows] = await con.execute("SELECT admin_id FROM users WHERE id=?", [req.session.userId]);
      if (rows.length === 0) return res.status(400).json({ success: false, message: 'User not found' });
      admin_id = rows[0].admin_id;
    }

    let finalAssignedTo = assignedTo;
    if (req.session.role === 'admin') {
      if (parseInt(assignedTo) === req.session.adminId) finalAssignedTo = 0;
    } else if (req.session.role === 'user' || req.session.role === 'owner') {
      if (assignedTo === 'admin' || parseInt(assignedTo) === admin_id) finalAssignedTo = 0;
    }

    const finalDate = date || new Date().toISOString().slice(0, 10) + " 00:00:00";

    let sectionValue = 'TASK';
    if (req.session.role === 'admin' && parseInt(finalAssignedTo) !== 0) sectionValue = 'OTHERS';
    if (req.session.role !== 'admin' && parseInt(finalAssignedTo) !== parseInt(req.session.userId)) sectionValue = 'OTHERS';

    // HANDLE TEAM ASSIGNMENT
    if (typeof assignedTo === "string" && assignedTo.startsWith("team_")) {
      const teamId = assignedTo.split("_")[1];

      const [users] = await con.execute(`
        SELECT u.id 
        FROM users u
        JOIN roles r ON u.role_id = r.id
        WHERE r.team_id = ?
      `, [teamId]);

      for (let user of users) {
        await con.execute(
          `INSERT INTO tasks
          (admin_id, title, description, priority, due_date, assigned_to, assigned_by, who_assigned, section, status)
          VALUES (?, ?, ?, ?, ?, ?, ?, ?, 'OTHERS', 'OPEN')`,
          [admin_id, title || 'No Title', description || null,
           (priority || 'LOW').toUpperCase(), finalDate, user.id, assigned_by, who_assigned]
        );
      }

      req.io.emit('update_tasks');
      notifyMobile();
      return res.json({ success: true });
    }

    // HANDLE "ALL MEMBERS"
    if (assignedTo === "all") {
      const [users] = await con.execute("SELECT id FROM users WHERE admin_id=?", [admin_id]);

      for (let user of users) {
        if ((req.session.role === 'admin' && user.id === req.session.adminId) ||
            (req.session.role !== 'admin' && user.id === req.session.userId)) continue;

        try {
          await con.execute(
            `INSERT INTO tasks
            (admin_id, title, description, priority, due_date, assigned_to, assigned_by, who_assigned, section, status)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, 'OTHERS', 'OPEN')`,
            [admin_id, title || 'No Title', description || null,
             (priority || 'LOW').toUpperCase(), finalDate, user.id, assigned_by, who_assigned]
          );
        } catch (err) {
          console.error(`Failed to insert task for user ${user.id}:`, err);
        }
      }

      try {
        await con.execute(
          `INSERT INTO tasks
          (admin_id, title, description, priority, due_date, assigned_to, assigned_by, who_assigned, section, status)
          VALUES (?, ?, ?, ?, ?, 0, ?, ?, 'OTHERS', 'OPEN')`,
          [admin_id, title || 'No Title', description || null,
           (priority || 'LOW').toUpperCase(), finalDate, assigned_by, who_assigned]
        );
      } catch (err) {
        console.error('Failed to insert task for admin:', err);
      }

      req.io.emit('update_tasks');
      notifyMobile();
      return res.json({ success: true, message: 'Task added successfully' });
    }

    // NORMAL INSERT
    await con.execute(
      `INSERT INTO tasks
       (admin_id, title, description, priority, due_date, assigned_to, assigned_by, who_assigned, section, status)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 'OPEN')`,
      [admin_id, title || 'No Title', description || null,
       (priority || 'LOW').toUpperCase(), finalDate, finalAssignedTo, assigned_by, who_assigned, sectionValue]
    );

    req.io.emit('update_tasks');
    notifyMobile();
    res.json({ success: true, message: 'Task added successfully' });

  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false, message: 'Error adding task' });
  }
});

// ==============================
// UPDATE TASK STATUS
// ==============================
router.post('/update-task-status', async (req, res) => {
  if (!req.session.role) return res.redirect('/');

  try {
    let { id, status, section } = req.body;
    if (!status || status === null) status = 'OPEN';
    if (!section || section === null) section = 'TASK';

    await db.execute(
      `UPDATE tasks SET status = ?, section = ? WHERE id = ?`,
      [status, section, id]
    );

    req.io.emit('update_tasks');
    notifyMobile();
    res.json({ success: true, status, section });
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false, error: 'Database error' });
  }
});

// ==============================
// UPDATE TASK DATE
// ==============================
router.post('/update-task-date', async (req, res) => {
  const { id, due_date } = req.body;

  if (!id || !due_date) return res.json({ success: false });

  try {
    await con.execute("UPDATE tasks SET due_date = ? WHERE id = ?", [due_date, id]);
    req.io.emit('update_tasks');
    notifyMobile();
    res.json({ success: true });
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false });
  }
});

// ==============================
// GET SINGLE TASK (FOR EDIT)
// ==============================
router.get('/get-task/:id', (req, res) => {
  const { id } = req.params;

  con.query(
    `SELECT id, title, description, priority, DATE_FORMAT(due_date, '%Y-%m-%d') AS due_date 
     FROM tasks WHERE id = ?`,
    [id],
    (err, result) => {
      if (err) return res.status(500).json({ success: false });
      if (result.length === 0) return res.json({ success: false });
      res.json({ success: true, task: result[0] });
    }
  );
});

// ==============================
// EDIT TASK DETAILS
// ==============================
router.post('/edit-task-details', async (req, res) => {
  if (!req.session.role) return res.status(401).json({ success: false, error: "Unauthorized" });

  try {
    const { id, title, description, priority, due_date, assigned_to } = req.body;

    let finalAssignedTo = assigned_to;
    if (req.session.role === 'admin') {
      if (parseInt(assigned_to) === req.session.adminId) finalAssignedTo = 0;
    } else if (req.session.role === 'user' || req.session.role === 'owner') {
      if (assigned_to === 'admin' || parseInt(assigned_to) === req.session.adminId) finalAssignedTo = 0;
    }

    let newSection = 'TASK';
    if (req.session.role === 'admin' && parseInt(finalAssignedTo) !== 0) newSection = 'OTHERS';
    if (req.session.role !== 'admin' && parseInt(finalAssignedTo) !== parseInt(req.session.userId)) newSection = 'OTHERS';

    const finalDesc = (description === "" || description === null) ? null : description;

    await db.execute(
      `UPDATE tasks 
       SET title = ?, description = ?, priority = ?, due_date = ?, assigned_to = ?, section = IF(status='COMPLETED', section, ?) 
       WHERE id = ?`,
      [title, finalDesc, priority.toUpperCase(), due_date, finalAssignedTo, newSection, id]
    );

    req.io.emit('update_tasks');
    notifyMobile();
    res.json({ success: true });
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false, error: 'Database error' });
  }
});

// ==============================
// UPDATE FULL TASK DETAILS
// ==============================
router.post('/update-task-details', async (req, res) => {
  const { id, title, description, priority, due_date, assigned_to } = req.body;

  let finalAssignedTo = assigned_to;
  if (req.session.role === 'admin') {
    if (parseInt(assigned_to) === req.session.adminId) finalAssignedTo = 0;
  } else if (req.session.role === 'user' || req.session.role === 'owner') {
    if (assigned_to === 'admin' || parseInt(assigned_to) === req.session.adminId) finalAssignedTo = 0;
  }

  let newSection = 'TASK';
  if (req.session.role === 'admin' && parseInt(finalAssignedTo) !== 0) newSection = 'OTHERS';
  if (req.session.role !== 'admin' && parseInt(finalAssignedTo) !== parseInt(req.session.userId)) newSection = 'OTHERS';

  try {
    await con.execute(
      "UPDATE tasks SET title=?, description=?, priority=?, due_date=?, assigned_to=?, section=IF(status='COMPLETED', section, ?) WHERE id=?",
      [title, description, priority, due_date || null, finalAssignedTo, newSection, id]
    );
    req.io.emit('update_tasks');
    notifyMobile();
    res.json({ success: true });
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false });
  }
});

// ==============================
// UPDATE TASK SECTION (DRAG)
// ==============================
router.post('/update-task-section', async (req, res) => {
  const { id, section } = req.body;

  try {
    await con.execute("UPDATE tasks SET section=? WHERE id=?", [section, id]);
    req.io.emit('update_tasks');
    notifyMobile();
    res.json({ success: true });
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false });
  }
});

// ==============================
// DELETE SINGLE TASK
// ==============================
router.post('/delete-task/:id', async (req, res) => {
  try {
    await con.execute("DELETE FROM tasks WHERE id = ?", [req.params.id]);
    req.io.emit('update_tasks');
    notifyMobile();
    res.status(200).json({ success: true });
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false });
  }
});

// ==============================
// DELETE COMPLETED TASKS
// ==============================
router.post('/delete-completed-tasks', async (req, res) => {
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
    } else if (role === 'user' || role === 'owner') {
      query = "DELETE FROM tasks WHERE admin_id = ? AND assigned_to = ? AND status = 'COMPLETED'";
      params = [adminId, userId];
    } else {
      return res.status(403).json({ success: false, message: 'Forbidden: Invalid role' });
    }

    const [result] = await db.query(query, params);

    if (result.affectedRows > 0) {
      req.io.emit('update_tasks');
      notifyMobile();
    }

    return res.json({
      success: result.affectedRows > 0,
      message: result.affectedRows > 0
        ? 'Completed tasks deleted successfully'
        : 'No completed tasks found to delete'
    });

  } catch (err) {
    console.error('Error deleting completed tasks:', err);
    return res.status(500).json({ success: false, message: 'Server error', error: err.message });
  }
});

// ==============================
// GET TEAM MEMBERS
// ==============================
router.get('/get-team-members/:teamId', async (req, res) => {
  try {
    const { teamId } = req.params;
    const currentUserId = req.session.userId || null;

    let query = `
      SELECT u.id, u.name 
      FROM users u
      JOIN roles r ON u.role_id = r.id
      WHERE r.team_id = ?
    `;
    let params = [teamId];

    if (currentUserId) {
      query += " AND u.id != ?";
      params.push(currentUserId);
    }

    const [rows] = await con.execute(query, params);
    res.json({ success: true, members: rows });

  } catch (err) {
    console.error(err);
    res.json({ success: false });
  }
});

// ==============================
// GET OTHER EMPLOYEES (team_id NULL)
// ==============================
router.get('/get-other-employees', async (req, res) => {
  try {
    const adminId = req.session.adminId;

    const [rows] = await con.execute(`
      SELECT u.id, u.name
      FROM users u
      JOIN roles r ON u.role_id = r.id
      WHERE u.admin_id = ?
      AND r.team_id IS NULL
    `, [adminId]);

    res.json({ success: true, members: rows });

  } catch (err) {
    console.error(err);
    res.json({ success: false });
  }
});

module.exports = router;