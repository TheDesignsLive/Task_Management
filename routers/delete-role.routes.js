const express = require('express');
const router = express.Router();
const con = require('../config/db'); // mysql2 promise pool

// DELETE ROLE
router.get('/delete-role/:id', async (req, res) => {
  try {
     if (!req.session.role) return res.json({ success: false, message: 'Unauthorized' });
    const roleId = req.params.id;

    if (!roleId) {
      return res.json({ success: false, message: 'Role ID missing' });
    }

    // OPTIONAL: prevent delete if role is used by users
    const [used] = await con.execute(
      "SELECT id FROM users WHERE role_id = ? LIMIT 1",
      [roleId]
    );

    if (used.length > 0) {
        return res.json({ success: false, message: 'Cannot delete: This role is currently assigned to users.' });
    }
    
    // DELETE ROLE
    await con.execute("DELETE FROM roles WHERE id = ?", [roleId]);
    
    // 🔴 AUTO REFRESH FOR ALL USERS (ROLE UPDATED)
    req.io.emit('update_roles');

    res.json({ success: true, message: 'Role deleted successfully' });

  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false, message: 'Error deleting role' });
  }
});

module.exports = router;