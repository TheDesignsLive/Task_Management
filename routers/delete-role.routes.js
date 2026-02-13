const express = require('express');
const router = express.Router();
const con = require('../config/db'); // mysql2 promise pool

// DELETE ROLE
router.get('/delete-role/:id', async (req, res) => {
  try {
    const roleId = req.params.id;

    if (!roleId) {
      return res.send("Role ID missing");
    }

    // OPTIONAL: prevent delete if role is used by users
    const [used] = await con.execute(
      "SELECT id FROM users WHERE role_id = ? LIMIT 1",
      [roleId]
    );

    if (used.length > 0) {
      return res.send("Cannot delete: Role is assigned to users");
    }

    // DELETE ROLE
    await con.execute("DELETE FROM roles WHERE id = ?", [roleId]);

    res.redirect('/view-roles');

  } catch (err) {
    console.error(err);
    res.send("Error deleting role");
  }
});

module.exports = router;
