const express = require('express');
const router = express.Router();
const con = require('../config/db');
const multer = require('multer');
const path = require('path');
const bcrypt = require('bcryptjs');

const storage = multer.diskStorage({
    destination: (req, file, cb) => cb(null, 'public/images/'),
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

router.post('/edit-member/:id', (req, res) => {
    upload(req, res, async (err) => {
        if (err) {
            return res.send(`<script>alert('${err.message}'); window.location=document.referrer;</script>`);
        }

        try {
            if (!req.session.role) return res.redirect('/');
            const id = req.params.id;
            const { role_id, name, email, phone, password } = req.body;

            let sql, values;
            const hashedPassword = password ? await bcrypt.hash(password, 10) : null;

            if (req.file) {
                const profile_pic = req.file.filename;
                sql = password 
                    ? `UPDATE users SET role_id=?, name=?, email=?, phone=?, password=?, profile_pic=? WHERE id=?`
                    : `UPDATE users SET role_id=?, name=?, email=?, phone=?, profile_pic=? WHERE id=?`;
                values = password ? [role_id, name, email, phone, hashedPassword, profile_pic, id] : [role_id, name, email, phone, profile_pic, id];
            } else {
                sql = password 
                    ? `UPDATE users SET role_id=?, name=?, email=?, phone=?, password=? WHERE id=?`
                    : `UPDATE users SET role_id=?, name=?, email=?, phone=? WHERE id=?`;
                values = password ? [role_id, name, email, phone, hashedPassword, id] : [role_id, name, email, phone, id];
            }

            await con.query(sql, values);
                 // 🔴 AUTO REFRESH FOR ALL USERS (ROLE UPDATED)
    req.io.emit('update_members');
            res.send("<script>window.location='/view_member';</script>");
        } catch (dbErr) {
            console.log(dbErr);
            res.send("<script>alert('Database Error'); window.location='/view_member';</script>");
        }
    });
});

module.exports = router;
