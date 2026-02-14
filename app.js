const express = require('express');
const cors = require('cors');
const path = require('path');
const session = require('express-session');

const app = express();
const PORT = 3000;

// DB connection
const con = require('./config/db');

// ================= ROUTES =================
const authRoutes = require('./routers/auth.routes');
const logoutRoutes = require('./routers/logout.routes');
const addmemberRoutes = require('./routers/add-member.routes');
const editmember = require('./routers/edit-member.routes');
const delete_member = require('./routers/delete-member.routes');
const viewMemberRoutes = require('./routers/view_member');
const addrole = require('./routers/add-role.routes');
const viewrole = require('./routers/view-role.routes');
const delete_role = require('./routers/delete-role.routes');
const editrole = require('./routers/edit-role.routes');
<<<<<<< HEAD
const logoutRoutes = require('./routers/logout.routes');
<<<<<<< HEAD
const homeroutes=require('./routers/home.routes');


=======

const homeTaskRoutes = require('./routers/home_task.routes'); // ✅ ONLY HOME ROUTE
>>>>>>> 6bf255002e8c1ee682d14b84a3d733004e472f49

const suspendmember=require('./routers/suspend-member.routes');
const notification=require('./routers/notifications.routes');
const memberRequest=require('./routers/memberRequest.routes');


=======
const taskRoutes = require('./routers/task.routes');
const homeTaskRoutes = require('./routers/home_task.routes');
const suspendmember = require('./routers/suspend-member.routes');
const notification = require('./routers/notifications.routes');
const memberRequest = require('./routers/memberRequest.routes');
>>>>>>> 5bc1039d323691841e127faf3ce5ea4d2e8c7a85

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
app.use('/', editmember);
app.use('/', delete_member);
app.use('/view_member', viewMemberRoutes);

app.use('/view-roles', viewrole);
app.use('/add-role', addrole);
app.use('/', editrole);
app.use('/', delete_role);

<<<<<<< HEAD
<<<<<<< HEAD
app.use('/',homeroutes);
=======
// app.use('/',homeroutes);
app.use('/add-task', taskRoutes);   // <-- Add this AFTER other routes
>>>>>>> 6bf255002e8c1ee682d14b84a3d733004e472f49
=======
app.use('/add-task', taskRoutes);
>>>>>>> 5bc1039d323691841e127faf3ce5ea4d2e8c7a85

app.use('/', suspendmember);
app.use('/', notification);
app.use('/', memberRequest);

<<<<<<< HEAD
app.use('/',notification);
app.use('/',memberRequest);

app.use('/view-roles',viewrole);
app.use('/add-role',addrole);
app.use('/',editrole);
app.use('/',delete_role);


// ✅ KEEP ONLY THIS HOME ROUTE

=======
// ✅ Home page (admin + user)
app.use('/', homeTaskRoutes);
>>>>>>> 5bc1039d323691841e127faf3ce5ea4d2e8c7a85

// ================= START SERVER =================
app.listen(PORT, () => {
    console.log(`Server running on http://localhost:${PORT}`);
});
