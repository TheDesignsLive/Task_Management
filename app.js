const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const path = require('path');

const con = require('./config/db'); 
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

app.post("/signup", (req, res) => {
    const { name, company_name, email, phone, password } = req.body;

    const sql = "INSERT INTO admins (name, company_name, email, phone, password) VALUES (?,?,?,?,?)";

    con.query(sql, [name, company_name, email, phone, password], (err, result) => {
        if (err) return res.send("Email already exists ❌");
        res.send("Signup Success ✅");
    });
});

// ================= LOGIN =================
app.post("/login", (req, res) => {
    const { email, password } = req.body;

    const sql = "SELECT * FROM admins WHERE email=? AND password=?";

    con.query(sql, [email, password], (err, result) => {
        if (err) throw err;

        if (result.length > 0) {
            res.send("Login Success ✅");
        } else {
            res.send("Invalid Email or Password ❌");
        }
    });
});


app.post('/add-task', (req, res) => {
  const { task, date, priority, assignedTo } = req.body;

  if (!task || task.trim() === '') {
    return res.status(400).send('Task cannot be empty!');
  }

  
  let dbPriority = 'BLUE'; // default
  if (priority === 'High') dbPriority = 'RED';
  else if (priority === 'Medium') dbPriority = 'YELLOW';
  else if (priority === 'Low') dbPriority = 'BLUE';

  const due_date = date && date.trim() !== '' ? date : null;
  const assigned_to = assignedTo && assignedTo.trim() !== '' ? assignedTo : 'Unassigned';

  const query = `
    INSERT INTO task (task, due_date, priority, assigned_to)
    VALUES (?, ?, ?, ?)
  `;

  con.query(query, [task.trim(), due_date, dbPriority, assigned_to], (err, result) => {
    if (err) {
      console.log(err);
      return res.status(500).send('Database error');
    }
    res.send('Task added successfully!');
  });
});

app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});
