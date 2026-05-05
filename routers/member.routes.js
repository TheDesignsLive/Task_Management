const express = require('express');
const router = express.Router();
const con = require('../config/db');
const multer = require('multer');
const path = require('path');
const bcrypt = require('bcryptjs');
const { debugLog } = require('../utils/logger');
const { notifyMobile } = require('../utils/notifyMobile'); // ✅ ADD THIS

// Multer Config
const storage = multer.diskStorage({
    destination: (req, file, cb) => cb(null, 'public/images'), 
    filename: (req, file, cb) => cb(null, Date.now() + path.extname(file.originalname))
});
const fileFilter = (req, file, cb) => {
    const allowedTypes = /jpeg|jpg|png|gif|webp/;
    const extname = allowedTypes.test(path.extname(file.originalname).toLowerCase());
    const mimetype = allowedTypes.test(file.mimetype);
    if (extname && mimetype) return cb(null, true);
    cb(new Error('Only images are allowed'));
};
const upload = multer({ storage, fileFilter }).single('profile_pic');

// 1. ADD MEMBER
// ================= ADD MEMBER =================
router.post('/add-member', (req, res) => {
    upload(req, res, async (err) => {
        if (err) return res.json({ success: false, message: err.message });

        let controlType = null;

        try {
            if (!req.session.role) {
                return res.json({ success: false, message: 'Unauthorized' });
            }

            const { role_id, name, email, phone, password } = req.body;
            if (!email || !name || !role_id || !password) {
                return res.json({ success: false, message: 'All required fields must be filled' });
            }
            const admin_id = req.session.adminId;
            const userId = req.session.userId;

            // ✅ Email check
            const [emailCheck] = await con.execute(
                "SELECT id FROM users WHERE email=? UNION SELECT id FROM member_requests WHERE email=?",
                [email, email]
            );

            if (emailCheck.length > 0) {
                return res.json({ success: false, message: 'Email already exists' });
            }

            const profile_pic = req.file ? req.file.filename : null;
            const hashedPassword = await bcrypt.hash(password, 10);

            // ================= ADMIN =================
            if (req.session.role === "admin") {

                await con.execute(
                    `INSERT INTO users 
                    (admin_id, role_id, name, email, phone, password, profile_pic, created_by, status, created_at) 
                    VALUES (?, ?, ?, ?, ?, ?, ?, ?, 'ACTIVE', NOW())`,
                    [admin_id, role_id, name, email, phone, hashedPassword, profile_pic, admin_id]
                );
                debugLog('Admin added a new member', { adminId: admin_id, newMemberEmail: email, roleId: role_id });
            }

            // ================= USER =================
            else {

                // 🔥 BEST: use session (faster)
          controlType = req.session.control_type;

                // fallback (if not stored in session)
                if (!controlType) {
                    const [roleData] = await con.execute(
                        "SELECT control_type FROM roles WHERE id=?",
                        [req.session.role_id]
                    );
                    controlType = roleData.length > 0 ? roleData[0].control_type : null;
                }

                // ✅ OWNER or ADMIN → direct insert
                if (controlType === "OWNER") {

                    await con.execute(
                        `INSERT INTO users 
                        (admin_id, role_id, name, email, phone, password, profile_pic, created_by, status, created_at) 
                        VALUES (?, ?, ?, ?, ?, ?, ?, ?, 'ACTIVE', NOW())`,
                        [admin_id, role_id, name, email, phone, hashedPassword, profile_pic, userId]
                    );
                    debugLog('Owner added a new member', { ownerId: userId, newMemberEmail: email, roleId: role_id });
                }

                // ✅ PARTIAL → request
                else {

                    await con.execute(
                        `INSERT INTO member_requests 
                        (admin_id, role_id, requested_by, name, email, phone, password, profile_pic, status, created_at) 
                        VALUES (?, ?, ?, ?, ?, ?, ?, ?, 'PENDING', NOW())`,
                        [admin_id, role_id, userId, name, email, phone, hashedPassword, profile_pic]
                    );
                    debugLog('User requested to add a new member', { requestedBy: userId, newMemberEmail: email });

                    // 🔔 notify admin
                    req.io.emit("member_request");
                }
            }

            req.io.emit('update_members');
                 notifyMobile('members'); // ✅ PUSH TO MOBILE

       return res.json({
    success: true,
    message:
        (req.session.role === "admin")
            ? "Member successfully added"
            : (controlType === "OWNER"
                ? "Member successfully added"
                : "Request sent to admin")
});

        } catch (err) {
            console.error(err);
            res.status(500).json({ success: false, message: 'Database Error' });
        }
    });
});
// 2. EDIT MEMBER
router.post('/edit-member/:id', (req, res) => {
    upload(req, res, async (err) => {
        if (err) return res.json({ success: false, message: err.message });
        try {
            if (!req.session.role) return res.json({ success: false, message: 'Unauthorized' });
            const id = req.params.id;
            const { role_id, name, email, phone, password } = req.body;
            const hashedPassword = password ? await bcrypt.hash(password, 10) : null;

            let sql, values;
            if (req.file) {
                const profile_pic = req.file.filename;
                sql = password ? `UPDATE users SET role_id=?, name=?, email=?, phone=?, password=?, profile_pic=? WHERE id=?` : `UPDATE users SET role_id=?, name=?, email=?, phone=?, profile_pic=? WHERE id=?`;
                values = password ? [role_id, name, email, phone, hashedPassword, profile_pic, id] : [role_id, name, email, phone, profile_pic, id];
            } else {
                sql = password ? `UPDATE users SET role_id=?, name=?, email=?, phone=?, password=? WHERE id=?` : `UPDATE users SET role_id=?, name=?, email=?, phone=? WHERE id=?`;
                values = password ? [role_id, name, email, phone, hashedPassword, id] : [role_id, name, email, phone, id];
            }
            await con.query(sql, values);
            debugLog('Member details updated', { memberId: id, updatedByRole: req.session.role });

            // --- ZERO RELOAD NAME UPDATE EMIT ---
            req.io.emit('update_session_name', { userId: id, newName: name });
            
            req.io.emit('update_members');
               notifyMobile('members'); // ✅ PUSH TO MOBILE
            res.json({ success: true, message: 'Member updated successfully' });
        } catch (dbErr) {
            res.status(500).json({ success: false, message: 'Database Error' });
        }
    });
});

