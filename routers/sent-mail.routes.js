//sent-mail.routes.js
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
            pass: "ipka xjqi uach zrpc" // Use App Password for Gmail
        }
    });
    
    let mailOptions = null;

    // if sent_for is "forget_password", use this subject and text
    if(sent_for == "forget_password"){
        mailOptions = {
            from: 'social.designs.live@gmail.com',
            to: contact,
            subject: "Your OTP for Password Reset",
            text: `Your OTP for Password Reset is ${otp}. If you didn't request this, please ignore this email.`,
            html: `
            <div style="font-family: 'Segoe UI', Arial, sans-serif; max-width: 500px; margin: 0 auto; border: 1px solid #eee; padding: 20px; border-radius: 10px;">
                <h2 style="color: #095959; text-align: center;">Password Reset Request</h2>
                
                <p style="font-size: 15px; color: #555; text-align: center; font-style: italic; margin-bottom: 25px;">
                    "Secure access to streamline your workflow and master your productivity."
                </p>

                <p style="font-size: 16px; color: #333;">We received a request to reset the password for your account. To proceed, please use the following One-Time Password (OTP):</p>
                
                <div style="background-color: #f4fdfd; border: 2px dashed #095959; padding: 20px; text-align: center; margin: 20px 0;">
                    <span style="font-size: 32px; font-weight: bold; letter-spacing: 5px; color: #095959;">${otp}</span>
                </div>
                
                <p style="font-size: 13px; color: #777; text-align: center;">
                    This code is valid for 10 minutes. <br>
                    If you didn't request a password reset, please ignore this email. Your account is safe.
                </p>
                <hr style="border: none; border-top: 1px solid #eee; margin-top: 20px;">
                <p style="font-size: 12px; color: #aaa; text-align: center;">© 2026 [Your Company Name]. All rights reserved.</p>
            </div>
        `
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
            text: `Your OTP for Email Change is ${otp}. If you didn't request this, please ignore this email.`,
            html: `
            <div style="font-family: 'Segoe UI', Arial, sans-serif; max-width: 500px; margin: 0 auto; border: 1px solid #eee; padding: 20px; border-radius: 10px;">
                <h2 style="color: #095959; text-align: center;">Email Address Update</h2>
                
                <p style="font-size: 15px; color: #555; text-align: center; font-style: italic; margin-bottom: 25px;">
                    "Keeping your contact information secure and up to date."
                </p>

                <p style="font-size: 16px; color: #333;">You have requested to change or verify the email address associated with your account. Please use the following One-Time Password (OTP) to confirm this change:</p>
                
                <div style="background-color: #f4fdfd; border: 2px dashed #095959; padding: 20px; text-align: center; margin: 20px 0;">
                    <span style="font-size: 32px; font-weight: bold; letter-spacing: 5px; color: #095959;">${otp}</span>
                </div>
                
                <p style="font-size: 13px; color: #777; text-align: center;">
                    This code is valid for 10 minutes. <br>
                    If you didn't request an email change, please ignore this message. Your current email remains active.
                </p>
                <hr style="border: none; border-top: 1px solid #eee; margin-top: 20px;">
                <p style="font-size: 12px; color: #aaa; text-align: center;">© 2026 [Your Company Name]. All rights reserved.</p>
            </div>
        `
        };
    }
    if (sent_for == "change_password") {
    mailOptions = {
        from: 'social.designs.live@gmail.com',
        to: contact,
        subject: "Security Alert: OTP to Change Password",
        text: `Your OTP for changing your password is ${otp}. If you didn't request this, please secure your account.`,
        html: `
        <div style="font-family: 'Segoe UI', Arial, sans-serif; max-width: 500px; margin: 0 auto; border: 1px solid #eee; padding: 20px; border-radius: 10px;">
            <h2 style="color: #095959; text-align: center;">Password Change Verification</h2>
            <p style="font-size: 15px; color: #555; text-align: center; font-style: italic; margin-bottom: 25px;">
                "Verifying your identity to keep your account credentials safe."
            </p>
            <p style="font-size: 16px; color: #333;">To finalize your new password, please enter the following One-Time Password (OTP):</p>
            <div style="background-color: #fef9f9; border: 2px dashed #095959; padding: 20px; text-align: center; margin: 20px 0;">
                <span style="font-size: 32px; font-weight: bold; letter-spacing: 5px; color: #095959;">${otp}</span>
            </div>
            <p style="font-size: 13px; color: #777; text-align: center;">
                If you did not authorize this change, please ignore this email and contact support immediately.
            </p>
            <hr style="border: none; border-top: 1px solid #eee; margin-top: 20px;">
            <p style="font-size: 12px; color: #aaa; text-align: center;">© 2026 [Your Company Name]. All rights reserved.</p>
        </div>`
    };
}   

if (sent_for == "delete_profile") {
        mailOptions = {
            from: 'social.designs.live@gmail.com',
            to: contact,
            subject: "CRITICAL: OTP to Delete Your Profile",
            text: `Your OTP for deleting your profile is ${otp}. This action is permanent.`,
            html: `
            <div style="font-family: 'Segoe UI', Arial, sans-serif; max-width: 500px; margin: 0 auto; border: 1px solid #eee; padding: 20px; border-radius: 10px; border-top: 5px solid #d9534f;">
                <h2 style="color: #d9534f; text-align: center;">Account Deletion Request</h2>
                <p style="font-size: 16px; color: #333;">You have requested to <strong>permanently delete</strong> your profile and all associated data. This action cannot be undone.</p>
                <div style="background-color: #fff5f5; border: 2px dashed #d9534f; padding: 20px; text-align: center; margin: 20px 0;">
                    <span style="font-size: 32px; font-weight: bold; letter-spacing: 5px; color: #d9534f;">${otp}</span>
                </div>
                <p style="font-size: 13px; color: #777; text-align: center;">
                    If you did not request this, your account may be compromised. Please change your password immediately.
                </p>
                <hr style="border: none; border-top: 1px solid #eee; margin-top: 20px;">
                <p style="font-size: 12px; color: #aaa; text-align: center;">© 2026 [Your Company Name]. All rights reserved.</p>
            </div>`
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