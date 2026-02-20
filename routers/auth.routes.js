const express = require('express');
const router = express.Router();
const con = require('../config/db');
const session = require('express-session');
const multer = require('multer');
const path = require('path');

// ================= MULTER (PROFILE PIC) ====================
const storage = multer.diskStorage({
    destination: function (req, file, cb) {
        cb(null, 'public/uploads');   // make sure uploads folder exists
    },
    filename: function (req, file, cb) {
        const uniqueName = Date.now() + path.extname(file.originalname);
        cb(null, uniqueName);
    }
});
const upload = multer({ storage: storage });

// ================= SESSION ====================
router.use(session({
    secret: "mysecretkey",
    resave: false,
    saveUninitialized: true
}));

// ================= SIGNUP ====================
router.post("/signup", upload.single("profile_pic"), async (req, res) => {
    const { name, company_name, email, phone, password } = req.body;

    if (!name || !email || !password) {
        return res.send("Please fill all required fields ❌");
    }

    // 🔹 PROFILE PIC FILENAME
    let profilePic = null;
    if (req.file) {
        profilePic = req.file.filename;
    }

    const sql = "INSERT INTO admins (name, company_name, email, phone, password, profile_pic) VALUES (?,?,?,?,?,?)";

    try {
        const [result] = await con.query(sql, [name, company_name, email, phone, password, profilePic]);

        // ✅ STORE SESSION (SAME AS LOGIN)
        req.session.adminId = result.insertId;
        req.session.role = "admin";
        req.session.email = email;   // 🔹 ADDED (IMPORTANT)

        return res.redirect("/home");
    } catch (err) {
        if (err.code === 'ER_DUP_ENTRY') {
            res.send("Email already exists ❌");
        } else {
            console.error(err);
            res.send("Something went wrong ❌");
        }
    }
});


// check admins email exist or not in admins table

router.post("/check-email", async (req, res) => {
    const { email } = req.body;

    try {
        const [rows] = await con.query(
            "SELECT id FROM admins WHERE email=?",
            [email]
        );

        if (rows.length > 0) {
            return res.json({ exists: true });
        } else {
            return res.json({ exists: false });
        }

    } catch (err) {
        console.error(err);
        return res.status(500).json({ error: "Database error" });
    }
});

// ================= LOGIN =====================
router.post("/login", async (req, res) => {
    const { email, password, login_type } = req.body;

    if (!email || !password || !login_type) {
        return res.send("Please fill all fields ❌");
    }

    try {
        // ADMIN LOGIN
        if (login_type === "admin") {
            const [rows] = await con.query(
                "SELECT * FROM admins WHERE email=? AND password=?",
                [email, password]
            );

            if (rows.length > 0) {

                req.session.adminId = rows[0].id;
                req.session.role = "admin";
                req.session.email = rows[0].email; 

                return res.redirect("/home");
            } else {
                return res.send("Invalid Admin Email or Password ❌");
            }
        }

        // USER LOGIN
        if (login_type === "user") {
            const [rows] = await con.query(
                "SELECT * FROM users WHERE email=? AND password=? AND status='ACTIVE'",
                [email, password]
            );

            if (rows.length > 0) {

                req.session.userId = rows[0].id;
                req.session.role = "user";
                req.session.email = rows[0].email; 

                req.session.adminId = rows[0].admin_id;
                req.session.role_id = rows[0].role_id;
                req.session.userName = rows[0].name; 

                return res.redirect("/home");
            } else {
                return res.send("Invalid User Email or Password ❌");
            }
        }

        res.send("Invalid login type ❌");

    } catch (err) {
        console.error(err);
        res.send("Database error ❌");
    }
});

module.exports = router;
