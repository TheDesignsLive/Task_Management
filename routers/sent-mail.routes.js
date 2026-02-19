const express = require('express');
const router = express.Router();
const nodemailer = require('nodemailer');

router.post("/forgot-password/send-otp", async (req, res) => {
    const { contact, otp,sent_for } = req.body;

    // Create transporter (use your email credentials)
    let transporter = nodemailer.createTransport({
        service: "gmail",
        auth: {
            user: "school.activity.management.pro@gmail.com",
            pass: "plet rkli ycvg uwez" // Use App Password for Gmail
        }
    });
    let mailOptions=null;

    // if sent_for is "forget_password", use this subject and text

    if(sent_for=="forget_password"){

    mailOptions = {
        from: 'jay13981398@gmail.com',
        to: contact,
        subject: "Your OTP for Password Reset",
        text: `Your OTP is ${otp}`
    };
}

    // if sent_for is "signup", use this subject and text make your own way for signup send message
        if(sent_for=="signup"){

    mailOptions = {
        from: 'school.activity.management.pro@gmail.com',
        to: contact,
        subject: "Your OTP for Signup Verification",
        text: `Your OTP is ${otp}`
    };
}

    try {
        await transporter.sendMail(mailOptions);
        res.json({ status: "sent" });
    } catch (err) {
        console.error(err);
        res.status(500).json({ status: "error", message: "Failed to send OTP" });
    }
});

module.exports = router;
