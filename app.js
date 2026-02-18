const express = require('express');
const cors = require('cors');
const path = require('path');
const session = require('express-session');
const con = require('./config/db');

const app = express();
const PORT = 3000;

// Routes
const authRoutes = require('./routers/auth.routes');
const viewMemberRoutes = require('./routers/view_member');
const addmemberRoutes = require('./routers/add-member.routes');
const editmember=require('./routers/edit-member.routes');
const taskRoutes = require('./routers/task.routes');
const delete_member = require('./routers/delete-member.routes');
const addrole = require('./routers/add-role.routes');
const viewrole = require('./routers/view-role.routes');
const delete_role = require('./routers/delete-role.routes');
const editrole = require('./routers/edit-role.routes');
const logoutRoutes = require('./routers/logout.routes');
const homeroutes=require('./routers/home.routes');

const suspendmember=require('./routers/suspend-member.routes');
const notification=require('./routers/notifications.routes');
const memberRequest=require('./routers/memberRequest.routes');
const updateTaskRoute = require('./routers/update-task-status');

const profile=require('./routers/profile.routes');
const settings=require('./routers/settings.routes');
const forgotPasswordRoutes = require('./routers/forgot-password.routes');
const SentMailRoutes = require('./routers/sent-mail.routes');





// ================= MIDDLEWARES =================
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(session({
    secret: 'your_secret_key',
    resave: false,
    saveUninitialized: true
}));

// ================= EJS =================
app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, 'views'));
app.use(express.static(path.join(__dirname, 'public')));

// ================= ROUTES =================
app.get('/', (req, res) => {
    res.render('signup');
});

app.use('/', authRoutes);
app.use('/', logoutRoutes);





app.use('/add-member', addmemberRoutes);
app.use('/', delete_member);
app.use('/view_member', viewMemberRoutes);
app.use('/add-task', taskRoutes);
app.use('/view-roles', viewrole);
app.use('/add-role', addrole);
app.use('/', editrole);
app.use('/', delete_role);


app.use('/',homeroutes);


app.use('/add-task', taskRoutes);   

app.use('/profile',profile);
app.use('/settings',settings);

app.use('/add-member',addmemberRoutes);
app.use('/',suspendmember);
app.use('/',editmember);
app.use('/',delete_member);
app.use('/view_member', viewMemberRoutes);

app.use('/',notification);
app.use('/',memberRequest);

app.use('/view-roles',viewrole);
app.use('/add-role',addrole);
app.use('/',editrole);
app.use('/',delete_role);

//forget password

// Forgot Password Page
app.get("/forgot-password", (req, res) => {
    res.render("forgot-password"); // renders forgot-password.ejs
});

app.use('/forgot-password', forgotPasswordRoutes);


// Show reset password page
app.get('/reset-password', (req, res) => {
    res.render('reset_password'); // reset_password.ejs
});

// Reset password API
app.post('/forgot-password/reset', async (req, res) => {
    const { contact, new_password } = req.body;

    try {
        // Check in admins
        let [adminRows] = await con.query("SELECT * FROM admins WHERE email=? OR phone=?", [contact, contact]);
        if(adminRows.length > 0){
            await con.query("UPDATE admins SET password=? WHERE email=? OR phone=?", [new_password, contact, contact]);
            return res.json({ status: "success" });
        }

        // Check in users
        let [userRows] = await con.query("SELECT * FROM users WHERE email=? OR phone=?", [contact, contact]);
        if(userRows.length > 0){
            await con.query("UPDATE users SET password=? WHERE email=? OR phone=?", [new_password, contact, contact]);
            return res.json({ status: "success" });
        }

        return res.json({ status: "error", message: "Contact not found" });
    } catch(err){
        console.error(err);
        return res.status(500).json({ status: "error", message: "Server error" });
    }
});

app.use('/', SentMailRoutes);

// app.use(updateTaskRoute);


//  KEEP ONLY THIS HOME ROUTE


// ================= START =================
app.listen(PORT, () => {
    console.log(`Server running on http://localhost:${PORT}`);
});
