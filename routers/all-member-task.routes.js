const express = require('express');
const router = express.Router();
const con = require('../config/db');

router.get('/all-member-task', async (req, res) => {

    if (!req.session.role) {
        return res.redirect('/');
    }

    try {

        let users = [];
        let members = [];
        let roles = [];
        let adminName = null;
        let tasks = [];

        const selectedUser = req.query.user_id || 'all';
        const adminId = req.session.adminId;

        // ================= ADMIN =================
        if (req.session.role === 'admin') {

            // Admin name
            const [adminRows] = await con.query(
                "SELECT name FROM admins WHERE id=?",
                [adminId]
            );
            if (adminRows.length > 0) {
                adminName = adminRows[0].name;
            }

            // Users list
            const [userRows] = await con.query(
                "SELECT id, name FROM users WHERE admin_id=? AND status='ACTIVE'",
                [adminId]
            );
            users = userRows;
            members = userRows;

            // Roles
            const [roleRows] = await con.query(
                "SELECT id, role_name FROM roles WHERE admin_id=?",
                [adminId]
            );
            roles = roleRows;

            // ===== ORIGINAL TASK QUERY =====
            let taskQuery = `
                SELECT 
                    t.*,
                    u1.name AS assigned_to_name,
                    u2.name AS assigned_by_name
                FROM tasks t
                JOIN users u1 ON t.assigned_to = u1.id
                JOIN users u2 ON t.assigned_by = u2.id
                WHERE t.admin_id = ?
            `;

            let params = [adminId];

            if (selectedUser !== 'all') {
                taskQuery += " AND t.assigned_to = ?";
                params.push(selectedUser);
            }

            const [taskRows] = await con.query(taskQuery, params);
            tasks = taskRows;

            /* ===============================
               ADD OTHERS SECTION HERE
            =============================== */

            let otherUserTasks;

               if (selectedUser === 'all') {

                const [rows] = await con.query(
                    `SELECT 
                        t.*,
                        'OTHERS' AS section,
                        u1.name AS assigned_to_name,
                        CASE 
                            WHEN t.who_assigned = 'admin' THEN a.name
                            ELSE u2.name
                        END AS assigned_by_name
                     FROM tasks t
                     JOIN users u1 ON t.assigned_to = u1.id
                     LEFT JOIN users u2 ON t.assigned_by = u2.id
                     LEFT JOIN admins a ON t.assigned_by = a.id
                     WHERE t.admin_id = ?
                       AND t.assigned_to != t.assigned_by
                     ORDER BY t.due_date ASC`,
                    [adminId]
                );

                otherUserTasks = rows;

            } else {

                const [rows] = await con.query(
                    `SELECT 
                        t.*,
                        'OTHERS' AS section,
                        u1.name AS assigned_to_name,
                        CASE 
                            WHEN t.who_assigned = 'admin' THEN a.name
                            ELSE u2.name
                        END AS assigned_by_name
                     FROM tasks t
                     JOIN users u1 ON t.assigned_to = u1.id
                     LEFT JOIN users u2 ON t.assigned_by = u2.id
                     LEFT JOIN admins a ON t.assigned_by = a.id
                     WHERE t.admin_id = ?
                       AND t.assigned_to = ?
                       AND t.assigned_to != t.assigned_by
                     ORDER BY t.due_date ASC`,
                    [adminId, selectedUser]
                );

                otherUserTasks = rows;
            }

            // 🔥 MERGE OTHERS INTO MAIN TASKS
            tasks = [...tasks, ...otherUserTasks];
        }
        // ================= USER =================
        else if (req.session.role === 'user') {

            const userId = req.session.userId;

            const [adminRows] = await con.query(
                "SELECT name FROM admins WHERE id=?",
                [adminId]
            );
            if (adminRows.length > 0) {
                adminName = adminRows[0].name;
            }

            const [userRows] = await con.query(
                "SELECT id, name FROM users WHERE admin_id=? AND status='ACTIVE'",
                [adminId]
            );
            users = userRows;
            members = userRows;

            const [roleRows] = await con.query(
                "SELECT id, role_name FROM roles WHERE admin_id=?",
                [adminId]
            );
            roles = roleRows;

                    let taskQuery = `
                SELECT 
                    t.*,
                    u1.name AS assigned_to_name,
                    u2.name AS assigned_by_name
                FROM tasks t
                JOIN users u1 ON t.assigned_to = u1.id
                JOIN users u2 ON t.assigned_by = u2.id
                WHERE t.admin_id = ?
            `;

            let params = [adminId];

            if (selectedUser !== 'all') {
                taskQuery += " AND t.assigned_to = ?";
                params.push(selectedUser);
            }

            const [taskRows] = await con.query(taskQuery, params);
            tasks = taskRows;

            /* ===============================
   ADD OTHERS SECTION FOR USER
=============================== */

let otherUserTasks;

if (selectedUser === 'all') {

    const [rows] = await con.query(
        `SELECT 
            t.*,
            'OTHERS' AS section,
            u1.name AS assigned_to_name,
            CASE 
                WHEN t.who_assigned = 'admin' THEN a.name
                ELSE u2.name
            END AS assigned_by_name
         FROM tasks t
         JOIN users u1 ON t.assigned_to = u1.id
         LEFT JOIN users u2 ON t.assigned_by = u2.id
         LEFT JOIN admins a ON t.assigned_by = a.id
         WHERE t.admin_id = ?
           AND t.assigned_to != t.assigned_by
         ORDER BY t.due_date ASC`,
        [adminId]
    );

    otherUserTasks = rows;

} else {

    const [rows] = await con.query(
        `SELECT 
            t.*,
            'OTHERS' AS section,
            u1.name AS assigned_to_name,
            CASE 
                WHEN t.who_assigned = 'admin' THEN a.name
                ELSE u2.name
            END AS assigned_by_name
         FROM tasks t
         JOIN users u1 ON t.assigned_to = u1.id
         LEFT JOIN users u2 ON t.assigned_by = u2.id
         LEFT JOIN admins a ON t.assigned_by = a.id
         WHERE t.admin_id = ?
           AND t.assigned_to = ?
           AND t.assigned_to != t.assigned_by
         ORDER BY t.due_date ASC`,
        [adminId, selectedUser]
    );

    otherUserTasks = rows;
}

// Merge OTHERS
tasks = [...tasks, ...otherUserTasks];
        }

        res.render('all-member-task', {
            session: req.session,
            users,
            members,
            roles,
            adminName,
            tasks,
            selected_user: selectedUser
        });

    } catch (err) {
        console.error(err);
        res.send("Database Error");
    }
});

module.exports = router;
