const express = require('express');
const router = express.Router();
const con = require('../config/db');   // promise pool

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
       
       // 🔴 AUTO REFRESH FOR ALL USERS (ROLE UPDATED)
       req.io.emit('update_roles');

       res.json({ success: true, message: 'Role successfully updated' });

    } catch (err) {
        console.log(err);
        res.status(500).json({ success: false, message: 'Database Error' });
    }
});

module.exports = router;