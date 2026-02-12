const express = require('express');
const router = express.Router();
const con = require('../config/db'); // DB connection

router.post('/add-task', async (req, res) => {
  try {
    const { title, description, date, priority, assignedTo } = req.body;

    if (!req.session.adminId && !req.session.userId) {
      return res.status(401).send("Unauthorized");
    }

    const assigned_by = req.session.role === 'admin' 
                        ? req.session.adminId 
                        : req.session.userId;

    const admin_id = req.session.role === 'admin'
                     ? req.session.adminId
                     : req.session.adminId; // for user

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
