const express = require('express');
const router = express.Router();
const con = require('../config/db');
const { notifyMobile } = require('../utils/notifyMobile'); 

/* ===============================
    NEW API ENDPOINT FOR NO-RELOAD
================================ */
router.get('/api/get-all-tasks', async (req, res) => {
    if (!req.session.role) return res.status(401).json({ success: false });
    const adminId = req.session.adminId;
    const userId = req.session.userId;
    let tasks = [];

    try {
        if (req.session.role === "admin") {

const [taskRows] = await con.query(
  "SELECT id, title, description, priority, due_date, status, section, assigned_by, assigned_to, who_assigned FROM tasks WHERE admin_id=? AND assigned_to=0 AND who_assigned='admin' ORDER BY due_date ASC",
  [adminId]
);

const [otherTaskRows] = await con.query(
  `SELECT t.id, t.title, t.description, t.priority, t.due_date, t.status, t.section,
          t.assigned_by, t.assigned_to, t.who_assigned,
          u.name AS assigned_by_name
   FROM tasks t 
   JOIN users u ON t.assigned_by = u.id 
   WHERE t.admin_id=? AND t.assigned_to=0 
AND (t.who_assigned='user' OR t.who_assigned='owner')
   ORDER BY due_date ASC`,
  [adminId]
);

tasks = [...taskRows, ...otherTaskRows];

        } else {

            // ✅ FIXED (removed 'OTHERS' hardcode)
const [adminTasksRows] = await con.query(
    `SELECT t.id, t.title, t.description, t.priority, t.due_date, t.status, t.section,
            t.assigned_by, t.assigned_to, t.who_assigned,
            a.name AS assigned_by_name 
     FROM tasks t 
     JOIN admins a ON t.assigned_by = a.id 
     WHERE t.admin_id=? AND t.assigned_to=? 
     ORDER BY due_date ASC`,
    [adminId, req.session.userId]
);

const [userOwnTasksRows] = await con.query(
    `SELECT id, title, description, priority, due_date, status, section,
            assigned_by, assigned_to, who_assigned
     FROM tasks 
     WHERE admin_id=? AND assigned_to=? AND (who_assigned='user' OR who_assigned='owner') AND assigned_by=? 
     ORDER BY due_date ASC`,
    [adminId, req.session.userId, req.session.userId]
);

            // ✅ FIXED (removed 'OTHERS' hardcode)
const [userToOthersTasksRows] = await con.query(
    `SELECT t.id, t.title, t.description, t.priority, t.due_date, t.status, t.section,
            t.assigned_by, t.assigned_to, t.who_assigned,
            u.name AS assigned_by_name 
     FROM tasks t 
     JOIN users u ON t.assigned_by = u.id 
     WHERE t.admin_id=? AND t.assigned_to=? AND (t.who_assigned='user' OR t.who_assigned='owner') AND t.assigned_by != ? 
     ORDER BY due_date ASC`,
    [adminId, req.session.userId, req.session.userId]
);

            tasks = [...userOwnTasksRows, ...adminTasksRows, ...userToOthersTasksRows];
        }

        res.json({ success: true, tasks });

    } catch (err) {
        res.status(500).json({ success: false });
    }
});

