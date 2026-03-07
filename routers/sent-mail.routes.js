const express = require('express');
const router = express.Router();
const nodemailer = require('nodemailer');

router.post("/forgot-password/send-otp", async (req, res) => {
    const { contact, otp, sent_for } = req.body;

    // Create transporter (use your email credentials)
    let transporter = nodemailer.createTransport({
        service: "gmail",
        auth: {
            user: "social.designs.live@gmail.com",
            pass: "ipka xjqi uach zrpc" 
            
        }
    });
    
    let mailOptions = null;

    // if sent_for is "forget_password", use this subject and text
    if(sent_for == "forget_password"){
        mailOptions = {
            from: 'social.designs.live@gmail.com',
            to: contact,
            subject: "Your OTP for Password Reset",
            text: `Your OTP is ${otp}`
        };
    }

    // if sent_for is "signup", use this subject and text
   if (sent_for == "signup") {
    mailOptions = {
        from: 'social.designs.live@gmail.com',
        to: contact,
        subject: "Verify your account – Welcome to [Your Brand Name]!",
        text: `Welcome! Your verification code is: ${otp}. Streamline your workflow and master your productivity with us.`,
        html: `
            <div style="font-family: 'Segoe UI', Arial, sans-serif; max-width: 500px; margin: 0 auto; border: 1px solid #eee; padding: 20px; border-radius: 10px;">
                <h2 style="color: #095959; text-align: center;">Welcome to the Team!</h2>
                
                <p style="font-size: 15px; color: #555; text-align: center; font-style: italic; margin-bottom: 25px;">
                    "Streamline your workflow, hit your deadlines, and master your productivity."
                </p>

                <p style="font-size: 16px; color: #333;">We're excited to have you on board. To complete your signup and secure your account, please use the following One-Time Password (OTP):</p>
                
                <div style="background-color: #f4fdfd; border: 2px dashed #095959; padding: 20px; text-align: center; margin: 20px 0;">
                    <span style="font-size: 32px; font-weight: bold; letter-spacing: 5px; color: #095959;">${otp}</span>
                </div>
                
                <p style="font-size: 13px; color: #777; text-align: center;">
                    This code is valid for 10 minutes. <br>
                    If you didn't request this, please ignore this email.
                </p>
                <hr style="border: none; border-top: 1px solid #eee; margin-top: 20px;">
                <p style="font-size: 12px; color: #aaa; text-align: center;">© 2026 [Your Company Name]. All rights reserved.</p>
            </div>
        `
    };
}
    // if sent_for is "change_email", use this subject and text
    if(sent_for == "change_email"){
        mailOptions = {
            from: 'social.designs.live@gmail.com',
            to: contact,
            subject: "Your OTP for Email Change",
            text: `Your OTP is ${otp}. Use this to verify your email address.`
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