const express = require('express');
const router = express.Router();
const con = require('../config/db');
const multer = require('multer');
const fs = require('fs');
const session = require('express-session');


// ================= FILE UPLOAD =================
const storage = multer.diskStorage({
    destination: (req, file, cb) => cb(null, 'public/uploads'),
    filename: (req, file, cb) => cb(null, Date.now() + "_" + file.originalname)
});
const upload = multer({ storage });


// ================= PROFILE PAGE =================
router.get('/', async (req, res) => {
    
    let r="user";
    if(req.session.role=="admin"){
        r="admin";
    }
    if (!req.session.role) return res.redirect('/');

    let show_sidebar = "Usersidebar";
    let members = [];
    let adminName = null;
    let adminId = null;
    let profilePic = null;

    let name="", email="", phone="", company="", role="";

    try {

        // ================= ADMIN =================
        if (req.session.role === "admin") {

            show_sidebar = "sidebar";
            adminId = req.session.adminId;
            role = "Admin";

            const [mRows] = await con.query(
                "SELECT id, name FROM users WHERE admin_id=? AND status='ACTIVE'",
                [adminId]
            );
            members = mRows;

            const [aRows] = await con.query(
                "SELECT name,email,phone,company_name,profile_pic FROM admins WHERE id=?",
                [adminId]
            );

            if (aRows.length) {
                adminName = aRows[0].name;
                name = aRows[0].name;
                email = aRows[0].email;
                phone = aRows[0].phone;
                company = aRows[0].company_name;
                profilePic = aRows[0].profile_pic;
            }
        }

        // ================= USER =================
        else {

            role = "User";

            const [uRows] = await con.query(
                "SELECT name,email,phone,profile_pic,role_id,admin_id FROM users WHERE id=?",
                [req.session.userId]
            );

            if (uRows.length) {

                name = uRows[0].name;
                email = uRows[0].email;
                phone = uRows[0].phone;
                profilePic = uRows[0].profile_pic;

                const [cRows] = await con.query(
                    "SELECT company_name FROM admins WHERE id=?",
                    [uRows[0].admin_id]
                );
                if (cRows.length) company = cRows[0].company_name;

                const [rRows] = await con.query(
                    "SELECT can_manage_members FROM roles WHERE id=?",
                    [uRows[0].role_id]
                );

                if (rRows.length && rRows[0].can_manage_members == 1)
                    show_sidebar = "sidebar";
            }
        }

        res.render('profile', {
            members,
            adminName,
            show_sidebar,
            profilePic,
            session: req.session,
            name,
            email,
            phone,
            company,
            r,
            role
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

                const [old] = await con.query(
                    "SELECT profile_pic FROM admins WHERE id=?",
                    [req.session.adminId]
                );

                if (old.length && old[0].profile_pic) {
                    const path = "public/uploads/" + old[0].profile_pic;
                    if (fs.existsSync(path)) fs.unlinkSync(path);
                }

                await con.query(
                    "UPDATE admins SET name=?,email=?,phone=?,company_name=?,profile_pic=? WHERE id=?",
                    [name, email, phone, company, newPic, req.session.adminId]
                );

            } else {
                await con.query(
                    "UPDATE admins SET name=?,email=?,phone=?,company_name=? WHERE id=?",
                    [name, email, phone, company, req.session.adminId]
                );
            }
        }

        else {

            if (newPic) {

                const [old] = await con.query(
                    "SELECT profile_pic FROM users WHERE id=?",
                    [req.session.userId]
                );

                if (old.length && old[0].profile_pic) {
                    const path = "public/uploads/" + old[0].profile_pic;
                    if (fs.existsSync(path)) fs.unlinkSync(path);
                }

                await con.query(
                    "UPDATE users SET name=?,email=?,phone=?,profile_pic=? WHERE id=?",
                    [name, email, phone, newPic, req.session.userId]
                );

            } else {
                await con.query(
                    "UPDATE users SET name=?,email=?,phone=? WHERE id=?",
                    [name, email, phone, req.session.userId]
                );
            }
        }

        req.session.email = email;
        res.redirect('/profile');

    } catch (err) {
        console.error(err);
        res.send("Profile update failed");
    }
});

module.exports = router;