/* ===============================
    HOME PAGE (ADMIN + USER + OWNER)
================================ */
router.get('/home', async (req, res) => {
    if (!req.session.role) return res.redirect('/');
    let members = [];
    let adminName = null;
    let tasks = [];
    let teams = []; // ✅ ADD THIS LINE
    let adminId;

    try {
        if (req.session.role === "admin") {

            adminId = req.session.adminId;
            req.session.control_type = 'ADMIN';

            const [adminRows] = await con.query("SELECT name FROM admins WHERE id=?", [adminId]);
            if (adminRows.length > 0) adminName = adminRows[0].name;

            const [rows] = await con.query(
                "SELECT id, name FROM users WHERE admin_id=? AND status='ACTIVE'",
                [adminId]
            );
            members = rows;


                    // ✅ GET TEAMS FOR ADMIN
        const [teamRows] = await con.query(
            "SELECT id, name FROM teams WHERE admin_id=?",
            [adminId]
        );
        teams = teamRows;

                    // ✅ FIXED
        const [taskRows] = await con.query(
            `SELECT id, title, description, priority, due_date, status, section, assigned_by, assigned_to, who_assigned
            FROM tasks 
            WHERE admin_id=? AND assigned_to=0 AND who_assigned='admin'
            ORDER BY due_date ASC`,
            [adminId]
        );
        const [otherTaskRows] = await con.query(
        `SELECT t.id, t.title, t.description, t.priority, t.due_date, t.status, t.section,
                t.assigned_by, t.assigned_to, t.who_assigned,
                u.name AS assigned_by_name
        FROM tasks t 
        JOIN users u ON t.assigned_by = u.id 
        WHERE t.admin_id=? AND t.assigned_to=0 
AND (t.who_assigned='user' OR t.who_assigned='owner')
        ORDER BY due_date ASC`,
        [adminId]
        );

        tasks = [...taskRows, ...otherTaskRows];

        } else if (req.session.role === "user" || req.session.role === "owner") {

            adminId = req.session.adminId;

            const [userRoleRows] = await con.query("SELECT role_id FROM users WHERE id=?", [req.session.userId]);
            if (userRoleRows.length > 0) {
                const roleId = userRoleRows[0].role_id;
                const [roleRows] = await con.query("SELECT control_type FROM roles WHERE id=?", [roleId]);
                if (roleRows.length > 0) req.session.control_type = roleRows[0].control_type;
            }

            const [adminRows] = await con.query("SELECT name FROM admins WHERE id=?", [adminId]);
            if (adminRows.length > 0) adminName = adminRows[0].name;

            const [rows] = await con.query(
                "SELECT id, name FROM users WHERE admin_id=? AND status='ACTIVE' AND id!=?",
                [adminId, req.session.userId]
            );
            members = rows;


                    // ✅ GET TEAMS FOR USER (same admin)
        const [teamRows] = await con.query(
            "SELECT id, name FROM teams WHERE admin_id=?",
            [adminId]
        );
        teams = teamRows;

            // ✅ FIXED
            const [adminTasksRows] = await con.query(
                `SELECT t.id, t.title, t.description, t.priority, t.due_date, t.status, t.section,
                        t.assigned_by, t.assigned_to, t.who_assigned,
                        a.name AS assigned_by_name 
                FROM tasks t 
                JOIN admins a ON t.assigned_by = a.id 
                WHERE t.admin_id=? AND t.assigned_to=? 
                ORDER BY due_date ASC`,
                [adminId, req.session.userId]
            );

            const [userOwnTasksRows] = await con.query(
                `SELECT id, title, description, priority, due_date, status, section, assigned_by, assigned_to, who_assigned 
                 FROM tasks 
                 WHERE admin_id=? AND assigned_to=? AND (who_assigned='user' OR who_assigned='owner') AND assigned_by=? 
                 ORDER BY due_date ASC`,
                [adminId, req.session.userId, req.session.userId]
            );

                    // ✅ FIXED
        const [userToOthersTasksRows] = await con.query(
            `SELECT t.id, t.title, t.description, t.priority, t.due_date, t.status, t.section,
                    t.assigned_by, t.assigned_to, t.who_assigned,
                    u.name AS assigned_by_name 
            FROM tasks t 
            JOIN users u ON t.assigned_by = u.id 
            WHERE t.admin_id=? AND t.assigned_to=? AND (who_assigned='user' OR who_assigned='owner') AND assigned_by != ? 
            ORDER BY due_date ASC`,
            [adminId, req.session.userId, req.session.userId]
        );

            tasks = [...userOwnTasksRows, ...adminTasksRows, ...userToOthersTasksRows];
        }

        res.render("home", {
            members,
            adminName,
            tasks,
            session: req.session,
             teams, // ✅ ADD THIS
            activePage: 'home'
        });

    } catch (err) {
        res.send("Error loading home");
    }
});

