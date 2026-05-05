// masterpanel.routes.js  ← FULL UPDATED FILE
const express = require('express');
const router = express.Router();
const con = require('../config/db');
const nodemailer = require('nodemailer');
const bcrypt = require('bcrypt');

// ─────────────────────────────────────────────
//  CONFIG
// ─────────────────────────────────────────────
const MAIL_USER     = 'social.designs.live@gmail.com';
const MAIL_PASS     = 'ipka xjqi uach zrpc';
const OTP_EXPIRY_MS = 10 * 60 * 1000; // 10 minutes

// ─────────────────────────────────────────────
//  MAILER HELPER
// ─────────────────────────────────────────────
const transporter = nodemailer.createTransport({
    service: 'gmail',
    auth: { user: MAIL_USER, pass: MAIL_PASS }
});

async function sendOTPEmail(toEmail, otp, subject = 'Master Panel OTP') {
    await transporter.sendMail({
        from: MAIL_USER,
        to: toEmail,
        subject,
        html: `
        <div style="font-family:'Segoe UI',Arial,sans-serif;max-width:500px;margin:0 auto;border:1px solid #eee;padding:24px;border-radius:12px;">
          <h2 style="color:#0F8989;text-align:center;">TMS Master Panel</h2>
          <p style="text-align:center;color:#555;font-size:15px;">Your one-time verification code:</p>
          <div style="background:#f4fdfd;border:2px dashed #0F8989;padding:22px;text-align:center;margin:20px 0;border-radius:8px;">
            <span style="font-size:36px;font-weight:bold;letter-spacing:10px;color:#0F8989;">${otp}</span>
          </div>
          <p style="font-size:13px;color:#777;text-align:center;">Valid for <strong>10 minutes</strong>. Do not share this code.</p>
          <hr style="border:none;border-top:1px solid #eee;margin-top:20px;">
          <p style="font-size:12px;color:#aaa;text-align:center;">© 2026 TMS. All rights reserved.</p>
        </div>`
    });
}

// Helper: get master email from DB
async function getMasterEmail() {
    const [rows] = await con.query('SELECT email FROM master_auth LIMIT 1');
    if (!rows.length) throw new Error('Master account not configured.');
    return rows[0].email;
}

function generateOTP() {
    return Math.floor(100000 + Math.random() * 900000).toString();
}

// ─────────────────────────────────────────────
//  MIDDLEWARE: protect master panel pages
// ─────────────────────────────────────────────
function requireMasterAuth(req, res, next) {
    if (req.session.masterAuthenticated) return next();
    return res.redirect('/master/login');
}

// ─────────────────────────────────────────────
//  GET /master/login
// ─────────────────────────────────────────────
router.get('/master/login', (req, res) => {
    // Always clear master auth on login page visit — forces fresh login every time
    req.session.masterAuthenticated = false;
    req.session.role = null;
    res.render('master_login');
});

router.get('/master/get-email', async (req, res) => {
    try {
        const email = await getMasterEmail();
        return res.json({ success: true, email });
    } catch (err) {
        return res.status(500).json({ success: false });
    }
});
// ─────────────────────────────────────────────
//  POST /master/verify-password
// ─────────────────────────────────────────────
router.post('/master/verify-password', async (req, res) => {
    const { password } = req.body;
    if (!password) return res.json({ success: false, message: 'Password required.' });

    try {
        const [rows] = await con.query('SELECT * FROM master_auth LIMIT 1');
        if (!rows.length) return res.json({ success: false, message: 'Master account not configured.' });

        const master = rows[0];
        const match  = await bcrypt.compare(password, master.password_hash);
        if (!match) return res.json({ success: false, message: 'Incorrect password.' });

        // ✅ Direct login — no OTP needed
        req.session.masterAuthenticated = true;
        req.session.role                = 'master';

        return res.json({ success: true });
    } catch (err) {
        console.error('[Master] verify-password error:', err);
        return res.status(500).json({ success: false, message: 'Server error.' });
    }
});
// ─────────────────────────────────────────────
//  POST /master/verify-otp  (login step 2)
// ─────────────────────────────────────────────
router.post('/master/verify-otp', (req, res) => {
    const { otp } = req.body;
    if (!otp) return res.json({ success: false, message: 'OTP required.' });

    if (req.session.masterOTPPurpose !== 'login') {
        return res.json({ success: false, message: 'No active login session.' });
    }
    if (Date.now() > req.session.masterOTPExpiry) {
        return res.json({ success: false, message: 'OTP expired. Please login again.' });
    }
    if (otp !== req.session.masterOTP) {
        return res.json({ success: false, message: 'Invalid OTP.' });
    }

    req.session.masterAuthenticated = true;
    req.session.masterOTP           = null;
    req.session.masterOTPExpiry     = null;
    req.session.masterOTPPurpose    = null;
    req.session.role                = 'master';

    return res.json({ success: true });
});

