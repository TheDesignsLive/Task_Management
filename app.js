const express = require('express');
const cors = require('cors');
const path = require('path');
const con = require('./config/db'); // mysql2 promise pool
const app = express();
const PORT = 3000;

app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, 'views'));
app.use(express.static(path.join(__dirname, 'public')));

app.get('/', (req, res) => {
  res.render('signup');
});

// ================= SIGNUP ====================
app.post("/signup", async (req, res) => {
    const { name, company_name, email, phone, password } = req.body;

    if (!name || !email || !password) {
        return res.send("Please fill all required fields ❌");
    }

    const sql = "INSERT INTO admins (name, company_name, email, phone, password) VALUES (?,?,?,?,?)";

    try {
        await con.query(sql, [name, company_name, email, phone, password]);
        res.send("Signup Success ✅");z
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
app.post("/login", async (req, res) => {
    const { email, password } = req.body;

    if (!email || !password) return res.send("Please fill all fields ❌");

    const sql = "SELECT * FROM admins WHERE email=? AND password=?";

    try {
        const [rows] = await con.query(sql, [email, password]);
        if (rows.length > 0) {
            res.send("Login Success ✅");
        } else {
            res.send("Invalid Email or Password ❌");
        }
    } catch (err) {
        console.error(err);
        res.send("Database error ❌");
    }
});

app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});
