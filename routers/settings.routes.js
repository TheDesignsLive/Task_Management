const express = require('express');
const router = express.Router();
const con = require('../config/db');
const multer = require('multer');
const path = require('path');

// ================= MULTER (PROFILE PIC) ====================
const storage = multer.diskStorage({
    destination: function (req, file, cb) {
        cb(null, 'public/uploads');
    },
    filename: function (req, file, cb) {
        const uniqueName = Date.now() + path.extname(file.originalname);
        cb(null, uniqueName);
    }
});
const upload = multer({ storage: storage });

router.get('/', async (req, res) => {

    if (!req.session.role) {
        return res.redirect('/');
    }

    let show_sidebar = "Usersidebar";
    let members = [];
    let adminName = null;
    let adminId = null;
    let profile = null;

    try {

        // ================= ADMIN =================
        if (req.session.role === "admin") {

            show_sidebar = "sidebar";
            adminId = req.session.adminId;

            const [mRows] = await con.query(
                "SELECT id, name FROM users WHERE admin_id=? AND status='ACTIVE'",
                [adminId]
            );
            members = mRows;

            const [aRows] = await con.query(
                "SELECT * FROM admins WHERE id=?",
                [adminId]
            );
            if (aRows.length > 0) {
                adminName = aRows[0].name;
                profile = aRows[0];
            }
        }

        // ================= USER =================
        else if (req.session.role === "user") {

            const [uRows] = await con.query(
                "SELECT * FROM users WHERE id=?",
                [req.session.userId]
            );

            if (uRows.length > 0) {
                profile = uRows[0];
                adminId = uRows[0].admin_id;
                const roleId = uRows[0].role_id;

                const [rRows] = await con.query(
                    "SELECT can_manage_members FROM roles WHERE id=?",
                    [roleId]
                );

                if (rRows.length > 0 && rRows[0].can_manage_members == 1) {
                    show_sidebar = "sidebar";
                } else {
                    show_sidebar = "Usersidebar";
                }
            }
        }

        res.render('settings', {
            members,
            adminName,
            show_sidebar,
            session: req.session,
            profile
        });

    } catch (err) {
        console.error(err);
        res.send("Error loading settings");
    }
});


// ================= UPDATE PROFILE =================
router.post('/update-profile', upload.single("profile_pic"), async (req, res) => {

    try {

        let profilePic = null;
        if (req.file) profilePic = req.file.filename;

        if (req.session.role === "admin") {

            const { name, phone, company_name } = req.body;

            if (profilePic) {
                await con.query(
                    "UPDATE admins SET name=?, phone=?, company_name=?, profile_pic=? WHERE id=?",
                    [name, phone, company_name, profilePic, req.session.adminId]
                );
            } else {
                await con.query(
                    "UPDATE admins SET name=?, phone=?, company_name=? WHERE id=?",
                    [name, phone, company_name, req.session.adminId]
                );
            }
        }

        else if (req.session.role === "user") {

            const { name, phone } = req.body;

            if (profilePic) {
                await con.query(
                    "UPDATE users SET name=?, phone=?, profile_pic=? WHERE id=?",
                    [name, phone, profilePic, req.session.userId]
                );
            } else {
                await con.query(
                    "UPDATE users SET name=?, phone=? WHERE id=?",
                    [name, phone, req.session.userId]
                );
            }
        }

        res.redirect('/settings');

    } catch (err) {
        console.error(err);
        res.send("Profile update failed");
    }
});


// ================= CHANGE PASSWORD =================
router.post('/change-password', async (req, res) => {

    const { old_password, new_password } = req.body;

    try {

        if (req.session.role === "admin") {

            const [rows] = await con.query(
                "SELECT password FROM admins WHERE id=?",
                [req.session.adminId]
            );

            if (rows.length && rows[0].password === old_password) {
                await con.query(
                    "UPDATE admins SET password=? WHERE id=?",
                    [new_password, req.session.adminId]
                );
            }
        }

        else if (req.session.role === "user") {

            const [rows] = await con.query(
                "SELECT password FROM users WHERE id=?",
                [req.session.userId]
            );

            if (rows.length && rows[0].password === old_password) {
                await con.query(
                    "UPDATE users SET password=? WHERE id=?",
                    [new_password, req.session.userId]
                );
            }
        }

        res.redirect('/settings');

    } catch (err) {
        console.error(err);
        res.send("Password change failed");
    }
});

module.exports = router;
