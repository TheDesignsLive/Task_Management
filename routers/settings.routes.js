const express = require('express');
const router = express.Router();
const con = require('../config/db');

let otpStore = {}; // { key: { otp, expires, resendTime } }

// ================= PAGE LOAD =================
router.get('/', async (req, res) => {

    if (!req.session.role) return res.redirect('/');

    let show_sidebar = "Usersidebar";
    let members = [];
    let adminName = null;

    try {

        // ADMIN
        if (req.session.role === "admin") {

            show_sidebar = "sidebar";

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

        // USER
        else {

            const [uRows] = await con.query(
                "SELECT role_id,admin_id FROM users WHERE id=?",
                [req.session.userId]
            );

            if (uRows.length) {
                const [rRows] = await con.query(
                    "SELECT can_manage_members FROM roles WHERE id=?",
                    [uRows[0].role_id]
                );
                if (rRows.length && rRows[0].can_manage_members == 1)
                    show_sidebar = "sidebar";
            }
        }

        res.render('settings', {
            show_sidebar,
            members,      // ✅ FIX navbar error
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

    const { current_password, new_password, confirm_password } = req.body;
    if (new_password !== confirm_password) return res.send("<script>alert('Password mismatch'); window.location=document.referrer;</script>");

    try {

        let table = req.session.role === "admin" ? "admins" : "users";
        let id = req.session.role === "admin" ? req.session.adminId : req.session.userId;

        const [rows] = await con.query(`SELECT password FROM ${table} WHERE id=?`, [id]);

        if (!rows.length || rows[0].password !== current_password)
            return res.send("<script>alert('Wrong current password'); window.location=document.referrer;</script>");

        await con.query(`UPDATE ${table} SET password=? WHERE id=?`, [new_password, id]);

        res.send("<script>alert('Password changed successfully'); window.location='/settings';</script>");

    } catch (err) {
        console.log(err);
        res.send("<script>alert('Password change failed'); window.location=document.referrer;</script>");
    }
});


/* ================= SEND OTP ================= */

router.post('/send-otp', async (req, res) => {

    const { contact } = req.body;
    const otp = Math.floor(100000 + Math.random() * 900000);

    otpStore[contact] = {
        otp,
        expires: Date.now() + 5 * 60 * 1000,
        resendTime: Date.now() + 2 * 60 * 1000
    };

    console.log("OTP:", otp); // 🔴 show in console (use SMS/email later)
    res.send("<script>alert('OTP sent'); window.location=document.referrer;</script>");
});


/* ================= VERIFY OTP & RESET ================= */

router.post('/verify-otp', async (req, res) => {

    const { contact, otp, new_password, confirm_password } = req.body;

    if (new_password !== confirm_password)
        return res.send("<script>alert('Password mismatch'); window.location=document.referrer;</script>");

    const data = otpStore[contact];
    if (!data) return res.send("<script>alert('OTP not found'); window.location=document.referrer;</script>");

    if (Date.now() > data.expires)
        return res.send("<script>alert('OTP expired'); window.location=document.referrer;</script>");

    if (parseInt(otp) !== data.otp)
        return res.send("<script>alert('Wrong OTP'); window.location=document.referrer;</script>");

    try {

        let table = req.session.role === "admin" ? "admins" : "users";

        await con.query(
            `UPDATE ${table} SET password=? WHERE email=? OR phone=?`,
            [new_password, contact, contact]
        );

        delete otpStore[contact];
        res.send("<script>alert('Password reset successfully'); window.location='/settings';</script>");

    } catch (err) {
        console.log(err);
        res.send("<script>alert('Reset failed'); window.location=document.referrer;</script>");
    }
});


module.exports = router;