// 3. DELETE/SUSPEND ACTIONS
// ================= DELETE MEMBER =================
router.get('/delete-member/:id', async (req, res) => {
    try {
        if (!req.session.role) return res.json({ success: false, message: 'Unauthorized' });
        const memberId = req.params.id;

        if (req.session.role === 'admin' || req.session.role === 'owner') {
            await con.execute('DELETE FROM users WHERE id = ?', [memberId]);
            debugLog('Member deleted directly', { deletedMemberId: memberId, deletedByRole: req.session.role });
            req.io.emit('force_logout', memberId);
        } else {
            const [memberData] = await con.execute('SELECT * FROM users WHERE id = ?', [memberId]);
            if (memberData.length === 0) return res.json({ success: false, message: 'Member not found' });
            const m = memberData[0];
            await con.execute(
                `INSERT INTO member_requests (admin_id, role_id, request_type, requested_by, name, email, phone, profile_pic, status, created_at) VALUES (?, ?, 'DELETE', ?, ?, ?, ?, ?, 'PENDING', NOW())`,
                [m.admin_id, m.role_id, req.session.userId, m.name, m.email, m.phone, m.profile_pic]
            );
            debugLog('Member deletion requested', { targetMemberId: memberId, requestedBy: req.session.userId });
            req.io.emit('member_request');
            // ❌ REMOVE notifyMobile from here
        }

        req.io.emit('update_members');
        notifyMobile('members'); // ✅ CORRECT — outside the if/else, always runs
        res.json({ success: true, message: 'Operation successful' });

    } catch (error) {
        res.status(500).json({ success: false, message: 'Operation failed' });
    }
});

router.get('/suspend-member/:id', async (req, res) => {
    try {
        if (!req.session.role) return res.json({ success: false, message: 'Unauthorized' });
        const userId = req.params.id;
        const [rows] = await con.query("SELECT status FROM users WHERE id = ?", [userId]);
        if (rows.length === 0) return res.json({ success: false, message: 'User not found' });
        
const newStatus = rows[0].status === "ACTIVE" ? "INACTIVE" : "ACTIVE";
        await con.query("UPDATE users SET status = ? WHERE id = ?", [newStatus, userId]);
        debugLog(`Member status changed to ${newStatus}`, { targetMemberId: userId, changedByRole: req.session.role });
        // Force logout if suspended
        if (newStatus === "INACTIVE") {
            req.io.emit('force_logout', userId);
        }
        
        req.io.emit('update_members');
        notifyMobile('members'); // ✅ PUSH TO MOBILE
        const msg = newStatus === 'ACTIVE' ? 'Member activated successfully' : 'Member suspended successfully';
        res.json({ success: true, message: msg, newStatus });
    } catch (err) {
        res.status(500).json({ success: false, message: 'Database error' });
    }
});



module.exports = router;
