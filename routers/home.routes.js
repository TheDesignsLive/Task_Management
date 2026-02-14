// const express = require('express');
// const router = express.Router();
// const con = require('../config/db');

<<<<<<< HEAD
/* ===============================
   HOME PAGE (ADMIN + USER)
================================ */
router.get('/home', async (req, res) => {
    if (!req.session.role) return res.redirect('/');

    let show_sidebar = "Usersidebar";
    let members = [];
    let adminName = null;
    let tasks = [];
    let adminId;
=======
// router.get("/home", async (req, res) => {

//     if (!req.session.role) {
//         return res.redirect("/");
//     }

//     let show_sidebar = "Usersidebar";
//     let members = [];
//     let adminName = null;
//     let adminId = null;
>>>>>>> 6bf255002e8c1ee682d14b84a3d733004e472f49

//     try {

<<<<<<< HEAD
        /* ============================
           ADMIN LOGIN
        ============================ */
        if (req.session.role === "admin") {
            show_sidebar = "sidebar";
            adminId = req.session.adminId;

            // Admin Name
            const [adminRows] = await con.query(
                "SELECT name FROM admins WHERE id=?",
                [adminId]
            );
            if (adminRows.length > 0) adminName = adminRows[0].name;

            // Members
            const [rows] = await con.query(
                "SELECT id, name FROM users WHERE admin_id=? AND status='ACTIVE'",
                [adminId]
            );
            members = rows;

            // Tasks for admin only where who_assigned = 'admin', assigned_to = 0
            const [taskRows] = await con.query(
                `SELECT id, title, description, priority, due_date, status, section
                 FROM tasks
                 WHERE admin_id=? AND assigned_to=0
                 ORDER BY due_date ASC`,
                [adminId]
            );

            tasks = taskRows;
        }

        /* ============================
           USER LOGIN
        ============================ */
        else if (req.session.role === "user") {
            adminId = req.session.adminId;

            // Admin Name
            const [adminRows] = await con.query(
                "SELECT name FROM admins WHERE id=?",
                [adminId]
            );
            if (adminRows.length > 0) adminName = adminRows[0].name;

            // Tasks assigned to user
            const [taskRows] = await con.query(
                `SELECT id, title, description, priority, due_date, status, section
                 FROM tasks
                 WHERE admin_id=? AND assigned_to=?
                 ORDER BY due_date ASC`,
                [adminId, req.session.userId]
            );

            tasks = taskRows;
        }

        // Render home
        res.render("home", {
            show_sidebar,
            members,
            adminName,
            tasks,
            session: req.session
        });
=======
//         // ============================
//         // 1️⃣ ADMIN LOGIN
//         // ============================
//         if (req.session.role === "admin") {

//             show_sidebar = "sidebar";
//             adminId = req.session.adminId;

//             // Get admin name
//             const [adminRows] = await con.query(
//                 "SELECT name FROM admins WHERE id=?",
//                 [adminId]
//             );

//             if (adminRows.length > 0) {
//                 adminName = adminRows[0].name;
//             }

//             // Get users
//             const [rows] = await con.query(
//                 "SELECT id, name FROM users WHERE admin_id=? AND status='ACTIVE'",
//                 [adminId]
//             );

//             members = rows;
//         }

//         // ============================
//         // 2️⃣ USER LOGIN
//         // ============================
//         else if (req.session.role === "user") {

//             // First get admin_id of this user
//             const [userRows] = await con.query(
//                 "SELECT admin_id, role_id FROM users WHERE id=?",
//                 [req.session.userId]
//             );

//             if (userRows.length === 0) {
//                 return res.send("User not found");
//             }

//             adminId = userRows[0].admin_id;

//             // 🔥 Get admin name directly using admin_id
//             const [adminRows] = await con.query(
//                 "SELECT name FROM admins WHERE id=?",
//                 [adminId]
//             );

//             if (adminRows.length > 0) {
//                 adminName = adminRows[0].name;
//             }

//             // Permission check
//             const role_id = userRows[0].role_id;

//             const [roleRows] = await con.query(
//                 "SELECT can_manage_members FROM roles WHERE id=?",
//                 [role_id]
//             );

//             if (roleRows.length > 0 && roleRows[0].can_manage_members == 1) {
//                 show_sidebar = "sidebar";
//             } else {
//                 show_sidebar = "Usersidebar";
//             }

//             // Get company users except himself
//             const [rows] = await con.query(
//                 "SELECT id, name FROM users WHERE admin_id=? AND status='ACTIVE' AND id!=?",
//                 [adminId, req.session.userId]
//             );

//             members = rows;
//         }

//         // ============================
//         // 3️⃣ Render
//         // ============================
//         res.render("home", {
//             show_sidebar,
//             members,
//             adminName,
//             session: req.session
//         });
>>>>>>> 6bf255002e8c1ee682d14b84a3d733004e472f49

//     } catch (err) {
//         console.error(err);
//         res.send("Error loading home");
//     }
// });

<<<<<<< HEAD
/* ===============================
   UPDATE TASK STATUS
================================ */
router.post('/update-task-status', async (req, res) => {
    const { id, status } = req.body;
    try {
        await con.query("UPDATE tasks SET status=? WHERE id=?", [status, id]);
        res.json({ success: true });
    } catch (err) {
        console.error(err);
        res.status(500).json({ success: false });
    }
});

/* ===============================
   UPDATE TASK SECTION
================================ */
router.post('/update-task-section', async (req, res) => {
    const { id, section } = req.body;
    try {
        await con.query("UPDATE tasks SET section=? WHERE id=?", [section, id]);
        res.json({ success: true });
    } catch (err) {
        console.error(err);
        res.status(500).json({ success: false });
    }
});

module.exports = router;
=======
// module.exports = router;
>>>>>>> 6bf255002e8c1ee682d14b84a3d733004e472f49
