const express = require('express');
const cors = require('cors');
const path = require('path');
const session = require('express-session');
const MySQLStore = require('express-mysql-session')(session); // Added for DB sessions
const con = require('./config/db');
const http = require('http'); // Required for Socket.io
const socketIo = require('socket.io'); // Required for Socket.io
const cron = require('node-cron'); // Added for automatic cleanup

const backupDatabase = require('./backup/backup');
// const uploadLatestSQL = require('./drive');
// const cron = require('node-cron');

const app = express();
const server = http.createServer(app); // Create HTTP server
const io = socketIo(server); // Initialize Socket.io

// ================= SESSION DB CONFIG =================
const sessionStore = new MySQLStore({}, con); // Uses your existing 'sessions' table

// ================= ROUTES IMPORT =================
const authRoutes = require('./routers/auth.routes');
const homeroutes = require('./routers/home.routes');
const logoutRoutes = require('./routers/logout.routes');
const viewMemberRoutes = require('./routers/view_member');
const addmemberRoutes = require('./routers/member.routes');
const viewrole = require('./routers/view-role.routes');
// const addrole = require('./routers/add-role.routes');
// const delete_role = require('./routers/delete-role.routes');
// const editrole = require('./routers/edit-role.routes');
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
const panel=require('./routers/masterpanel.routes');
const viewTeamsRoutes = require('./routers/view-teams.routes');
const { debugLog } = require('./utils/logger');
const export_master=require('./backup/export_master');
const import_master=require('./backup/import_master.routes');

// ================= MIDDLEWARES =================
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Mobile Detection & Redirect Middleware
app.use((req, res, next) => {
    const host = req.get('host');
    const userAgent = req.headers['user-agent'].toLowerCase();
    
    // Mobile device keywords
    const isMobile = /android|webos|iphone|ipad|ipod|blackberry|iemobile|opera mini/i.test(userAgent);

    // Agar user mobile par hai aur abhi desktop domain par hai
    if (isMobile && host === 'tms.thedesigns.live') {
        // Redirect to your new mobile domain (m.thedesigns.live ya jo aapne banaya hai)
        return res.redirect('https://m-tms.thedesigns.live' + req.url);
    }

    next();
});



app.use(session({
    key: 'tms_session_cookie', // Cookie name
    secret: 'your_secret_key',
    store: sessionStore,       // Save sessions to your MySQL 'sessions' table
    resave: false,
    saveUninitialized: false,  
    cookie: {
        maxAge: 30 * 24 * 60 * 60 * 1000, // Fixed to 30 days for permanent feel
        httpOnly: true
    }
}));


app.use((req, res, next) => {
    req.io = io;
    next();
});

app.use(async (req, res, next) => {
    try {
        res.locals.admin = null;
        res.locals.teams = [];
        res.locals.session = req.session; // ✅ IMPORTANT

const isAdmin = req.session.role === 'admin' || req.session.role === 'owner';

        const adminId = req.session.adminId;

        if (!adminId) return next();

        // ✅ GET ADMIN
        const [adminRows] = await con.query(
            "SELECT id, name FROM admins WHERE id=?",
            [adminId]
        );

        if (adminRows.length > 0) {
            res.locals.admin = adminRows[0];
        }

        // ✅ GET TEAMS
        const [teams] = await con.query(
            "SELECT id, name FROM teams WHERE admin_id=?",
            [adminId]
        );

        res.locals.teams = teams;

        next();

    } catch (err) {
        console.error("Middleware error:", err);
        res.locals.admin = null;
        res.locals.teams = [];
        next();
    }
});



// ================= EJS & STATIC FILES =================
app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, 'views'));
app.use(express.static(path.join(__dirname, 'public')));

// ================= AUTOMATIC CLEANUP (CRON JOB) =================
// Runs every day at 00:00 (Midnight)
cron.schedule('0 0 * * *', () => {
    debugLog('Running auto-cleanup: Deleting old data...');

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
        else debugLog('Old announcements cleaned up.');
    });

    // Execute Tasks deletion
    con.query(deleteTasksSql, (err) => {
        if (err) console.error('Auto-cleanup Tasks Error:', err);
        else debugLog('Old completed tasks cleaned up.');
    });
});





function getISTTime() {
    return new Date().toLocaleString("en-IN", {
        timeZone: "Asia/Kolkata"
    });
}

function scheduleBackup(hour, minute, period) {

    let cronHour;

    if (period === "AM") {
        cronHour = (hour === 12) ? 0 : hour;
    } else {
        cronHour = (hour === 12) ? 12 : hour + 12;
    }

    const cronTime = `${minute} ${cronHour} * * *`;

    debugLog("==================================");
    debugLog("🕒 Current Server Time (UTC):", new Date().toString());
    debugLog("🕒 Current IST Time:", getISTTime());
    debugLog("⏰ Backup Time(IST):", `${hour}:${minute} ${period}`);
  
    debugLog("==================================");




let isBackupRunning = false; // 🔥 LOCK

cron.schedule(cronTime, async () => {
    if (isBackupRunning) {
        debugLog("⛔ Backup already running, skipping...");
        return;
    }

    isBackupRunning = true;

    try {
        debugLog("\n🚀 CRON TRIGGERED");

        await backupDatabase();  
       

    } catch (err) {
        console.error("❌ Cron Error:", err.message);
    } finally {
        isBackupRunning = false; // 🔓 UNLOCK
    }

}, {
    timezone: "Asia/Kolkata"
});
}


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

app.use('/', viewTeamsRoutes);

// Roles Management
app.use('/', viewrole);
// app.use('/add-role', addrole);
// app.use('/', editrole);
// app.use('/', delete_role);


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

app.use("/masterpage",panel)
app.use("/",export_master)
app.use('/', import_master);

// ================= START SERVER =================
const PORT = process.env.PORT || 3000;
server.listen(PORT, () => { // Changed app.listen to server.listen
   
    debugLog("server running on port " + PORT);
        scheduleBackup(12,0,"AM");
    
});
