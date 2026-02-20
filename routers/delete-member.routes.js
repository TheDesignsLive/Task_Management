const express = require('express');
const router = express.Router();
const con = require('../config/db'); // mysql2 promise pool


// DELETE MEMBER (because HTML uses <a href="/delete-member/:id"> -> GET)
router.get('/delete-member/:id', async (req, res) => {

  try {
     if (!req.session.role) return res.redirect('/');
    const memberId = req.params.id;


    // delete from users table (change table if needed)
    await con.execute('DELETE FROM users WHERE id = ?', [memberId]);

    // redirect back to members page
    res.redirect('/view_member');

  } catch (error) {
    console.error('Delete Error:', error);
    res.send('Delete failed');
  }
});

module.exports = router;
