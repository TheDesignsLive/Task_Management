const express = require('express');
const router = express.Router();
const con = require('../config/db');

// VIEW ROLES PAGE
router.get('/', async (req, res) => {
  try {
    const adminId = req.session.adminId;

    if (!adminId) {
      return res.redirect('/'); // not logged in
    }

    // fetch roles of this admin
    const [roles] = await con.execute(
      'SELECT * FROM roles WHERE admin_id = ? ORDER BY id DESC',
      [adminId]
    );

    res.render('view_role', { roles });

  } catch (err) {
    console.error('View Roles Error:', err);
    res.send('Error loading roles');
  }
});

module.exports = router;
