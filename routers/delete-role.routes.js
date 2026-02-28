const express = require('express');
const router = express.Router();
const con = require('../config/db'); // mysql2 promise pool

// DELETE ROLE
router.get('/delete-role/:id', async (req, res) => {
  try {
     if (!req.session.role) return res.redirect('/');
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
    return res.send(`
        <div id="customDialog" style="position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.6); display: flex; justify-content: center; align-items: center; z-index: 9999; font-family: Arial, sans-serif;">
            <div style="background: white; width: 350px; padding: 25px; border-radius: 10px; text-align: center; box-shadow: 0 10px 30px rgba(0,0,0,0.3);">
                <h3 style="margin-top: 0; color: #ed1e1e;">Action Denied</h3>
                <p style="color: #555; font-size: 15px; margin-bottom: 20px;">Cannot delete: This role is currently assigned to users.</p>
                <button onclick="window.location=document.referrer" style="width: 100%; padding: 12px; background-color: #209595; color: white; border: none; border-radius: 6px; font-weight: bold; cursor: pointer; font-size: 14px;">Okay, Back</button>
            </div>
        </div>
    `);
}
    // DELETE ROLE
    await con.execute("DELETE FROM roles WHERE id = ?", [roleId]);
         // 🔴 AUTO REFRESH FOR ALL USERS (ROLE UPDATED)
    req.io.emit('update_roles');

    res.redirect('/view-roles');

  } catch (err) {
    console.error(err);
    res.send("Error deleting role");
  }
});

module.exports = router;