/* ===============================
    TASK ACTIONS (WITH EMIT)
================================ */

router.post('/update-task-date', async (req, res) => {
    const { id, due_date } = req.body;
    try {
        await con.query("UPDATE tasks SET due_date=? WHERE id=?", [due_date, id]);
        req.io.emit('update_tasks');
          notifyMobile(); // ✅ ADD — tells mobile clients to refresh
        res.json({ success: true });
    } catch (err) {
        res.status(500).json({ success: false });
    }
});

router.post('/update-task-status', async (req, res) => {
    const { id, status } = req.body;
    try {
        await con.query("UPDATE tasks SET status=? WHERE id=?", [status, id]);
        req.io.emit('update_tasks');
        notifyMobile(); // ✅ ADD — tells mobile clients to refresh
        res.json({ success: true });
    } catch (err) {
        res.status(500).json({ success: false });
    }
});

router.post('/update-task-section', async (req, res) => {
    const { id, section } = req.body;
    try {
        await con.query("UPDATE tasks SET section=? WHERE id=?", [section, id]);
        req.io.emit('update_tasks');
          notifyMobile(); // ✅ ADD — tells mobile clients to refresh
        res.json({ success: true });
    } catch (err) {
        res.status(500).json({ success: false });
    }
});

router.post('/edit-task-details', async (req, res) => {
    const { id, title, description, priority, due_date, assigned_to } = req.body;

    try {

        const adminId = req.session.adminId;
        const sessionRole = req.session.role;   // "admin", "owner", or "user"
        const sessionUserId = req.session.userId;

        let finalAssignedTo = assigned_to;
        let finalAssignedBy;
        let whoAssigned;

        // ================= ASSIGN LOGIC =================

        if (sessionRole === "admin") {

            // ADMIN LOGIN
            finalAssignedBy = adminId;
            whoAssigned = "admin";

            if (assigned_to == 0) {
                // admin assign to himself
                finalAssignedTo = 0;
            } else {
                // admin assign to employee
                finalAssignedTo = assigned_to;
            }

        } else if (sessionRole === "user" || sessionRole === "owner") {

            // USER / OWNER LOGIN
            finalAssignedBy = sessionUserId;
            whoAssigned = sessionRole;

            if (assigned_to == 0) {
                // user assign to admin
                finalAssignedTo = 0;
            } else {
                // user assign to another user OR self
                finalAssignedTo = assigned_to;
            }
        }

        // ================= UPDATE QUERY =================

        await con.query(
            `UPDATE tasks 
             SET title=?, description=?, priority=?, due_date=?, 
                 assigned_to=?
             WHERE id=?`,
            [
                title,
                description,
                priority,
                due_date,
                finalAssignedTo,
                id
            ]
        );

        // ================= SOCKET =================
        req.io.emit('update_tasks');
        notifyMobile(); // ✅ ADD — tells mobile clients to refresh

        res.json({ success: true });

    } catch (err) {
        console.error(err);
        res.status(500).json({ success: false });
    }
});

router.post('/delete-task/:id', async (req, res) => {
    try {
        await con.query("DELETE FROM tasks WHERE id=?", [req.params.id]);
        req.io.emit('update_tasks');
        notifyMobile(); // ✅ ADD — tells mobile clients to refresh
        res.json({ success: true });
    } catch (err) {
        res.status(500).json({ success: false });
    }
});
router.post('/delete-completed-tasks', async (req, res) => {
    try {
        const adminId = req.session.adminId;
        await con.query("DELETE FROM tasks WHERE admin_id=? AND status='COMPLETED'", [adminId]);
        req.io.emit('update_tasks');
        notifyMobile(); // ✅ ADD — tells mobile clients to refresh
        res.json({ success: true });
    } catch (err) {
        res.status(500).json({ success: false });
    }
});
module.exports = router;