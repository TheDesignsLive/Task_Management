// const express = require('express');
// const router = express.Router();
// const con = require('../config/db');

// router.get("/home", async (req, res) => {

//     if (!req.session.role) {
//         return res.redirect("/");
//     }

//     let show_sidebar = "Usersidebar";
//     let members = [];
//     let adminName = null;
//     let adminId = null;

//     try {

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

//     } catch (err) {
//         console.error(err);
//         res.send("Error loading home");
//     }
// });

// module.exports = router;
