// import_master.routes.js
// REPLACE YOUR ENTIRE import_master.routes.js WITH THIS FILE
const express = require("express");
const router = express.Router();
const multer = require("multer");
const fs = require("fs");
const db = require("../config/db.js");
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


    //     auth: {
    //     user: "gmfruitshalvad@gmail.com",
    //     pass: "vtlo fwhe bijl xdlx"
    // }

    


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
            const [rows] = await db.query('SELECT email FROM master_auth LIMIT 1');
            if (!rows.length) return res.json({ success: false, message: "Master email not configured" });
            const masterEmail = rows[0].email;

            await transporter.sendMail({
                from: "social.designs.live@gmail.com",
                    //   from: "gmfruitshalvad@gmail.com",
                to: masterEmail,
                subject: "🔐 Secure Database Import OTP",
                html: `
                <div style="font-family: Arial, sans-serif; background:#f4f6f8; padding:20px;">
                    <div style="max-width:500px; margin:auto; background:#ffffff; border-radius:10px; overflow:hidden; box-shadow:0 5px 20px rgba(0,0,0,0.1);">
                        <div style="background:#00d1b2; padding:20px; text-align:center; color:white;">
                            <h2 style="margin:0;">🔐 TMS Security Alert</h2>
                            <p style="margin:5px 0 0;">Database Import Verification</p>
                        </div>
                        <div style="padding:25px; text-align:center;">
                            <p style="color:#555; font-size:14px;">You requested to import a database. Use the OTP below to continue:</p>
                            <div style="margin:20px auto; padding:15px; font-size:28px; font-weight:bold; letter-spacing:6px; color:#00d1b2; border:2px dashed #00d1b2; border-radius:10px; width:fit-content; background:#f9fefe;">
                                ${otp}
                            </div>
                            <p style="color:#888; font-size:12px;">This OTP is valid for a short time. Do not share it with anyone.</p>
                        </div>
                        <div style="background:#f1f1f1; padding:12px; text-align:center; font-size:12px; color:#777;">
                            © ${new Date().getFullYear()} TMS System | Secure Access
                        </div>
                    </div>
                </div>`
            });

            debugLog("OTP SENT:", otp);
            res.json({ success: true, email: masterEmail });

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
        return res.json({ success: false, message: "Session expired. Resend OTP" });
    }

    if (parseInt(otp) === req.session.importOTP) {
        req.session.importVerified = true;
        req.session.importOTP = null;
        return res.json({ success: true });
    }

    return res.json({ success: false, message: "Invalid OTP" });
});

// ================= IMPORT SQL =================
router.post("/import/upload", upload.single("file"), async (req, res) => {
    let filePath = null;

    try {
        if (!req.session.importVerified) {
            return res.json({ success: false, message: "OTP not verified" });
        }

        filePath = req.file.path;
        const sql = fs.readFileSync(filePath, "utf8");

        if (!sql.trim()) {
            return res.json({ success: false, message: "Empty file" });
        }

        // ✅ FIX: Split on ALL semicolons (old regex missed the last statement)
        const rawStatements = sql.split(";");

        const statements = rawStatements
            .map(s => s.trim())
            .filter(s => {
                if (!s) return false;
                // Skip blocks that are entirely comments
                const lines = s.split("\n").map(l => l.trim()).filter(l => l.length > 0);
                const allComments = lines.every(l =>
                    l.startsWith("--") || l.startsWith("#") || l.startsWith("/*") || l.startsWith("*")
                );
                return !allComments;
            });

        const connection = await db.getConnection();

        try {
            // ✅ FIX: These three lines MUST run first.
            // Without FOREIGN_KEY_CHECKS=0, any table with FK references
            // (users.role_id, tasks.user_id etc) fails silently → shows null/empty on import
            await connection.query("SET FOREIGN_KEY_CHECKS=0");
            await connection.query("SET SQL_MODE='NO_AUTO_VALUE_ON_ZERO'");
            await connection.query("SET NAMES utf8mb4");

            let successCount = 0;
            let skipCount = 0;

            for (const stmt of statements) {
                // Skip SET statements already handled above
                if (/^SET\s+(FOREIGN_KEY_CHECKS|SQL_MODE|NAMES)\s*/i.test(stmt)) {
                    continue;
                }

                // INSERT IGNORE so duplicates are skipped without crashing
                const safeStmt = stmt.replace(/^INSERT\s+INTO\s+/i, "INSERT IGNORE INTO ");

                try {
                    await connection.query(safeStmt);
                    successCount++;
                } catch (stmtErr) {
                    const preview = stmt.substring(0, 80).replace(/\n/g, " ");
                    console.warn(`[Import] Skipped: ${stmtErr.sqlMessage || stmtErr.message} | SQL: ${preview}`);
                    skipCount++;
                }
            }

            console.log(`[Import] Done. Success: ${successCount}, Skipped: ${skipCount}`);

        } finally {
            // Always re-enable FK checks
            try { await connection.query("SET FOREIGN_KEY_CHECKS=1"); } catch (_) {}
            connection.release();
        }

        try { fs.unlinkSync(filePath); } catch (_) {}
        req.session.importVerified = false;
        res.json({ success: true });

    } catch (err) {
        console.error("[Import] Fatal error:", err);
        if (filePath) { try { fs.unlinkSync(filePath); } catch (_) {} }
        res.json({ success: false, message: err.message });
    }
});

module.exports = router;
