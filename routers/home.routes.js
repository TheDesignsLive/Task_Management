const express = require('express');
const router = express.Router();
const con = require('../config/db');

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

    try {

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

            // Tasks for admin only
            const [taskRows] = await con.query(
                `SELECT id, title, description, priority, due_date, status, section
                 FROM tasks
                 WHERE admin_id=? AND assigned_to=0 AND who_assigned='admin'
                 ORDER BY due_date ASC`,
                [adminId]
            );

            tasks = taskRows;

            
            /* ==========================================================
               ✅✅✅ ADDED FOR OTHERS SECTION (USER → ADMIN TASKS)
               Condition:
               admin_id = adminId
               assigned_to = 0
               who_assigned = 'user'
            ========================================================== */
            const [otherTaskRows] = await con.query(
                `SELECT t.id, t.title, t.description, t.priority,
                        t.due_date, t.status,
                        'OTHERS' AS section,
                        u.name AS assigned_by_name
                 FROM tasks t
                 JOIN users u ON t.assigned_by = u.id
                 WHERE t.admin_id=?
                 AND t.assigned_to=0
                 AND t.who_assigned='user'
                 ORDER BY t.due_date ASC`,
                [adminId]
            );

            // Merge into same tasks array
            tasks = [...tasks, ...otherTaskRows];
        }

        /* ============================
           USER LOGIN  
        ============================ */
        else if (req.session.role === "user") {
            adminId = req.session.adminId;

            // 🔹 GET ROLE ID FROM USER
            const [userRoleRows] = await con.query(
                "SELECT role_id FROM users WHERE id=?",
                [req.session.userId]
            );

            if (userRoleRows.length > 0) {
                const roleId = userRoleRows[0].role_id;

                // 🔹 CHECK can_manage_member FROM roles
                const [roleRows] = await con.query(
                    "SELECT can_manage_members FROM roles WHERE id=?",
                    [roleId]
                );
                if (roleRows.length > 0 && roleRows[0].can_manage_members == 1) {
                    show_sidebar = "sidebar";
                } else {
                    show_sidebar = "Usersidebar";
                }
            }

            // Admin Name
            const [adminRows] = await con.query(
                "SELECT name FROM admins WHERE id=?",
                [adminId]
            );
            if (adminRows.length > 0) adminName = adminRows[0].name;


            // 100%✅ ADD THIS BLOCK (FETCH ALL COMPANY USERS FOR DROPDOWN)
            const [rows] = await con.query(
                "SELECT id, name FROM users WHERE admin_id=? AND status='ACTIVE' AND id!=?",
                [adminId, req.session.userId]
            );
            members = rows;
            // 100%✅ END ADDED BLOCK

            // 100%✅ FETCH TASKS GIVEN BY ADMIN TO USER
            const [adminTasksRows] = await con.query(
                `SELECT t.id, t.title, t.description, t.priority,
                        t.due_date, t.status,
                        'OTHERS' AS section,
                        a.name AS assigned_by_name
                 FROM tasks t
                 JOIN admins a ON t.assigned_by = a.id
                 WHERE t.admin_id=?
                 AND t.assigned_to=?
                 AND t.who_assigned='admin'
                 ORDER BY t.due_date ASC`,
                [adminId, req.session.userId]
            );

            // 100%✅ FETCH TASKS GIVEN BY USER ITSELF
            const [userTasksRows] = await con.query(
                `SELECT id, title, description, priority, due_date, status, section
                 FROM tasks
                 WHERE admin_id=? AND assigned_to=? AND who_assigned='user'
                 ORDER BY due_date ASC`,
                [adminId, req.session.userId]
            );

            // 100%✅ FETCH TASKS GIVEN BY OTHER USERS IN SAME ADMIN
            const [otherUserTasksRows] = await con.query(
                `SELECT t.id, t.title, t.description, t.priority,
                        t.due_date, t.status,
                        'OTHERS' AS section,
                        u.name AS assigned_by_name
                 FROM tasks t
                 JOIN users u ON t.assigned_by = u.id
                 WHERE t.admin_id=? 
                 AND t.assigned_to=? 
                 AND t.who_assigned='user' 
                 AND t.assigned_by != ? 
                 ORDER BY t.due_date ASC`,
                [adminId, req.session.userId, req.session.userId]
            );

            // 100%✅ MERGE USER TASKS + ADMIN TASKS + OTHER USERS TASKS
            tasks = [...userTasksRows, ...adminTasksRows, ...otherUserTasksRows];
        }

        // Render home
        res.render("home", {
            show_sidebar,
            members,
            adminName,
            tasks,
            session: req.session
        });

    } catch (err) {
        console.error(err);
        res.send("Error loading home");
    }
});

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
