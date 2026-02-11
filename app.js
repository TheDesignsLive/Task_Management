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
        res.render('signup');
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
    const { email, password, login_type } = req.body;

    console.log("TYPE:", login_type);   // 👈 check in terminal

    if (!email || !password || !login_type) {
        return res.send("Please fill all fields ❌");
    }

    try {

        // 🔹 ADMIN LOGIN
        if (login_type === "admin") {

            const [rows] = await con.query(
                "SELECT * FROM admins WHERE email=? AND password=?",
                [email, password]
            );

            if (rows.length > 0) {
               return res.render("/home");
            } else {
                return res.send("Invalid Admin Email or Password ❌");
            }
        }

        // 🔹 USER LOGIN
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

        return res.send("Invalid login type ❌");

    } catch (err) {
        console.error(err);
        res.send("Database error ❌");
    }
});

app.get("/home", (req, res) => {
  res.render("home");
});


app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});
