const express = require('express');
const router = express.Router();
const con = require('../config/db');

router.get('/', async (req, res) => { // Assuming route is /assign-by-me based on context

    if (!req.session.role) {
        return res.redirect('/');
    }

    let show_sidebar = "Usersidebar";
    let members = [];
    let adminName = null;
    let openTasks = [];
    let completedTasks = [];

    try {

        // ================= ADMIN =================
        if (req.session.role === "admin") {

            show_sidebar = "sidebar";

            // members for navbar dropdown
            const [mRows] = await con.query(
                "SELECT id, name FROM users WHERE admin_id=? AND status='ACTIVE'",
                [req.session.adminId]
            );
            members = mRows;

            // admin name
            const [aRows] = await con.query(
                "SELECT name FROM admins WHERE id=?",
                [req.session.adminId]
            );
            if (aRows.length > 0) adminName = aRows[0].name;

            // FETCH ALL TASKS ASSIGNED BY ADMIN
            // Added due_date to selection
            const [rows] = await con.query(`
                SELECT 
                    t.id,
                    t.title,
                    t.description,
                    t.status,
                    t.due_date,
                    t.created_at,
                    u.name AS assigned_to
                FROM tasks t
                JOIN users u ON u.id = t.assigned_to
                WHERE t.who_assigned='admin' 
                AND t.assigned_by=?
                ORDER BY t.due_date ASC
            `, [req.session.adminId]);

            // SPLIT OPEN & COMPLETED
            rows.forEach(task => {
                if (task.status === 'COMPLETED') {
                    completedTasks.push(task);
                } else {
                    openTasks.push(task);
                }
            });
        }

        // ================= USER =================
        else if (req.session.role === "user") {

            const [uRows] = await con.query(
                "SELECT role_id, admin_id FROM users WHERE id=?",
                [req.session.userId]
            );

            if (uRows.length > 0) {

                const roleId = uRows[0].role_id;

                const [rRows] = await con.query(
                    "SELECT can_manage_members FROM roles WHERE id=?",
                    [roleId]
                );

                if (rRows.length > 0 && rRows[0].can_manage_members == 1) {
                    show_sidebar = "sidebar";
                } else {
                    show_sidebar = "Usersidebar";
                }
            }

            // FETCH USER ASSIGNED TASKS
            // Added due_date to selection
            const [rows] = await con.query(`
                SELECT 
                    t.id,
                    t.title,
                    t.description,
                    t.status,
                    t.due_date,
                    t.created_at,
                    u.name AS assigned_to
                FROM tasks t
                JOIN users u ON u.id = t.assigned_to
                WHERE t.who_assigned='user' 
                AND t.assigned_by=?
                ORDER BY t.due_date ASC
            `, [req.session.userId]);

            // SPLIT OPEN & COMPLETED
            rows.forEach(task => {
                if (task.status === 'COMPLETED') {
                    completedTasks.push(task);
                } else {
                    openTasks.push(task);
                }
            });
        }

        res.render('assign_by_me', {
            members,
            adminName,
            show_sidebar,
            openTasks,
            completedTasks,
            session: req.session
        });

    } catch (err) {
        console.error(err);
        res.send("Error loading Assign By Me");
    }
});

module.exports = router;