// ─────────────────────────────────────────────
//  POST /master/resend-otp
// ─────────────────────────────────────────────
router.post('/master/resend-otp', async (req, res) => {
    if (!req.session.masterOTPPurpose) {
        return res.json({ success: false, message: 'No active session.' });
    }
    try {
        const masterEmail = await getMasterEmail();
        const otp = generateOTP();
        req.session.masterOTP       = otp;
        req.session.masterOTPExpiry = Date.now() + OTP_EXPIRY_MS;
        await sendOTPEmail(masterEmail, otp, 'TMS Master Panel – Resend OTP');
        return res.json({ success: true });
    } catch (err) {
        return res.status(500).json({ success: false, message: 'Failed to resend.' });
    }
});

// ─────────────────────────────────────────────
//  POST /master/forgot-send-otp
// ─────────────────────────────────────────────
router.post('/master/forgot-send-otp', async (req, res) => {
    try {
        const masterEmail = await getMasterEmail();
        const otp = generateOTP();
        req.session.masterOTP        = otp;
        req.session.masterOTPExpiry  = Date.now() + OTP_EXPIRY_MS;
        req.session.masterOTPPurpose = 'forgot';
  await sendOTPEmail(masterEmail, otp, 'TMS Master Panel – Forgot Password OTP');
        return res.json({ success: true, email: masterEmail });
    } catch (err) {
        console.error('[Master] forgot-send-otp error:', err);
        return res.status(500).json({ success: false, message: 'Failed to send OTP.' });
    }
});

// ─────────────────────────────────────────────
//  POST /master/forgot-verify-otp
// ─────────────────────────────────────────────
router.post('/master/forgot-verify-otp', (req, res) => {
    const { otp } = req.body;
    if (req.session.masterOTPPurpose !== 'forgot') {
        return res.json({ success: false, message: 'No active forgot-password session.' });
    }
    if (Date.now() > req.session.masterOTPExpiry) {
        return res.json({ success: false, message: 'OTP expired.' });
    }
    if (otp !== req.session.masterOTP) {
        return res.json({ success: false, message: 'Invalid OTP.' });
    }

    req.session.masterCanReset  = true;
    req.session.masterOTP       = null;
    req.session.masterOTPExpiry = null;
    req.session.masterOTPPurpose = null;
    return res.json({ success: true });
});

// ─────────────────────────────────────────────
//  POST /master/reset-password
// ─────────────────────────────────────────────
router.post('/master/reset-password', async (req, res) => {
    if (!req.session.masterCanReset) {
        return res.json({ success: false, message: 'Not authorized to reset.' });
    }
    const { newPassword } = req.body;
    if (!newPassword || newPassword.length < 8) {
        return res.json({ success: false, message: 'Minimum 8 characters required.' });
    }
    // Validate: uppercase, lowercase, digit, special char
    const passRx = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z0-9]).{8,}$/;
    if (!passRx.test(newPassword)) {
        return res.json({ success: false, message: 'Password must have uppercase, lowercase, number and special character.' });
    }
    try {
        const hash = await bcrypt.hash(newPassword, 10);
        await con.query('UPDATE master_auth SET password_hash = ? LIMIT 1', [hash]);
        req.session.masterCanReset = false;
        return res.json({ success: true });
    } catch (err) {
        console.error('[Master] reset-password error:', err);
        return res.status(500).json({ success: false, message: 'Server error.' });
    }
});

