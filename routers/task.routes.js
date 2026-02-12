const express = require('express');
const router = express.Router();
const con = require('../config/db'); // DB connection

router.post('/add-task', async (req, res) => {
  try {
    const { title, description, date, priority, assignedTo } = req.body;

    // Check session
    if (!req.session.adminId && !req.session.userId) {
      return res.status(401).send("Unauthorized");
    }

    // Determine who is adding the task
    const assigned_by = req.session.role === 'admin' 
                        ? req.session.adminId 
                        : req.session.userId;

    // Determine admin_id (owner of task)
    let admin_id;
    if (req.session.role === 'admin') {
      admin_id = req.session.adminId;
    } else {
      // For regular user, get admin_id from database
      const [rows] = await con.execute(
        "SELECT admin_id FROM users WHERE id=?",
        [req.session.userId]
      );
      if (rows.length === 0) return res.status(400).send("User not found");
      admin_id = rows[0].admin_id;
    }

    // Insert task
    await con.execute(
      `INSERT INTO tasks 
       (admin_id, title, description, priority, due_date, assigned_to, assigned_by, section, status) 
       VALUES (?, ?, ?, ?, ?, ?, ?, 'TASK', 'OPEN')`,
      [admin_id, title, description || null, priority.toUpperCase(), date || null, assignedTo, assigned_by]
    );

    res.send("Task added successfully!");
  } catch (err) {
    console.error(err);
    res.status(500).send("Error adding task");
  }
});

module.exports = router;
