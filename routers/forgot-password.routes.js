const express = require('express');
const router = express.Router();
const con = require('../config/db'); // your DB connection

// Step 1: Check contact & generate OTP
router.post("/check", async (req, res) => {
  try {
    const { contact } = req.body;

    // Check in admins
    const [adminRows] = await con.query("SELECT * FROM admins WHERE email=? OR phone=?", [contact, contact]);
    // Check in users
    const [userRows] = await con.query("SELECT * FROM users WHERE email=? OR phone=?", [contact, contact]);

    if(adminRows.length === 0 && userRows.length === 0){
        return res.json({ status: "not_found" });
    }

    // Generate 6-digit OTP and store in session
    const otp = Math.floor(100000 + Math.random() * 900000);
    req.session.otp = otp;
    req.session.contact = contact;

    // Here you can send OTP via email/SMS in production
    console.log("Generated OTP:", otp); // ✅ prints OTP in server console

    return res.json({ status: "found" });
  } catch(err){
    console.error(err);
    return res.status(500).json({ status: "error", message: "Server error" });
  }
});

// Step 2: Verify OTP
router.post("/verify", (req, res) => {
    const { contact, otp } = req.body;

    if(req.session.contact !== contact){
        return res.json({ status: "error", message: "Contact mismatch" });
    }

    if(Number(otp) === req.session.otp){
        return res.json({ status: "success" });
    } else {
        return res.json({ status: "error", message: "Incorrect OTP" });
    }
});

// Step 3: Reset Password
router.post("/reset", async (req, res) => {
    const { contact, new_password } = req.body;

    try {
        // Check in admins
        let [adminRows] = await con.query("SELECT * FROM admins WHERE email=? OR phone=?", [contact, contact]);
        if(adminRows.length > 0){
            await con.query("UPDATE admins SET password=? WHERE email=? OR phone=?", [new_password, contact, contact]);
            return res.json({ status: "success" });
        }

        // Check in users
        let [userRows] = await con.query("SELECT * FROM users WHERE email=? OR phone=?", [contact, contact]);
        if(userRows.length > 0){
            await con.query("UPDATE users SET password=? WHERE email=? OR phone=?", [new_password, contact, contact]);
            return res.json({ status: "success" });
        }

        return res.json({ status: "error", message: "Contact not found" });
    } catch(err){
        console.error(err);
        return res.status(500).json({ status: "error", message: "Server error" });
    }
});

module.exports = router;