// ─────────────────────────────────────────────
//  CHANGE EMAIL — Step 1: Send OTP to current email
//  POST /master/change-email-send-otp
// ─────────────────────────────────────────────
router.post('/master/change-email-send-otp', async (req, res) => {
    try {
        const masterEmail = await getMasterEmail();
        const otp = generateOTP();
        req.session.masterOTP               = otp;
        req.session.masterOTPExpiry         = Date.now() + OTP_EXPIRY_MS;
        req.session.masterOTPPurpose        = 'change-email-old';
        req.session.masterChangeEmailVerified = false;
        req.session.masterNewEmail          = null;

       await sendOTPEmail(masterEmail, otp, 'TMS Master Panel – Change Email Verification');
        return res.json({ success: true, email: masterEmail });
    } catch (err) {
        console.error('[Master] change-email-send-otp error:', err);
        return res.status(500).json({ success: false, message: 'Failed to send OTP.' });
    }
});

// ─────────────────────────────────────────────
//  CHANGE EMAIL — Step 2: Verify OTP from current email
//  POST /master/change-email-verify-old-otp
// ─────────────────────────────────────────────
router.post('/master/change-email-verify-old-otp', (req, res) => {
    const { otp } = req.body;
    if (req.session.masterOTPPurpose !== 'change-email-old') {
        return res.json({ success: false, message: 'No active change-email session.' });
    }
    if (Date.now() > req.session.masterOTPExpiry) {
        return res.json({ success: false, message: 'OTP expired.' });
    }
    if (otp !== req.session.masterOTP) {
        return res.json({ success: false, message: 'Invalid OTP.' });
    }

    req.session.masterChangeEmailVerified = true;
    req.session.masterOTP                 = null;
    req.session.masterOTPExpiry           = null;
    req.session.masterOTPPurpose          = null;
    return res.json({ success: true });
});

// ─────────────────────────────────────────────
//  CHANGE EMAIL — Step 3: Send OTP to new email
//  POST /master/change-email-send-new-otp
// ─────────────────────────────────────────────
router.post('/master/change-email-send-new-otp', async (req, res) => {
    if (!req.session.masterChangeEmailVerified) {
        return res.json({ success: false, message: 'Please verify current email first.' });
    }

    // On resend, use already stored new email; on first call, use body
    let newEmail = req.body.newEmail || req.session.masterNewEmail;

    if (!newEmail) {
        return res.json({ success: false, message: 'New email is required.' });
    }

    // Basic email validation
    const emailRx = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRx.test(newEmail)) {
        return res.json({ success: false, message: 'Invalid email address.' });
    }

    try {
        // Check it's not already the same email
        const [rows] = await con.query('SELECT email FROM master_auth LIMIT 1');
        if (rows.length && rows[0].email === newEmail) {
            return res.json({ success: false, message: 'New email is the same as the current email.' });
        }

        const otp = generateOTP();
        req.session.masterOTP        = otp;
        req.session.masterOTPExpiry  = Date.now() + OTP_EXPIRY_MS;
        req.session.masterOTPPurpose = 'change-email-new';
        req.session.masterNewEmail   = newEmail; // store for resend

        await sendOTPEmail(newEmail, otp, 'TMS Master Panel – Verify New Email');
        return res.json({ success: true });
    } catch (err) {
        console.error('[Master] change-email-send-new-otp error:', err);
        return res.status(500).json({ success: false, message: 'Failed to send OTP.' });
    }
});

