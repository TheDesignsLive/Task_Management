const express = require('express');
const router = express.Router();
const con = require('../config/db');

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