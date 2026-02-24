const express = require('express');
const router = express.Router();
const con = require('../config/db');
const bcrypt = require('bcryptjs'); // Added for encryption

// ================= PAGE LOAD =================
router.get('/', async (req, res) => {
    if (!req.session.role) return res.redirect('/');

    let members = [];
    let adminName = null;

    try {
        if (req.session.role === "admin") {
            const [mRows] = await con.query(
                "SELECT id,name FROM users WHERE admin_id=? AND status='ACTIVE'",
                [req.session.adminId]
            );
            members = mRows;

            const [aRows] = await con.query(
                "SELECT name FROM admins WHERE id=?",
                [req.session.adminId]
            );
            if (aRows.length) adminName = aRows[0].name;
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
    if (!req.session.role) return res.redirect('/');

    const { current_password, new_password, confirm_password } = req.body;

    if (new_password !== confirm_password)
        return res.send("<script>alert('Password mismatch'); window.location=document.referrer;</script>");

    try {
        let table = req.session.role === "admin" ? "admins" : "users";
        let id = req.session.role === "admin" ? req.session.adminId : req.session.userId;

        const [rows] = await con.query(`SELECT password FROM ${table} WHERE id=?`, [id]);

        if (!rows.length) return res.send("<script>alert('Account not found'); window.location=document.referrer;</script>");

        // Verify current password (assuming current password in DB is already hashed)
        const match = await bcrypt.compare(current_password, rows[0].password);
        if (!match)
            return res.send("<script>alert('Wrong current password'); window.location=document.referrer;</script>");

        // HASH THE NEW PASSWORD
        const saltRounds = 10;
        const hashedNewPassword = await bcrypt.hash(new_password, saltRounds);

        await con.query(`UPDATE ${table} SET password=? WHERE id=?`, [hashedNewPassword, id]);

        res.send("<script>alert('Password changed successfully'); window.location='/settings';</script>");

    } catch (err) {
        console.log(err);
        res.send("<script>alert('Password change failed'); window.location=document.referrer;</script>");
    }
});

/* ================= CHANGE GMAIL ================= */
router.post('/change-email', async (req, res) => {
    if (!req.session.role) return res.redirect('/');
    const { new_email } = req.body;

    try {
        let table = req.session.role === "admin" ? "admins" : "users";
        let id = req.session.role === "admin" ? req.session.adminId : req.session.userId;

        const [adminCheck] = await con.query("SELECT id FROM admins WHERE email=?", [new_email]);
        const [userCheck] = await con.query("SELECT id FROM users WHERE email=?", [new_email]);

        if (adminCheck.length > 0 || userCheck.length > 0) {
            return res.send("<script>alert('Email already in use by another account!'); window.location='/settings';</script>");
        }

        await con.query(`UPDATE ${table} SET email=? WHERE id=?`, [new_email, id]);
        req.session.email = new_email;
        res.send("<script>alert('Gmail changed successfully'); window.location='/settings';</script>");
    } catch (err) {
        console.log(err);
        res.send("<script>alert('Gmail change failed'); window.location='/settings';</script>");
    }
});

/* ================= DELETE PROFILE ================= */
router.get('/delete-profile', async (req, res) => {
    if (!req.session.role) return res.redirect('/');
    if (req.session.role !== "admin") {
        return res.send("<script>alert('You cannot delete your account.'); window.location='/settings';</script>");
    }

    try {
        let adminId = req.session.adminId;
        await con.query(`DELETE FROM admins WHERE id=?`, [adminId]);
        req.session.destroy();
        res.send("<script>alert('Account deleted successfully.'); window.location='/';</script>");
    } catch (err) {
        console.log(err);
        res.send("<script>alert('Failed to delete profile.'); window.location='/settings';</script>");
    }
});

module.exports = router;