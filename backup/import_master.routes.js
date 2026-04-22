
const express = require("express");
const router = express.Router();
const multer = require("multer");
const fs = require("fs");
const mysql = require("mysql2");
const path = require("path");
const nodemailer = require("nodemailer");
const { debugLog } = require("../utils/logger");

const upload = multer({ dest: "uploads/" });

// ✅ MAIL CONFIG
const transporter = nodemailer.createTransport({
    service: "gmail",
    auth: {
        user: "social.designs.live@gmail.com",
        pass: "ipka xjqi uach zrpc"
    }
});

// ================= SEND OTP =================
router.post("/import/send-otp", (req, res) => {
    const otp = Math.floor(100000 + Math.random() * 900000);

    req.session.importOTP = otp;
    req.session.importVerified = false;

    req.session.save(async (err) => {
        if (err) {
            console.error("Session save error:", err);
            return res.json({ success: false });
        }

        try {
           await transporter.sendMail({
    from: "social.designs.live@gmail.com",
    to: "jay13981398@gmail.com",    //thedesigns.live@gmail.com
    subject: "🔐 Secure Database Import OTP",
    
    html: `
    <div style="font-family: Arial, sans-serif; background:#f4f6f8; padding:20px;">
        
        <div style="max-width:500px; margin:auto; background:#ffffff; border-radius:10px; overflow:hidden; box-shadow:0 5px 20px rgba(0,0,0,0.1);">
            
            <!-- HEADER -->
            <div style="background:#00d1b2; padding:20px; text-align:center; color:white;">
                <h2 style="margin:0;">🔐 TMS Security Alert</h2>
                <p style="margin:5px 0 0;">Database Import Verification</p>
            </div>

            <!-- BODY -->
            <div style="padding:25px; text-align:center;">
                
                <p style="color:#555; font-size:14px;">
                    You requested to import a database. Use the OTP below to continue:
                </p>

                <!-- OTP BOX -->
                <div style="
                    margin:20px auto;
                    padding:15px;
                    font-size:28px;
                    font-weight:bold;
                    letter-spacing:6px;
                    color:#00d1b2;
                    border:2px dashed #00d1b2;
                    border-radius:10px;
                    width:fit-content;
                    background:#f9fefe;
                ">
                    ${otp}
                </div>

                <p style="color:#888; font-size:12px;">
                    This OTP is valid for a short time. Do not share it with anyone.
                </p>

            </div>

            <!-- FOOTER -->
            <div style="background:#f1f1f1; padding:12px; text-align:center; font-size:12px; color:#777;">
                © ${new Date().getFullYear()} TMS System | Secure Access
            </div>

        </div>

    </div>
    `
});

            debugLog("OTP SENT:", otp); // debug

            res.json({ success: true });

        } catch (mailErr) {
            console.error("Mail error:", mailErr);
            res.json({ success: false });
        }
    });
});

// ================= VERIFY OTP =================
router.post("/import/verify-otp", (req, res) => {
    const { otp } = req.body;

    debugLog("Entered OTP:", otp);
    debugLog("Session OTP:", req.session.importOTP);
    debugLog("Session ID:", req.sessionID);

    if (!req.session.importOTP) {
        return res.json({
            success: false,
            message: "Session expired. Resend OTP"
        });
    }

    if (parseInt(otp) === req.session.importOTP) {
        req.session.importVerified = true;

        // 🔥 IMPORTANT: destroy OTP after use
        req.session.importOTP = null;

        return res.json({ success: true });
    }

    return res.json({
        success: false,
        message: "Invalid OTP"
    });
});

// ================= IMPORT SQL =================
router.post("/import/upload", upload.single("file"), (req, res) => {
    try {
        if (!req.session.importVerified) {
            return res.json({ success: false, message: "OTP not verified" });
        }

        const filePath = req.file.path;
        const sql = fs.readFileSync(filePath, "utf8");

        if (!sql.trim()) {
            return res.json({ success: false, message: "Empty file" });
        }

        const connection = mysql.createConnection({
            host: process.env.DB_HOST,
            user: process.env.DB_USER,
            password: process.env.DB_PASS,
            database: process.env.DB_NAME,
            multipleStatements: true
        });

        connection.query(sql, (err) => {
            if (err) {
                console.error(err);
                return res.json({ success: false });
            }

            fs.unlinkSync(filePath);

            req.session.importVerified = false; // reset

            res.json({ success: true });
        });

    } catch (err) {
        console.error(err);
        res.json({ success: false });
    }
});


module.exports = router;
