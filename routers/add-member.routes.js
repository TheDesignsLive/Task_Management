const express = require('express');
const router = express.Router();
const con = require('../config/db');
const multer = require('multer');
const path = require('path');
const bcrypt = require('bcryptjs');

const storage = multer.diskStorage({
    destination: (req, file, cb) => cb(null, 'public/images'), // Updated folder location
    filename: (req, file, cb) => cb(null, Date.now() + path.extname(file.originalname))
});

const fileFilter = (req, file, cb) => {
    const allowedTypes = /jpeg|jpg|png|gif|webp/;
    const extname = allowedTypes.test(path.extname(file.originalname).toLowerCase());
    const mimetype = allowedTypes.test(file.mimetype);
    if (extname && mimetype) return cb(null, true);
    cb(new Error('Only images are allowed (jpeg, jpg, png, gif, webp)'));
};

const upload = multer({ storage, fileFilter }).single('profile_pic');

router.post('/', (req, res) => {
    // 🔥 Handle upload manually to catch the error
    upload(req, res, async (err) => {
        if (err) {
            // Show alert instead of error page
            return res.send(`<script>alert('${err.message}'); window.location=document.referrer;</script>`);
        }

        try {
            if (!req.session.role) return res.redirect('/');

            const { role_id, name, email, phone, password } = req.body;
            const admin_id = req.session.adminId;

            const [emailCheck] = await con.execute(
                "SELECT id FROM users WHERE email=? UNION SELECT id FROM member_requests WHERE email=?",
                [email, email]
            );

            if (emailCheck.length > 0) {
                return res.send("<script>alert('Email already exists'); window.location=document.referrer;</script>");
            }

            const profile_pic = req.file ? req.file.filename : null;
            const hashedPassword = await bcrypt.hash(password, 10);

            if (req.session.role === "admin") {
                await con.execute(
                    "INSERT INTO users (admin_id, role_id, name, email, phone, password, profile_pic, created_by, status, created_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, 'ACTIVE', NOW())",
                    [admin_id, role_id, name, email, phone, hashedPassword, profile_pic, admin_id]
                );

                                // 🔴 AUTO REFRESH FOR ALL USERS
                req.io.emit('update_members');


                 return res.send("<script>alert('Member successfully added'); window.location=document.referrer;</script>");
            } else {
                await con.execute(
                    "INSERT INTO member_requests (admin_id, role_id, requested_by, name, email, phone, password, profile_pic, created_by, status, created_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 'PENDING', NOW())",
                    [admin_id, role_id, req.session.userId, name, email, phone, hashedPassword, profile_pic, req.session.role]
                );

                // 🔴 AUTO REFRESH FOR ALL USERS
                req.io.emit('update_members');
                 return res.send("<script>alert('Request successfully sent'); window.location=document.referrer;</script>");
            }
            res.redirect('/view_member');
        } catch (dbErr) {
            console.error(dbErr);
            res.status(500).send("<script>alert('Database Error'); window.location=document.referrer;</script>");
        }
    });
});

module.exports = router;
