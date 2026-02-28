const express = require('express');
const router = express.Router();
const con = require('../config/db');   // promise pool

// UPDATE ROLE
router.post("/edit-role/:id", async (req, res) => {
    try {
         if (!req.session.role) return res.redirect('/');
         
        const roleId = req.params.id;

        const role_name = req.body.role_name ? req.body.role_name.trim() : "";
        const control_type = req.body.control_type;
        if (!role_name || !control_type) {
            return res.send(`
                <script>
                    alert('All fields required');
                    window.location.href='/view-roles';
                </script>
            `);
        }

        const sql = `
            UPDATE roles 
            SET role_name = ?, control_type = ?
            WHERE id = ?
        `;

       await con.query(sql, [role_name, control_type, roleId]);
             // 🔴 AUTO REFRESH FOR ALL USERS (ROLE UPDATED)
    req.io.emit('update_roles');

        res.send(`
            <script>
               
                window.location.href='/view-roles';
            </script>
        `);

    } catch (err) {
        console.log(err);
        res.send(`
            <script>
                alert('Database Error');
                window.location.href='/view-roles';
            </script>
        `);
    }
});

module.exports = router;
