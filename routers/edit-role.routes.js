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
        const can_manage_members = req.body.can_manage_members ? 1 : 0;

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
            SET role_name = ?, control_type = ?, can_manage_members = ?
            WHERE id = ?
        `;

       await con.query(sql, [role_name, control_type, can_manage_members, roleId]);

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
