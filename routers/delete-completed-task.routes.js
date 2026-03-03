

// routes/deleteCompletedTasks.js
const express = require('express');
const router = express.Router();
const db = require('../config/db'); // promise pool

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