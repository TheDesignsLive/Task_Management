const express = require("express");
const router = express.Router();
const con = require("../config/db"); // adjust path if needed

// Reset password API
router.post("/reset", async (req, res) => {
    const { contact, new_password } = req.body;

    try {
        // 🔎 Check in admins table
        let [adminRows] = await con.query(
            "SELECT * FROM admins WHERE email=? OR phone=?",
            [contact, contact]
        );

        if (adminRows.length > 0) {
            await con.query(
                "UPDATE admins SET password=? WHERE email=? OR phone=?",
                [new_password, contact, contact]
            );
            return res.json({ status: "success" });
        }

        // 🔎 Check in users table
        let [userRows] = await con.query(
            "SELECT * FROM users WHERE email=? OR phone=?",
            [contact, contact]
        );

        if (userRows.length > 0) {
            await con.query(
                "UPDATE users SET password=? WHERE email=? OR phone=?",
                [new_password, contact, contact]
            );
            return res.json({ status: "success" });
        }

        return res.json({
            status: "error",
            message: "Contact not found"
        });

    } catch (err) {
        console.error(err);
        return res.status(500).json({
            status: "error",
            message: "Server error"
        });
    }
});

module.exports = router;
