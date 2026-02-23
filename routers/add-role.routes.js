const express = require('express');
const router = express.Router();
const con = require('../config/db');

// ADD CATEGORY (ROLE)
router.post('/', async (req, res) => {
  try {
     if (!req.session.role) return res.redirect('/');
     
    const adminId = req.session.adminId;
    const { role_name, control_type } = req.body;

    await con.execute(
      `INSERT INTO roles (admin_id, role_name, control_type)
       VALUES (?, ?, ?)`,
      [adminId, role_name, control_type]
    );

    res.redirect('/view-roles'); // back to pages

  } catch (err) {
    console.error(err);
    res.send("Error creating role");
  }
});

module.exports = router;
