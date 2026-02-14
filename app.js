const express = require('express');
const cors = require('cors');
const path = require('path');
const session = require('express-session');
const con = require('./config/db'); // mysql2 promise pool

const app = express();
const PORT = 3000;

// Routes
const authRoutes = require('./routers/auth.routes');
const homeroutes = require('./routers/home.routes');
const viewMemberRoutes = require('./routers/view_member');
const addmemberRoutes = require('./routers/add-member.routes');
const editmember=require('./routers/edit-member.routes');
const taskRoutes = require('./routers/task.routes');
const delete_member=require('./routers/delete-member.routes');
const addrole=require('./routers/add-role.routes');
const viewrole=require('./routers/view-role.routes');
const delete_role=require('./routers/delete-role.routes');
const editrole=require('./routers/edit-role.routes');
const logoutRoutes = require('./routers/logout.routes');
const suspendmember=require('./routers/suspend-member.routes');




// Middlewares
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(session({
    secret: 'your_secret_key',  // change this in production
    resave: false,
    saveUninitialized: true
}));

// EJS
app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, 'views'));
app.use(express.static(path.join(__dirname, 'public')));

// Routes
app.get('/', (req, res) => {
    res.render('signup');
});

app.use('/', authRoutes);

app.use('/', logoutRoutes);

app.use('/',homeroutes);
app.use('/add-task', taskRoutes);   // <-- Add this AFTER other routes

app.use('/add-member',addmemberRoutes);
app.use('/',suspendmember);
app.use('/',editmember);
app.use('/',delete_member);

app.use('/view_member', viewMemberRoutes);


app.use('/view-roles',viewrole);
app.use('/add-role',addrole);
app.use('/',editrole);
app.use('/',delete_role);


// Start server
app.listen(PORT, () => {
    console.log(`Server running on http://localhost:${PORT}`);
});
