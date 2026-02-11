const express = require('express');
const router = express.Router();
const con = require('../config/db'); // your MySQL connection

// GET route to view all members
router.get('/view_member', async (req, res) => {
  try {
    const [users] = await con.execute("SELECT * FROM users"); // fetch all users
    res.render('view_member', { users }); // render EJS and pass users
  } catch (err) {
    console.log(err);
    res.send("Error fetching members");
  }
});

module.exports = router;
