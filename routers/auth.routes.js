const express = require('express');
const router = express.Router();
const con = require('../config/db');
const session = require('express-session');

// ================= SESSION ====================
router.use(session({
    secret: "mysecretkey",
    resave: false,
    saveUninitialized: true
}));

// ================= SIGNUP ====================
router.post("/signup", async (req, res) => {
    const { name, company_name, email, phone, password } = req.body;

    if (!name || !email || !password) {
        return res.send("Please fill all required fields ❌");
    }

    const sql = "INSERT INTO admins (name, company_name, email, phone, password) VALUES (?,?,?,?,?)";

    try {
        const [result] = await con.query(sql, [name, company_name, email, phone, password]);

        // ✅ STORE SESSION
        req.session.adminId = result.insertId;
        req.session.role = "admin";

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

                // ✅ STORE SESSION
                req.session.adminId = rows[0].id;
                req.session.role = "admin";

                return res.redirect("/home");
            } else {
                return res.send("Invalid Admin Email or Password ❌");
            }
        }

        // USER LOGIN
        if (login_type === "user") {
            const [rows] = await con.query(
                "SELECT * FROM users WHERE email=? AND password=?",
                [email, password]
            );

            if (rows.length > 0) {

                // ✅ STORE SESSION
                req.session.userId = rows[0].id;
                req.session.role = "user";

                // 🔹 ADDED (ONLY THIS PART)
                req.session.admin_id = rows[0].admin_id;
                req.session.role_id = rows[0].role_id;

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
