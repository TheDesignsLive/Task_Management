const express = require('express');
const router = express.Router();
const con = require('../config/db');
const bcrypt = require('bcryptjs'); // Added for encryption

// ================= PAGE LOAD =================
router.get('/', async (req, res) => {
    if (!req.session.role) return res.redirect('/');

    let members = [];
    let adminName = null;
    let adminId = req.session.adminId;
    const sessionRole = req.session.role;
    const sessionUserId = req.session.userId;

    try {
        // Fetch Admin Name (Exactly like notification router)
        const [aRows] = await con.query("SELECT name FROM admins WHERE id=?", [adminId]);
        if (aRows.length > 0) adminName = aRows[0].name;

        // ================= NAVBAR DROPDOWN (MEMBERS) LOGIC =================
        // Exactly like notification router logic
        if (sessionRole === "admin") {
            const [mRows] = await con.query(
                "SELECT id, name FROM users WHERE admin_id=? AND status='ACTIVE'", 
                [adminId]
            );
            members = mRows;
        } else {
            const [mRows] = await con.query(
                "SELECT id, name FROM users WHERE admin_id=? AND status='ACTIVE' AND id != ?", 
                [adminId, sessionUserId]
            );
            members = mRows;
        }

        res.render('settings', {
            members,
            adminName,
            session: req.session
        });

    } catch (err) {
        console.log(err);
        res.send("<script>alert('Error loading settings'); window.location=document.referrer;</script>");
    }
});

/* ================= CHANGE PASSWORD ================= */
router.post('/change-password', async (req, res) => {
    if (!req.session.role) return res.json({ success: false, message: 'Unauthorized' });

    const { current_password, new_password, confirm_password } = req.body;

    if (new_password !== confirm_password)
        return res.json({ success: false, message: 'New passwords do not match' });

    try {
        let table = req.session.role === "admin" ? "admins" : "users";
        let id = req.session.role === "admin" ? req.session.adminId : req.session.userId;

        const [rows] = await con.query(`SELECT password FROM ${table} WHERE id=?`, [id]);

        if (!rows.length) return res.json({ success: false, message: 'Account not found' });

        // Verify current password 
        const match = await bcrypt.compare(current_password, rows[0].password);
        if (!match)
            return res.json({ success: false, message: 'Incorrect current password' });

        // HASH THE NEW PASSWORD
        const saltRounds = 10;
        const hashedNewPassword = await bcrypt.hash(new_password, saltRounds);

        await con.query(`UPDATE ${table} SET password=? WHERE id=?`, [hashedNewPassword, id]);

        res.json({ success: true, message: 'Your password has been successfully updated.' });

    } catch (err) {
        console.log(err);
        res.json({ success: false, message: 'Failed to update password due to a server error.' });
    }
});

/* ================= CHANGE GMAIL ================= */
router.post('/change-email', async (req, res) => {
    if (!req.session.role) return res.json({ success: false, message: 'Unauthorized' });
    const { new_email } = req.body;

    try {
        let table = req.session.role === "admin" ? "admins" : "users";
        let id = req.session.role === "admin" ? req.session.adminId : req.session.userId;

        const [adminCheck] = await con.query("SELECT id FROM admins WHERE email=?", [new_email]);
        const [userCheck] = await con.query("SELECT id FROM users WHERE email=?", [new_email]);

        if (adminCheck.length > 0 || userCheck.length > 0) {
            return res.json({ success: false, message: 'This email address is already registered to another account.' });
        }

        await con.query(`UPDATE ${table} SET email=? WHERE id=?`, [new_email, id]);
        req.session.email = new_email;
        
        res.json({ success: true, message: 'Your email address has been successfully updated.', newEmail: new_email });
    } catch (err) {
        console.log(err);
        res.json({ success: false, message: 'Failed to change email due to a server error.' });
    }
});

/* ================= DELETE PROFILE ================= */
router.get('/delete-profile', async (req, res) => {
    if (!req.session.role) return res.json({ success: false, message: 'Unauthorized' });
    if (req.session.role !== "admin") {
        return res.json({ success: false, message: 'Only admins can delete their profile.' });
    }

    try {
        let adminId = req.session.adminId;
        await con.query(`DELETE FROM admins WHERE id=?`, [adminId]);
        req.session.destroy();
        res.json({ success: true, message: 'Your profile and all associated data have been permanently deleted.' });
    } catch (err) {
        console.log(err);
        res.json({ success: false, message: 'Failed to delete profile due to a server error.' });
    }
});

module.exports = router;