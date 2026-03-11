const express = require('express');
const cors = require('cors');
const path = require('path');
const session = require('express-session');
const con = require('./config/db');
const http = require('http'); // Required for Socket.io
const socketIo = require('socket.io'); // Required for Socket.io
const cron = require('node-cron'); // Added for automatic cleanup

const app = express();
const server = http.createServer(app); // Create HTTP server
const io = socketIo(server); // Initialize Socket.io

// ================= ROUTES IMPORT =================
const authRoutes = require('./routers/auth.routes');
const homeroutes = require('./routers/home.routes');
const logoutRoutes = require('./routers/logout.routes');
const viewMemberRoutes = require('./routers/view_member');
const addmemberRoutes = require('./routers/member.routes');
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

const allMemberTask=require('./routers/all-member-task.routes');

const ma=require('./routers/master.routes');

// ================= MIDDLEWARES =================
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(session({
    secret: 'your_secret_key',
    resave: false,
    saveUninitialized: false,   // better security
    cookie: {
        maxAge: 7 * 24 * 60 * 60 * 1000 // 7 days in milliseconds
    }
}));

// SOCKET.IO MIDDLEWARE: This makes 'req.io' available in all your routers
app.use((req, res, next) => {
    req.io = io;
    next();
});

// ================= EJS & STATIC FILES =================
app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, 'views'));
app.use(express.static(path.join(__dirname, 'public')));

// ================= AUTOMATIC CLEANUP (CRON JOB) =================
// Runs every day at 00:00 (Midnight)
cron.schedule('0 0 * * *', () => {
    console.log('Running auto-cleanup: Deleting old data...');

    // 1. Delete Announcements older than 1 month
    const deleteAnnouncementsSql = `
        DELETE FROM announcements 
        WHERE created_at < NOW() - INTERVAL 1 MONTH`;

    // 2. Delete Completed Tasks older than 1 month
    const deleteTasksSql = `
        DELETE FROM tasks 
        WHERE status = 'COMPLETED' 
        AND updated_at < NOW() - INTERVAL 1 MONTH`;

    // Execute Announcements deletion
    con.query(deleteAnnouncementsSql, (err) => {
        if (err) console.error('Auto-cleanup Announcements Error:', err);
        else console.log('Old announcements cleaned up.');
    });

    // Execute Tasks deletion
    con.query(deleteTasksSql, (err) => {
        if (err) console.error('Auto-cleanup Tasks Error:', err);
        else console.log('Old completed tasks cleaned up.');
    });
});

// ================= ROUTES EXECUTION =================

// Base & Auth
app.get('/', (req, res) => {
    // ✅ If session exists, redirect to home without login
    if (req.session.adminId || req.session.userId) {
        return res.redirect('/home'); // ✅
    }
    res.render('signup');
});

app.use('/', authRoutes);
app.use('/', logoutRoutes);
app.use('/', homeroutes);
app.use('/',ma)

// Member Management
app.use('/view_member', viewMemberRoutes);
app.use('/', addmemberRoutes); //edit,delete,suspend
app.use('/', memberRequest);

// Roles Management
app.use('/view-roles', viewrole);
app.use('/add-role', addrole);
app.use('/', editrole);
app.use('/', delete_role);

// Tasks & Features
app.use('/assign_by_me', AssignByMe);
app.use('/', notification);
app.use('/profile', profile);
app.use('/settings', settings);
app.use('/',allMemberTask);


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
const PORT = process.env.PORT || 3000;
server.listen(PORT, () => { // Changed app.listen to server.listen
    console.log("Server running on port " + PORT);
});