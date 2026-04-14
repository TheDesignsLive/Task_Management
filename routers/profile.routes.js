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

const upload = multer({ 
    storage,
    limits: { fileSize: 5 * 1024 * 1024 }, // 5MB limit
    fileFilter: (req, file, cb) => {
        const allowedTypes = /jpeg|jpg|png|webp/;
        const ext = allowedTypes.test(file.originalname.toLowerCase());
        const mime = allowedTypes.test(file.mimetype);
        if (ext && mime) {
            cb(null, true);
        } else {
            cb(new Error("Only JPG, JPEG, PNG, WEBP images are allowed"));
        }
    }
});

// ================= PROFILE PAGE =================
router.get('/', async (req, res) => {
    if (!req.session.role) return res.redirect('/');

    let members = []; 
    let adminName = null;
    let profilePic = null;
    let name = "", email = "", phone = "", company = "", role = "", userRoleName = "";
    
    let adminId = req.session.adminId;
    const sessionRole = req.session.role;
    const sessionUserId = req.session.userId;

    try {
        const [aRows] = await con.query("SELECT name FROM admins WHERE id=?", [adminId]);
        if (aRows.length > 0) adminName = aRows[0].name;

        if (sessionRole === "admin") {
            const [mRows] = await con.query(
                "SELECT id, name FROM users WHERE admin_id=? AND status='ACTIVE'", 
                [adminId]
            );
            members = mRows;
        } else {
            const [mRows] = await con.query(
                "SELECT id, name FROM users WHERE admin_id=? AND status='ACTIVE' AND id != ?", 
                [adminId, sessionUserId]
            );
            members = mRows;
        }

        if (sessionRole === "admin") {
            role = "Admin";
            const [profileRows] = await con.query("SELECT name,email,phone,company_name,profile_pic FROM admins WHERE id=?", [adminId]);
            if (profileRows.length) {
                name = profileRows[0].name;
                email = profileRows[0].email;
                phone = profileRows[0].phone;
                company = profileRows[0].company_name;
                profilePic = profileRows[0].profile_pic;
            }
        } else {
            // ✅ FIX: Set role label to 'Admin' for owner, 'User' for normal user
            role = sessionRole === "owner" ? "Admin" : "User";
            const [uRows] = await con.query(
                `SELECT u.name, u.email, u.phone, u.profile_pic, u.admin_id, r.role_name 
                 FROM users u 
                 LEFT JOIN roles r ON u.role_id = r.id 
                 WHERE u.id=?`, 
                [sessionUserId]
            );

            if (uRows.length) {
                name = uRows[0].name;
                email = uRows[0].email;
                phone = uRows[0].phone;
                profilePic = uRows[0].profile_pic;
                userRoleName = uRows[0].role_name || '';
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
            role,
            userRoleName,
            activePage: "profile"
        
        });

    } catch (err) {
        console.error(err);
        res.send("Error loading profile");
    }
});

// ================= REMOVE PROFILE PICTURE =================
router.post('/remove-picture', async (req, res) => {
    if (!req.session.role) return res.status(403).json({ success: false });
    try {
        const table = req.session.role === "admin" ? "admins" : "users";
        const id = req.session.role === "admin" ? req.session.adminId : req.session.userId;

        const [rows] = await con.query(`SELECT profile_pic, name FROM ${table} WHERE id=?`, [id]);
        if (rows.length && rows[0].profile_pic) {
            const oldPath = "public/images/" + rows[0].profile_pic;
            if (fs.existsSync(oldPath)) fs.unlinkSync(oldPath);
            await con.query(`UPDATE ${table} SET profile_pic=NULL WHERE id=?`, [id]);
        }
        res.json({ success: true, name: rows[0].name });
    } catch (err) {
        console.error(err);
        res.status(500).json({ success: false });
    }
});

// ================= UPDATE PROFILE =================
router.post('/update-profile', (req, res) => {
    upload.single('profile_pic')(req, res, async function (err) {
        if (err) return res.json({ success: false, message: err.message });
        if (!req.session.role) return res.status(403).json({ success: false });

        const { name, phone, company } = req.body;
        const newPic = req.file ? req.file.filename : null;

        try {
            let currentId;
            if (req.session.role === "admin") {
                currentId = req.session.adminId;
                if (newPic) {
                    const [old] = await con.query("SELECT profile_pic FROM admins WHERE id=?", [currentId]);
                    if (old.length && old[0].profile_pic) {
                        const oldPath = "public/images/" + old[0].profile_pic;
                        if (fs.existsSync(oldPath)) fs.unlinkSync(oldPath);
                    }
                    await con.query("UPDATE admins SET name=?,phone=?,company_name=?,profile_pic=? WHERE id=?", [name, phone, company, newPic, currentId]);
                } else {
                    await con.query("UPDATE admins SET name=?,phone=?,company_name=? WHERE id=?", [name, phone, company, currentId]);
                }
                req.session.adminName = name;
            } else {
                currentId = req.session.userId;
                if (newPic) {
                    const [old] = await con.query("SELECT profile_pic FROM users WHERE id=?", [currentId]);
                    if (old.length && old[0].profile_pic) {
                        const oldPath = "public/images/" + old[0].profile_pic;
                        if (fs.existsSync(oldPath)) fs.unlinkSync(oldPath);
                    }
                    await con.query("UPDATE users SET name=?,phone=?,profile_pic=? WHERE id=?", [name, phone, newPic, currentId]);
                } else {
                    await con.query("UPDATE users SET name=?,phone=? WHERE id=?", [name, phone, currentId]);
                }
                req.session.userName = name;

                // ✅ FIX: If owner, also update the company name in the admins table
                if (req.session.role === "owner" && company !== undefined) {
                    await con.query("UPDATE admins SET company_name=? WHERE id=?", [company, req.session.adminId]);
                }
            }

            req.io.emit('update_session_name', { userId: currentId, adminId: req.session.adminId, newName: name });
            req.io.emit('update_profiles', { userId: currentId, name, phone, company, profilePic: newPic });

            return res.json({ success: true, name, phone, company, profilePic: newPic });
        } catch (err) {
            console.error(err);
            return res.status(500).json({ success: false, message: "Profile update failed" });
        }
    });
});

module.exports = router;