const express = require('express');
const router = express.Router();
const con = require('../config/db'); // mysql2 pool
const multer = require('multer');
const path = require('path');


// ================= MULTER CONFIG =================

// storage location
const storage = multer.diskStorage({
    destination: function (req, file, cb) {
        cb(null, 'public/uploads'); // folder must exist
    },
    filename: function (req, file, cb) {
        const uniqueName = Date.now() + path.extname(file.originalname);
        cb(null, uniqueName);
    }
});

const upload = multer({ storage: storage });


// ================= ADD MEMBER ROUTE =================

router.post('/', upload.single('profile_pic'), async (req, res) => {
    try {

        // ---------- SESSION VALUES ----------
        const admin_id = req.session.adminId || null;
        const role = req.session.role; // "admin" or "user"
        const userId = req.session.userId || null;

        // ---------- FORM VALUES ----------
        const role_id = req.body.role_id;
        const name = req.body.name;
        const email = req.body.email;
        const phone = req.body.phone;
        const password = req.body.password;

        // ---------- PROFILE PIC ----------
        let profile_pic = null;
        if (req.file) {
            profile_pic =  req.file.filename;
        }

        // =====================================================
        // 🔥 ROLE BASED INSERT (ADDED ONLY THIS PART)
        // =====================================================

        if (role === "admin") {

            // ===== INSERT INTO USERS =====
            const sql = `
                INSERT INTO users
                (admin_id, role_id, name, email, phone, password, profile_pic, created_by, status, created_at)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, 'ACTIVE', NOW())
            `;

            const values = [
                admin_id,
                role_id,
                name,
                email,
                phone,
                password,
                profile_pic,
                admin_id
            ];

            await con.execute(sql, values);

            console.log("User inserted directly by admin");

        } else if (role === "user") {

            // ---------- REQUESTED_BY LOGIC ----------
            let requested_by = userId;

            // ===== INSERT INTO MEMBER REQUESTS =====
            const sql = `
                INSERT INTO member_requests
                (admin_id, role_id, requested_by, name, email, phone, password, profile_pic, created_by, status, created_at)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 'PENDING', NOW())
            `;

            const values = [
                admin_id,
                role_id,
                requested_by,
                name,
                email,
                phone,
                password,
                profile_pic,
                role
            ];

            await con.execute(sql, values);

            console.log("Member request inserted by user");
        }

        // =====================================================

        res.redirect('/view_member');

    } catch (err) {
        console.error("Insert Error:", err);
        res.status(500).send("Database Insert Error");
    }
});

module.exports = router;
