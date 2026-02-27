const express = require('express');
const router = express.Router();
const con = require('../config/db');
const multer = require('multer');
const fs = require('fs');

// ================= FILE UPLOAD =================
const storage = multer.diskStorage({
    destination: (req, file, cb) => cb(null, 'public/images'),
    filename: (req, file, cb) => cb(null, Date.now() + "_" + file.originalname)
});
const upload = multer({ storage });

// ================= PROFILE PAGE =================
router.get('/', async (req, res) => {
    if (!req.session.role) return res.redirect('/');

    let r = req.session.role === "admin" ? "admin" : "user";
    let members = [];
    let adminName = null;
    let adminId = null;
    let profilePic = null;
    let name = "", email = "", phone = "", company = "", role = "", userRoleName = "";

    try {
        if (req.session.role === "admin") {
            adminId = req.session.adminId;
            role = "Admin";

            const [mRows] = await con.query("SELECT id, name FROM users WHERE admin_id=? AND status='ACTIVE'", [adminId]);
            members = mRows;

            const [aRows] = await con.query("SELECT name,email,phone,company_name,profile_pic FROM admins WHERE id=?", [adminId]);
            if (aRows.length) {
                adminName = aRows[0].name;
                name = aRows[0].name;
                email = aRows[0].email;
                phone = aRows[0].phone;
                company = aRows[0].company_name;
                profilePic = aRows[0].profile_pic;
            }
        } else {
            role = "User";
            // Updated to get Role Name
            const [uRows] = await con.query(
                `SELECT u.name, u.email, u.phone, u.profile_pic, u.admin_id, r.role_name 
                 FROM users u 
                 LEFT JOIN roles r ON u.role_id = r.id 
                 WHERE u.id=?`, 
                [req.session.userId]
            );

            if (uRows.length) {
                name = uRows[0].name;
                email = uRows[0].email;
                phone = uRows[0].phone;
                profilePic = uRows[0].profile_pic;
                userRoleName = uRows[0].role_name; // This is the Role Name

                const [cRows] = await con.query("SELECT company_name FROM admins WHERE id=?", [uRows[0].admin_id]);
                if (cRows.length) company = cRows[0].company_name;
            }
        }

        res.render('profile', {
            members,
            adminName,
            profilePic,
            session: req.session,
            name,
            email,
            phone,
            company,
            r,
            role,
            userRoleName // New variable
        });

    } catch (err) {
        console.error(err);
        res.send("Error loading profile");
    }
});

// ================= UPDATE PROFILE =================
router.post('/update-profile', upload.single('profile_pic'), async (req, res) => {
    if (!req.session.role) return res.redirect('/');
    const { name, email, phone, company } = req.body;
    const newPic = req.file ? req.file.filename : null;

    try {
        if (req.session.role === "admin") {
            if (newPic) {
                const [old] = await con.query("SELECT profile_pic FROM admins WHERE id=?", [req.session.adminId]);
                if (old.length && old[0].profile_pic) {
                    const oldPath = "public/images/" + old[0].profile_pic;
                    if (fs.existsSync(oldPath)) fs.unlinkSync(oldPath);
                }
                await con.query("UPDATE admins SET name=?,phone=?,company_name=?,profile_pic=? WHERE id=?", [name, phone, company, newPic, req.session.adminId]);
            } else {
                await con.query("UPDATE admins SET name=?,phone=?,company_name=? WHERE id=?", [name, phone, company, req.session.adminId]);
            }
        } else {
            if (newPic) {
                const [old] = await con.query("SELECT profile_pic FROM users WHERE id=?", [req.session.userId]);
                if (old.length && old[0].profile_pic) {
                    const oldPath = "public/images/" + old[0].profile_pic;
                    if (fs.existsSync(oldPath)) fs.unlinkSync(oldPath);
                }
                await con.query("UPDATE users SET name=?,phone=?,profile_pic=? WHERE id=?", [name, phone, newPic, req.session.userId]);
            } else {
                await con.query("UPDATE users SET name=?,phone=? WHERE id=?", [name, phone, req.session.userId]);
            }
        }
        res.redirect('/profile');
    } catch (err) {
        console.error(err);
        res.send("Profile update failed");
    }
});

module.exports = router;