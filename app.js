const express = require('express');
const cors = require('cors');
const path = require('path');
const session = require('express-session');
const con = require('./config/db');

const app = express();
const PORT = 3000;

// ================= ROUTES IMPORT =================
const authRoutes = require('./routers/auth.routes');
const homeroutes = require('./routers/home.routes');
const logoutRoutes = require('./routers/logout.routes');
const viewMemberRoutes = require('./routers/view_member');
const addmemberRoutes = require('./routers/add-member.routes');
const editmember = require('./routers/edit-member.routes');
const delete_member = require('./routers/delete-member.routes');
const suspendmember = require('./routers/suspend-member.routes');
const taskRoutes = require('./routers/task.routes');
const updateTaskRoute = require('./routers/update-task-status');
const addrole = require('./routers/add-role.routes');
const viewrole = require('./routers/view-role.routes');
const delete_role = require('./routers/delete-role.routes');
const editrole = require('./routers/edit-role.routes');
const notification = require('./routers/notifications.routes');
const memberRequest = require('./routers/memberRequest.routes');
const AssignByMe = require('./routers/assign_by_me.routes');
const profile = require('./routers/profile.routes');
const settings = require('./routers/settings.routes');
const forgotPasswordRoutes = require('./routers/forgot-password.routes');
const SentMailRoutes = require('./routers/sent-mail.routes');
const changePassword = require("./routers/change-password.routes");

// ================= MIDDLEWARES =================
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(session({
    secret: 'your_secret_key',
    resave: false,
    saveUninitialized: true
}));

// ================= EJS & STATIC FILES =================
app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, 'views'));
app.use(express.static(path.join(__dirname, 'public')));

// ================= ROUTES EXECUTION =================

// Base & Auth
app.get('/', (req, res) => {
    res.render('signup');
});
app.use('/', authRoutes);
app.use('/', logoutRoutes);
app.use('/', homeroutes);

// Member Management
app.use('/view_member', viewMemberRoutes);
app.use('/add-member', addmemberRoutes);
app.use('/', editmember);
app.use('/', delete_member);
app.use('/', suspendmember);
app.use('/', memberRequest);

// Roles Management
app.use('/view-roles', viewrole);
app.use('/add-role', addrole);
app.use('/', editrole);
app.use('/', delete_role);

// Tasks & Features
app.use('/add-task', taskRoutes);
app.use('/assign_by_me', AssignByMe);
app.use('/', notification);
app.use('/profile', profile);
app.use('/settings', settings);

// Forgot Password Workflow
app.get("/forgot-password", (req, res) => {
    res.render("forgot-password");
});
app.use('/forgot-password', forgotPasswordRoutes);
app.use("/forgot-password", changePassword);
app.use('/', SentMailRoutes);

app.get('/reset-password', (req, res) => {
    res.render('reset_password');
});

// ================= START SERVER =================
app.listen(PORT, () => {
    console.log(`Server running on http://localhost:${PORT}`);
});