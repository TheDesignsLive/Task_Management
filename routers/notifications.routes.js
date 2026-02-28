const express = require('express');
const router = express.Router();
const con = require('../config/db');
const multer = require('multer');
const path = require('path');

// Multer Config for Attachments
const storage = multer.diskStorage({
    destination: (req, file, cb) => cb(null, 'public/uploads'),
    filename: (req, file, cb) => cb(null, Date.now() + "_" + file.originalname)
});
const upload = multer({ storage });

router.get('/notifications', async (req, res) => {
    if (!req.session.role) return res.redirect('/');

    let members = [];
    let adminName = null;
    let adminId = req.session.adminId;
    let memberRequests = [];
    let deletionRequests = []; // New array for deletion requests
    let roles = [];
    let announcements = [];

    try {
        const [aRows] = await con.query("SELECT name FROM admins WHERE id=?", [adminId]);
        if (aRows.length > 0) adminName = aRows[0].name;

        const [rRows] = await con.query("SELECT id, role_name FROM roles WHERE admin_id=?", [adminId]);
        roles = rRows;

        const isControlAdmin = req.session.control_type === 'ADMIN';

        if (req.session.role === "admin" || isControlAdmin) {
            const [mRows] = await con.query("SELECT id, name FROM users WHERE admin_id=? AND status='ACTIVE'", [adminId]);
            members = mRows;

            if (req.session.role === "admin") {
                // Fetch ADD member requests
                const [reqRows] = await con.query(`
                    SELECT mr.*, r.role_name, u.name AS requested_by_name
                    FROM member_requests mr
                    JOIN roles r ON r.id = mr.role_id
                    JOIN users u ON u.id = mr.requested_by
                    WHERE mr.admin_id=? AND mr.status='PENDING' AND mr.request_type='ADD' 
                    ORDER BY mr.created_at DESC
                `, [adminId]);
                memberRequests = reqRows;

                // Fetch DELETE member requests
                const [delRows] = await con.query(`
                    SELECT mr.*, r.role_name, u.name AS requested_by_name
                    FROM member_requests mr
                    JOIN roles r ON r.id = mr.role_id
                    JOIN users u ON u.id = mr.requested_by
                    WHERE mr.admin_id=? AND mr.status='PENDING' AND mr.request_type='DELETE' 
                    ORDER BY mr.created_at DESC
                `, [adminId]);
                deletionRequests = delRows;
            }

            // Fetch ALL Announcements
            const [annRows] = await con.query(`
                SELECT a.*, 
                IF(a.role_id = 0, 'All', r.role_name) AS target_role,
                CASE 
                    WHEN a.who_added = 'ADMIN' THEN CONCAT(adm.name, ' (Admin)')
                    ELSE usr.name 
                END AS added_by_name
                FROM announcements a
                LEFT JOIN roles r ON a.role_id = r.id
                LEFT JOIN admins adm ON a.added_by = adm.id AND a.who_added = 'ADMIN'
                LEFT JOIN users usr ON a.added_by = usr.id AND a.who_added = 'USER'
                WHERE a.admin_id=? ORDER BY a.created_at DESC
            `, [adminId]);
            announcements = annRows;

        } else if (req.session.role === "user") {
            const [annRows] = await con.query(`
                SELECT a.*, 
                CASE 
                    WHEN a.who_added = 'ADMIN' THEN CONCAT(adm.name, ' (Admin)')
                    ELSE usr.name 
                END AS added_by_name
                FROM announcements a
                LEFT JOIN admins adm ON a.added_by = adm.id AND a.who_added = 'ADMIN'
                LEFT JOIN users usr ON a.added_by = usr.id AND a.who_added = 'USER'
                WHERE a.admin_id=? AND (a.role_id = ? OR a.role_id = 0)
                ORDER BY a.created_at DESC
            `, [adminId, req.session.role_id]);
            announcements = annRows;
        }

        res.render('notifications', {
            members,
            adminName,
            memberRequests,
            deletionRequests, // Passing to EJS
            roles,
            announcements,
            session: req.session
        });

    } catch (err) {
        console.error(err);
        res.send("Error loading notifications");
    }
});

// POST ROUTE: ADD ANNOUNCEMENT
router.post('/add-announcement', upload.single('attachment'), async (req, res) => {
    try {
        const { title, description, role_id } = req.body;
        const attachment = req.file ? req.file.filename : null;
        
        const adminId = req.session.adminId;
        const addedBy = req.session.role === 'admin' ? req.session.adminId : req.session.userId;
        const whoAdded = req.session.role.toUpperCase();

        await con.query(
            "INSERT INTO announcements (admin_id, added_by, who_added, role_id, title, description, attachment) VALUES (?, ?, ?, ?, ?, ?, ?)",
            [adminId, addedBy, whoAdded, role_id, title, description, attachment]
        );
        res.redirect('/notifications');
    } catch (err) {
        console.error(err);
        res.send("Error adding announcement");
    }
});

// POST ROUTE: EDIT ANNOUNCEMENT
router.post('/edit-announcement/:id', upload.single('attachment'), async (req, res) => {
    try {
        const { title, description, role_id } = req.body;
        const announcementId = req.params.id;
        let query = "UPDATE announcements SET title=?, description=?, role_id=? WHERE id=?";
        let params = [title, description, role_id, announcementId];

        if (req.file) {
            query = "UPDATE announcements SET title=?, description=?, role_id=?, attachment=? WHERE id=?";
            params = [title, description, role_id, req.file.filename, announcementId];
        }

        await con.query(query, params);
        res.redirect('/notifications');
    } catch (err) {
        console.error(err);
        res.send("Error updating announcement");
    }
});

// GET ROUTE: DELETE ANNOUNCEMENT
router.get('/delete-announcement/:id', async (req, res) => {
    try {
        if (req.session.role === 'admin' || req.session.control_type === 'ADMIN') {
            await con.query("DELETE FROM announcements WHERE id=?", [req.params.id]);
            res.redirect('/notifications');
        } else {
            res.send("Unauthorized to delete announcements");
        }
    } catch (err) {
        console.error(err);
        res.send("Error deleting announcement");
    }
});

module.exports = router;