// ─────────────────────────────────────────────
//  CHANGE EMAIL — Step 4: Verify OTP from new email & save
//  POST /master/change-email-verify-new-otp
// ─────────────────────────────────────────────
router.post('/master/change-email-verify-new-otp', async (req, res) => {
    const { otp } = req.body;

    if (req.session.masterOTPPurpose !== 'change-email-new') {
        return res.json({ success: false, message: 'No active email verification session.' });
    }
    if (!req.session.masterChangeEmailVerified) {
        return res.json({ success: false, message: 'Identity not verified.' });
    }
    if (Date.now() > req.session.masterOTPExpiry) {
        return res.json({ success: false, message: 'OTP expired.' });
    }
    if (otp !== req.session.masterOTP) {
        return res.json({ success: false, message: 'Invalid OTP.' });
    }

    const newEmail = req.session.masterNewEmail;
    if (!newEmail) {
        return res.json({ success: false, message: 'Session expired. Please start again.' });
    }

    try {
        await con.query('UPDATE master_auth SET email = ? LIMIT 1', [newEmail]);

        // Clear session change-email state
        req.session.masterOTP                 = null;
        req.session.masterOTPExpiry           = null;
        req.session.masterOTPPurpose          = null;
        req.session.masterChangeEmailVerified = false;
        req.session.masterNewEmail            = null;
        // Force re-login since email changed
        req.session.masterAuthenticated       = false;

        return res.json({ success: true });
    } catch (err) {
        console.error('[Master] change-email-verify-new-otp error:', err);
        return res.status(500).json({ success: false, message: 'Server error saving email.' });
    }
});

// ─────────────────────────────────────────────
//  GET /master/logout
// ─────────────────────────────────────────────
router.get('/master/logout', (req, res) => {
    req.session.masterAuthenticated = false;
    req.session.role = null;
    res.redirect('/master/login');
});

// ─────────────────────────────────────────────
//  MASTER PANEL HOME (protected)
// ─────────────────────────────────────────────
router.get('/masterpage', requireMasterAuth, async (req, res) => {
    // Do NOT clear auth here — impersonate routes also need it
    try {
        const [companies] = await con.query(`
            SELECT 
                a.id, 
                a.name as admin_name, 
                a.company_name, 
                a.email,
                (SELECT COUNT(*) FROM users WHERE admin_id = a.id) as total_users,
                (SELECT COUNT(*) FROM teams WHERE admin_id = a.id) as total_teams,
                (SELECT COUNT(*) FROM tasks WHERE admin_id = a.id) as total_tasks
            FROM admins a
            ORDER BY a.id DESC
        `);
        res.render('master_panel', { session: req.session, companies, activePage: 'master' });
    } catch (err) {
        console.error(err);
        res.status(500).send('Database Error loading Master Panel');
    }
});

// ─────────────────────────────────────────────
//  API: company details (protected)
// ─────────────────────────────────────────────
router.get('/masterpage/api/company-details/:id', requireMasterAuth, async (req, res) => {
    const adminId = req.params.id;
    try {
        const [users] = await con.query(`
            SELECT u.id, u.name, u.email, u.phone, u.status, r.role_name, r.control_type 
            FROM users u 
            LEFT JOIN roles r ON u.role_id = r.id 
            WHERE u.admin_id = ?
        `, [adminId]);

        const [teams] = await con.query(`
            SELECT t.id, t.name, t.created_at,
            (SELECT COUNT(*) FROM roles r JOIN users u ON u.role_id = r.id WHERE r.team_id = t.id AND u.admin_id = ?) as user_count
            FROM teams t WHERE t.admin_id = ?
        `, [adminId, adminId]);

        const [tasks] = await con.query(`
            SELECT id, title, description, priority, status, section, DATE_FORMAT(due_date,'%Y-%m-%d') as due_date
            FROM tasks WHERE admin_id = ? ORDER BY created_at DESC
        `, [adminId]);

        res.json({ success: true, users, teams, tasks });
    } catch (err) {
        console.error(err);
        res.status(500).json({ success: false });
    }
});



