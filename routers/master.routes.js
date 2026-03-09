const express = require('express');
const router = express.Router();
const con = require('../config/db');
const db = require('../config/db');

router.post('/add-task', async (req, res) => {
  try {
     if (!req.session.role) return res.json({ success: false, message: 'Unauthorized' });
     
    const { title, description, date, priority, assignedTo } = req.body;

    if (!req.session.adminId && !req.session.userId) {
      return res.status(401).json({ success: false, message: 'Unauthorized' });
    }

    const assigned_by = req.session.role === 'admin' 
                        ? req.session.adminId 
                        : req.session.userId;
    const who_assigned = req.session.role;

    let admin_id;
    if (req.session.role === 'admin') {
      admin_id = req.session.adminId;
    } else {
      const [rows] = await con.execute(
        "SELECT admin_id FROM users WHERE id=?",
        [req.session.userId]
      );
      if (rows.length === 0) return res.status(400).json({ success: false, message: 'User not found' });
      admin_id = rows[0].admin_id;
    }

    let finalAssignedTo = assignedTo;
    if (req.session.role === 'admin' && parseInt(assignedTo) === req.session.adminId) {
      finalAssignedTo = 0;
    }


    //
      // ===============================
          //  CHANGE STARTS HERE
          // If date is null → insert system today date
          // Format: YYYY-MM-DD 00:00:00
          // ===============================

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
          //
    await con.execute(
      `INSERT INTO tasks 
       (admin_id, title, description, priority, due_date, assigned_to, assigned_by, who_assigned, section, status) 
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, 'TASK', 'OPEN')`,
      [
        admin_id,
        title,
        description || null,
        priority.toUpperCase(),
        finalDate,
        finalAssignedTo,
        assigned_by,
        who_assigned
      ]
    );
         // 🔴 AUTO REFRESH FOR ALL USERS (ROLE UPDATED)
    req.io.emit('update_tasks');
    // Return simple JSON success
    res.json({ success: true, message: 'Task added successfully' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false, message: 'Error adding task' });
  }
});



module.exports = router;


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
  // 🔴 AUTO REFRESH FOR ALL USERS (ROLE UPDATED)
    req.io.emit('update_tasks');
        //  Send back updated status and section so frontend can update tasks array
        res.json({ success: true, status, section });
    } catch (err) {
        console.error(err);
        res.status(500).json({ success: false, error: 'Database error' });
    }
});

module.exports = router;


// POST /update-task-details
router.post('/edit-task-details', async (req, res) => {
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
             // 🔴 AUTO REFRESH FOR ALL USERS (ROLE UPDATED)
    req.io.emit('update_tasks');

        res.json({ success: true });
    } catch (err) {
        console.error(err);
        res.status(500).json({ success: false, error: 'Database error' });
    }
});



module.exports = router;

router.post('/update-task-date', (req, res) => {
    const { id, due_date } = req.body;

    if (!id || !due_date) {
        return res.json({ success: false });
    }

    const sql = "UPDATE tasks SET due_date = ? WHERE id = ?";
    con.query(sql, [due_date, id], (err, result) => {
        if (err) {
            console.log(err);
            return res.json({ success: false });
        }
          // 🔴 AUTO REFRESH FOR ALL USERS (ROLE UPDATED)
    req.io.emit('update_tasks');
        res.json({ success: true });
    });
});

module.exports = router;


/* ===============================
   GET SINGLE TASK (FOR EDIT)
================================ */
router.get('/get-task/:id', (req, res) => {
  const { id } = req.params;

  con.query(
    `SELECT 
      id, 
      title, 
      description, 
      priority, 
      DATE_FORMAT(due_date, '%Y-%m-%d') AS due_date 
     FROM tasks 
     WHERE id = ?`,
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

  con.query(
    "UPDATE tasks SET title=?, description=?, priority=?, due_date=? WHERE id=?",
    [title, description, priority, due_date || null, id],
    (err) => {
      if (err) return res.status(500).json({ success: false });
        // 🔴 AUTO REFRESH (TASK DETAILS UPDATED)
      req.io.emit('update_tasks');
      res.json({ success: true });
    }
  );
});

/* ===============================
   UPDATE ONLY DATE
================================ */
router.post('/update-task-date', (req, res) => {
  const { id, due_date } = req.body;

  con.query(
    "UPDATE tasks SET due_date=? WHERE id=?",
    [due_date || null, id],
    (err) => {
      if (err) return res.status(500).json({ success: false });
        // 🔴 AUTO REFRESH (TASK DETAILS UPDATED)
      req.io.emit('update_tasks');
      res.json({ success: true });
    }
  );
});



/* ===============================
   UPDATE TASK STATUS
================================ */
router.post('/update-task-status', (req, res) => {
  const { id, status, section } = req.body;

  con.query(
    "UPDATE tasks SET status=?, section=? WHERE id=?",
    [status, section, id],
    (err) => {
      if (err) return res.status(500).json({ success: false });
        // 🔴 AUTO REFRESH (TASK DETAILS UPDATED)
      req.io.emit('update_tasks');
      res.json({ success: true });
    }
  );
});

/* ===============================
   UPDATE TASK SECTION (DRAG)
================================ */
router.post('/update-task-section', (req, res) => {
  const { id, section } = req.body;

  con.query(
    "UPDATE tasks SET section=? WHERE id=?",
    [section, id],
    (err) => {
      if (err) return res.status(500).json({ success: false });
        // 🔴 AUTO REFRESH (TASK DETAILS UPDATED)
      req.io.emit('update_tasks');
      res.json({ success: true });
    }
  );
});

module.exports = router;



/* ===============================
   DELETE TASK
================================ */
router.post('/delete-task/:id', (req, res) => {
  const { id } = req.params;

  con.query("DELETE FROM tasks WHERE id = ?", [id], (err, result) => {
    if (err) {
      console.error(err);
      return res.status(500).json({ success: false });
    }
          // 🔴 AUTO REFRESH FOR ALL USERS (TASK DELETED)
    req.io.emit('update_tasks');
    return res.status(200).json({ success: true });
  });
});

module.exports = router;


router.post('/delete-completed-tasks', async (req, res) => {
  try {
    // Get role and IDs from session
    const role = req.session.role;
    const adminId = req.session.adminId;
    const userId = req.session.userId;

    if (!role) {
  
      return res.status(401).json({ success: false, message: 'Unauthorized' });
    }

    let query = '';
    let params = [];

    if (role === 'admin') {
      // Admin deletes tasks assigned to nobody (assigned_to = 0)
      query = "DELETE FROM tasks WHERE admin_id = ? AND assigned_to = 0 AND status = 'COMPLETED'";
      params = [adminId];
    } else if (role === 'user') {
      // User deletes only their own tasks
      query = "DELETE FROM tasks WHERE admin_id = ? AND assigned_to = ? AND status = 'COMPLETED'";
      params = [adminId, userId];
    } else {
      return res.status(403).json({ success: false, message: 'Forbidden: Invalid role' });
    }

    const [result] = await db.query(query, params);



    console.log("Delete result:", result);


    // 🔴 AUTO REFRESH FOR ALL USERS (COMPLETED TASKS DELETED)
    if (result.affectedRows > 0) {
      req.io.emit('update_tasks');
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

module.exports = router;