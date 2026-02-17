const express = require('express');
const router = express.Router();
const nodemailer = require('nodemailer');

router.post("/forgot-password/send-otp", async (req, res) => {
    const { contact, otp } = req.body;

    // Create transporter (use your email credentials)
    let transporter = nodemailer.createTransport({
        service: "gmail",
        auth: {
            user: "jay13981398@gmail.com",
            pass: "yjoy emfi hkuq ncuj" // Use App Password for Gmail
        }
    });

    // Email options
    let mailOptions = {
        from: 'jay13981398@gmail.com',
        to: contact,
        subject: "Your OTP for Password Reset",
        text: `Your OTP is ${otp}`
    };

    try {
        await transporter.sendMail(mailOptions);
        res.json({ status: "sent" });
    } catch (err) {
        console.error(err);
        res.status(500).json({ status: "error", message: "Failed to send OTP" });
    }
});

module.exports = router;
