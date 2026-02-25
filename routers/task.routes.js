const express = require('express');
const router = express.Router();
const con = require('../config/db');

router.post('/', async (req, res) => {
  try {
     if (!req.session.role) return res.redirect('/');
     
    const { title, description, date, priority, assignedTo } = req.body;

    if (!req.session.adminId && !req.session.userId) {
      return res.status(401).send("Unauthorized");
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
      if (rows.length === 0) return res.status(400).send("User not found");
      admin_id = rows[0].admin_id;
    }

    let finalAssignedTo = assignedTo;
    if (req.session.role === 'admin' && parseInt(assignedTo) === req.session.adminId) {
      finalAssignedTo = 0;
    }


    //
      // ===============================
          // ✅ CHANGE STARTS HERE
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

    // Return simple success
    res.send("success");
  } catch (err) {
    console.error(err);
    res.status(500).send("Error adding task");
  }
});



module.exports = router;