// ─────────────────────────────────────────────
//  DELETE COMPANY — cascade delete all data
//  DELETE /masterpage/api/delete-company/:id
// ─────────────────────────────────────────────
router.delete('/masterpage/api/delete-company/:id', requireMasterAuth, async (req, res) => {
    const adminId = req.params.id;
    if (!adminId || isNaN(adminId)) {
        return res.status(400).json({ success: false, message: 'Invalid company ID.' });
    }

    try {
        // Run all deletions in the correct FK-safe order
        // 1. announcement_seen (references announcements + users)
        await con.query(`DELETE FROM announcement_seen WHERE admin_id = ?`, [adminId]);

        // 2. announcements
        await con.query(`DELETE FROM announcements WHERE admin_id = ?`, [adminId]);

        // 3. tasks
        await con.query(`DELETE FROM tasks WHERE admin_id = ?`, [adminId]);

        // 4. member_requests
        await con.query(`DELETE FROM member_requests WHERE admin_id = ?`, [adminId]);

        // 5. users (FK to roles/teams — delete before roles & teams)
        await con.query(`DELETE FROM users WHERE admin_id = ?`, [adminId]);

        // 6. roles (FK to teams — delete before teams)
        await con.query(`DELETE FROM roles WHERE admin_id = ?`, [adminId]);

        // 7. teams
        await con.query(`DELETE FROM teams WHERE admin_id = ?`, [adminId]);

        // 8. sessions that belong to this admin
        await con.query(`DELETE FROM sessions WHERE data LIKE ?`, [`%"adminId":${adminId}%`]);

        // 9. Finally delete the admin itself
        await con.query(`DELETE FROM admins WHERE id = ?`, [adminId]);

        console.log(`[Master] ✅ Company ${adminId} and all related data deleted.`);
        return res.json({ success: true });

    } catch (err) {
        console.error('[Master] delete-company error:', err);
        return res.status(500).json({ success: false, message: 'Server error during deletion.' });
    }
});

// ─────────────────────────────────────────────
//  TOKEN-BASED IMPERSONATION (session-safe new tab)
//  POST /masterpage/impersonate-token/:id  → issues a one-time token
//  GET  /masterpage/go/:token              → redeems token, sets session, redirects
// ─────────────────────────────────────────────
const impersonateTokens = new Map(); // token → { adminId, expiresAt }

router.post('/masterpage/impersonate-token/:id', requireMasterAuth, async (req, res) => {
    try {
        const targetAdminId = req.params.id;
        const [adminData] = await con.query('SELECT name FROM admins WHERE id = ?', [targetAdminId]);
        if (!adminData.length) return res.json({ success: false, message: 'Admin not found' });

        // Generate one-time token
        const token = Math.random().toString(36).slice(2) + Date.now().toString(36);
        impersonateTokens.set(token, {
            adminId:   parseInt(targetAdminId),
            expiresAt: Date.now() + 30_000  // valid for 30 seconds only
        });

        return res.json({ success: true, url: `/masterpage/go/${token}` });
    } catch (err) {
        console.error(err);
        return res.status(500).json({ success: false });
    }
});

router.get('/masterpage/go/:token', async (req, res) => {
    const entry = impersonateTokens.get(req.params.token);

    if (!entry || Date.now() > entry.expiresAt) {
        impersonateTokens.delete(req.params.token);
        return res.send('<h2 style="font-family:sans-serif;color:#e74c3c;padding:40px">Link expired or invalid. Please go back and click View again.</h2>');
    }

    impersonateTokens.delete(req.params.token); // ✅ one-time use — delete immediately

    try {
        const adminId = entry.adminId;
        const [adminData]   = await con.query('SELECT name FROM admins WHERE id = ?', [adminId]);
        const [targetAdmin] = await con.query('SELECT email FROM admins WHERE id = ?', [adminId]);

        if (!adminData.length) return res.send('Admin not found');

        // ✅ NEW SESSION for this tab only — does NOT touch the original browser session
        // Regenerate session ID so this tab gets a completely fresh independent session
        req.session.regenerate((err) => {
            if (err) {
                console.error('Session regenerate error:', err);
                return res.status(500).send('Session error');
            }

            req.session.adminId             = adminId;
            req.session.userId              = null;
            req.session.role                = 'admin';
            req.session.control_type        = 'ADMIN';
            req.session.adminName           = adminData[0].name;
            req.session.email               = targetAdmin[0].email;
            req.session.masterAuthenticated = false;
            req.session.impersonating       = true;

            req.session.save(() => {
                res.redirect('/home');
            });
        });

    } catch (err) {
        console.error(err);
        res.status(500).send('Error opening company');
    }
});

module.exports = router;