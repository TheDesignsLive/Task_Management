const express = require('express');
const router = express.Router();
const con = require('../config/db');

router.get('/view-roles', async (req, res) => {

    if (!req.session.role) {
        return res.redirect('/');
    }

    let members = [];
    let roles = [];
    let adminId = null;
    let adminName = null; 

    try {
        // ================= ADMIN =================
        if (req.session.role === "admin") {
            adminId = req.session.adminId;

            const [aRows] = await con.query("SELECT name FROM admins WHERE id=?", [adminId]);
            if (aRows.length > 0) adminName = aRows[0].name;

            const [mRows] = await con.query(
                "SELECT id, name FROM users WHERE admin_id=? AND status='ACTIVE'",
                [adminId]
            );
            members = mRows;

            const [rRows] = await con.query(
                "SELECT * FROM roles WHERE admin_id=? ORDER BY id ASC",
                [adminId]
            );
            roles = rRows;
        }

        // ================= USER =================
        else if (req.session.role === "user") {
            const [userRows] = await con.query(
                "SELECT role_id, admin_id FROM users WHERE id=?",
                [req.session.userId]
            );

            if (userRows.length > 0) {
                adminId = userRows[0].admin_id;

                const [aRows] = await con.query("SELECT name FROM admins WHERE id=?", [adminId]);
                if (aRows.length > 0) adminName = aRows[0].name;

                const [mRows] = await con.query(
                    "SELECT id, name FROM users WHERE admin_id=? AND status='ACTIVE' AND id!=?",
                    [adminId, req.session.userId]
                );
                members = mRows;

                const [rRows] = await con.query(
                    "SELECT * FROM roles WHERE admin_id=? ORDER BY id DESC",
                    [adminId]
                );
                roles = rRows;
            }
        }

        res.render('view_role', {
            roles,
            members,
            adminName, 
            session: req.session,
            activePage:"view_member"
        });

    } catch (err) {
        console.error(err);
        res.send("Error loading roles");
    }
});

// ADD CATEGORY (ROLE)
router.post('/add-role', async (req, res) => {
  try {
     if (!req.session.role) return res.json({ success: false, message: 'Unauthorized' });
     
    const adminId = req.session.adminId;
    const { role_name, control_type } = req.body;

    await con.execute(
      `INSERT INTO roles (admin_id, role_name, control_type)
       VALUES (?, ?, ?)`,
      [adminId, role_name, control_type]
    );

    req.io.emit('update_roles');
    res.json({ success: true, message: 'Role successfully created' });

  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false, message: 'Error creating role' });
  }
});

// UPDATE ROLE
router.post("/edit-role/:id", async (req, res) => {
    try {
         if (!req.session.role) return res.json({ success: false, message: 'Unauthorized' });
         
        const roleId = req.params.id;
        const role_name = req.body.role_name ? req.body.role_name.trim() : "";
        const control_type = req.body.control_type;
        
        if (!role_name || !control_type) {
            return res.json({ success: false, message: 'All fields required' });
        }

        const sql = `
            UPDATE roles 
            SET role_name = ?, control_type = ?
            WHERE id = ?
        `;

       await con.query(sql, [role_name, control_type, roleId]);
       
       req.io.emit('update_roles');
       res.json({ success: true, message: 'Role successfully updated' });

    } catch (err) {
        console.log(err);
        res.status(500).json({ success: false, message: 'Database Error' });
    }
});

// DELETE ROLE
router.get('/delete-role/:id', async (req, res) => {
  try {
     if (!req.session.role) return res.json({ success: false, message: 'Unauthorized' });
    const roleId = req.params.id;

    const [used] = await con.execute(
      "SELECT id FROM users WHERE role_id = ? LIMIT 1",
      [roleId]
    );

    if (used.length > 0) {
        return res.json({ success: false, message: 'Cannot delete: This role is currently assigned to users.' });
    }
    
    await con.execute("DELETE FROM roles WHERE id = ?", [roleId]);
    
    req.io.emit('update_roles');
    res.json({ success: true, message: 'Role successfully deleted' });

  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false, message: 'Error deleting role' });
  }
});

module.exports = router;