const express = require('express');
const router = express.Router();
const con = require('../config/db');

// ADD CATEGORY (ROLE)
router.post('/', async (req, res) => {
  try {
     if (!req.session.role) return res.json({ success: false, message: 'Unauthorized' });
     
    const adminId = req.session.adminId;
    const { role_name, control_type } = req.body;

    await con.execute(
      `INSERT INTO roles (admin_id, role_name, control_type)
       VALUES (?, ?, ?)`,
      [adminId, role_name, control_type]
    );

    // 🔴 AUTO REFRESH FOR ALL USERS (ROLE UPDATED)
    req.io.emit('update_roles');

    res.json({ success: true, message: 'Role successfully created' });

  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false, message: 'Error creating role' });
  }
});

module.exports = router;