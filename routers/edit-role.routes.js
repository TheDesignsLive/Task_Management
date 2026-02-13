const express = require('express');
const router = express.Router();   // ⭐ THIS WAS MISSING
const con = require('../config/db');


// UPDATE ROLE
router.post("/edit-role/:id", (req, res) => {
    const roleId = req.params.id;

    const role_name = req.body.role_name?.trim();
    const control_type = req.body.control_type;
    const can_manage_members = req.body.can_manage_members ? 1 : 0;

    if (!role_name || !control_type) {
        return res.send("<script>alert('All fields required'); window.location='/view-roles';</script>");
    }

    const sql = `
        UPDATE roles 
        SET role_name = ?, control_type = ?, can_manage_members = ?
        WHERE id = ?
    `;

    con.query(sql, [role_name, control_type, can_manage_members, roleId], (err) => {
        if (err) {
            console.log(err);
            return res.send("<script>alert('Database Error'); window.location='/view-roles';</script>");
        }

        res.send("<script>alert('Role updated successfully ✅'); window.location='/view-roles';</script>");
    });
});


module.exports = router;   // ⭐ ALSO REQUIRED
