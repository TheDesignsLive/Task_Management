const express = require('express');
const router = express.Router();
const con = require('../config/db');

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
      res.json({ success: true });
    }
  );
});

module.exports = router;