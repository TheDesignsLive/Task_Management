const express = require('express');
const router = express.Router();
const con = require('../config/db');

router.post('/add-task', async (req, res) => {
  try {

    console.log("BODY DATA:", req.body);

    const { title, description, date, priority, assignedTo } = req.body;

    if (!req.session.role) {
      return res.status(401).send("Unauthorized");
    }

    if (!title?.trim() || !priority?.trim() || !assignedTo) {
      return res.status(400).send("Required fields missing");
    }

    let admin_id;
    let assigned_by;
    let who_assigned;
    let assigned_to_type;

    // ================= ADMIN LOGIN =================
    if (req.session.role === 'admin') {

      admin_id = req.session.adminId;
      assigned_by = req.session.adminId;
      who_assigned = 'admin';

      // If admin selected himself
      if (parseInt(assignedTo) === parseInt(req.session.adminId)) {
        assigned_to_type = 'admin';
      } else {
        assigned_to_type = 'user';
      }
    }

    // ================= USER LOGIN =================
    else {

      assigned_by = req.session.userId;
      who_assigned = 'user';

      const [rows] = await con.execute(
        "SELECT admin_id FROM users WHERE id=?",
        [req.session.userId]
      );

      if (rows.length === 0) {
        return res.status(400).send("User not found");
      }

      admin_id = rows[0].admin_id;

      // If user selected himself
      if (parseInt(assignedTo) === parseInt(req.session.userId)) {
        assigned_to_type = 'user';
      } else {
        assigned_to_type = 'admin';
      }
    }

    await con.execute(
      `INSERT INTO tasks
      (admin_id, title, description, priority, due_date,
       assigned_to, assigned_to_type,
       assigned_by, who_assigned,
       section, status)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 'TASK', 'OPEN')`,
      [
        admin_id,
        title.trim(),
        description || null,
        priority.toUpperCase(),
        date || null,
        assignedTo,
        assigned_to_type,
        assigned_by,
        who_assigned
      ]
    );

    res.send("Task added successfully");

  } catch (err) {
    console.error("TASK ERROR:", err);
    res.status(500).send("Error adding task");
  }
});

module.exports = router;
