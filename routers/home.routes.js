const express = require('express');
const router = express.Router();
const con = require('../config/db');

/* ===============================
   HOME PAGE (ADMIN + USER)
================================ */
router.get('/home', async (req, res) => {
    if (!req.session.role) return res.redirect('/');

    let members = [];
    let adminName = null;
    let tasks = [];
    let adminId;

    try {

        /* ============================
           ADMIN LOGIN
        ============================ */
        if (req.session.role === "admin") {
            adminId = req.session.adminId;
            req.session.control_type = 'ADMIN'; // Set control_type for Admin
          

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
                 ORDER BY 
    due_date ASC,
    CASE priority
        WHEN 'HIGH' THEN 1
        WHEN 'MEDIUM' THEN 2
        WHEN 'LOW' THEN 3
        ELSE 4
    END ASC`,
                [adminId]
            );

            tasks = taskRows;

            
            /* ==========================================================
             ADDED FOR OTHERS SECTION (USER → ADMIN TASKS)
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
                ORDER BY 
    due_date ASC,
    CASE priority
        WHEN 'HIGH' THEN 1
        WHEN 'MEDIUM' THEN 2
        WHEN 'LOW' THEN 3
        ELSE 4
    END ASC`,
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

                // 🔹 CHECK control_type FROM roles
                const [roleRows] = await con.query(
                    "SELECT control_type FROM roles WHERE id=?",
                    [roleId]
                );
                
                if (roleRows.length > 0) {
                    // Store control_type in session
                    req.session.control_type = roleRows[0].control_type;
                }
            }

            // Admin Name
            const [adminRows] = await con.query(
                "SELECT name FROM admins WHERE id=?",
                [adminId]
            );
            if (adminRows.length > 0) adminName = adminRows[0].name;


            //  ADD THIS BLOCK (FETCH ALL COMPANY USERS FOR DROPDOWN)
            const [rows] = await con.query(
                "SELECT id, name FROM users WHERE admin_id=? AND status='ACTIVE' AND id!=?",
                [adminId, req.session.userId]
            );
            members = rows;
            //  END ADDED BLOCK

            //  FETCH TASKS GIVEN BY ADMIN TO USER
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
               ORDER BY 
    due_date ASC,
    CASE priority
        WHEN 'HIGH' THEN 1
        WHEN 'MEDIUM' THEN 2
        WHEN 'LOW' THEN 3
        ELSE 4
    END ASC`,
                [adminId, req.session.userId]
            );

            // FETCH TASKS GIVEN BY USER ITSELF
            const [userTasksRows] = await con.query(
                `SELECT id, title, description, priority, due_date, status, section
                 FROM tasks
                 WHERE admin_id=? AND assigned_to=? AND who_assigned='user'
               ORDER BY 
    due_date ASC,
    CASE priority
        WHEN 'HIGH' THEN 1
        WHEN 'MEDIUM' THEN 2
        WHEN 'LOW' THEN 3
        ELSE 4
    END ASC`,
                [adminId, req.session.userId]
            );

            // FETCH TASKS GIVEN BY OTHER USERS IN SAME ADMIN
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
               ORDER BY 
    due_date ASC,
    CASE priority
        WHEN 'HIGH' THEN 1
        WHEN 'MEDIUM' THEN 2
        WHEN 'LOW' THEN 3
        ELSE 4
    END ASC`,
                [adminId, req.session.userId, req.session.userId]
            );

            //  MERGE USER TASKS + ADMIN TASKS + OTHER USERS TASKS
            tasks = [...userTasksRows, ...adminTasksRows, ...otherUserTasksRows];
        }
        // Render home
        res.render("home", {
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
