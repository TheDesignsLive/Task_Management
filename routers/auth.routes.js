const express = require('express');
const router = express.Router();
const con = require('../config/db');

// ================= SIGNUP ====================
router.post("/signup", async (req, res) => {
    const { name, company_name, email, phone, password } = req.body;

    if (!name || !email || !password) {
        return res.send("Please fill all required fields ❌");
    }

    const sql = "INSERT INTO admins (name, company_name, email, phone, password) VALUES (?,?,?,?,?)";

    try {
        await con.query(sql, [name, company_name, email, phone, password]);
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
                return res.send("User Login Success ✅");
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
