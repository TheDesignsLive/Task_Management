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
    let deletionRequests = []; 
    let roles = [];
    let announcements = [];
    let controlType = null;
    const sessionRole = req.session.role;
    const sessionUserId = req.session.userId;

    try {
        const [aRows] = await con.query("SELECT name FROM admins WHERE id=?", [adminId]);
        if (aRows.length > 0) adminName = aRows[0].name;

        const [rRows] = await con.query("SELECT id, role_name FROM roles WHERE admin_id=?", [adminId]);
        roles = rRows;

        // ================= NAVBAR DROPDOWN (MEMBERS) LOGIC =================
        // Everyone can assign tasks to everyone EXCEPT self (and users can't assign to Admin). No control-type restriction here.
        if (sessionRole === "admin") {
            const [mRows] = await con.query(
                "SELECT id, name FROM users WHERE admin_id=? AND status='ACTIVE'", 
                [adminId]
            );
            members = mRows;
        } else {
            const [mRows] = await con.query(
                "SELECT id, name FROM users WHERE admin_id=? AND status='ACTIVE' AND id != ?", 
                [adminId, sessionUserId]
            );
            members = mRows;
        }

        // ================= PAGE SPECIFIC LOGIC (REQUESTS & ANNOUNCEMENTS) =================
        
        if (sessionRole === "user") {
            const [currentUser] = await con.query("SELECT role_id FROM users WHERE id=?", [sessionUserId]);
            if (currentUser.length > 0) {
                const roleId = currentUser[0].role_id;
                const [roleData] = await con.query("SELECT control_type FROM roles WHERE id=?", [roleId]);
                if (roleData.length > 0) {
                    controlType = roleData[0].control_type;
                } else {
                    controlType = "NONE";
                }
            } else {
                controlType = "NONE";
            }
        } else if (sessionRole === "admin") {
            controlType = "ADMIN";
        }


        if (sessionRole === "admin" || controlType === 'ADMIN') {
            
            if (sessionRole === "admin") {
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

        } else if (sessionRole === "user") {
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
            deletionRequests, 
            roles,
            announcements,
            session: req.session
        });

    } catch (err) {
        console.error(err);
        res.send("Error loading notifications");
    }
});

// POST ROUTE: ADD ANNOUNCEMENT (Zero Reload Setup)
router.post('/add-announcement', upload.single('attachment'), async (req, res) => {
    try {
        const { title, description, role_id } = req.body;
        const attachment = req.file ? req.file.filename : null;
        
        const adminId = req.session.adminId;
        const addedBy = req.session.role === 'admin' ? req.session.adminId : req.session.userId;
        const whoAdded = req.session.role.toUpperCase();

        const [result] = await con.query(
            "INSERT INTO announcements (admin_id, added_by, who_added, role_id, title, description, attachment) VALUES (?, ?, ?, ?, ?, ?, ?)",
            [adminId, addedBy, whoAdded, role_id, title, description, attachment]
        );

        // Fetch the inserted record fully mapped to return to frontend for Zero Reload
        const [newAnn] = await con.query(`
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
            WHERE a.id = ?
        `, [result.insertId]);

        req.io.emit('new_announcement', newAnn[0]);

        res.json({ success: true, announcement: newAnn[0] });
    } catch (err) {
        console.error(err);
        res.status(500).json({ success: false, message: "Error adding announcement" });
    }
});

// POST ROUTE: EDIT ANNOUNCEMENT (Zero Reload Setup)
router.post('/edit-announcement/:id', upload.single('attachment'), async (req, res) => {
    try {
        const { title, description, role_id } = req.body;
        const announcementId = req.params.id;
        let query = "UPDATE announcements SET title=?, description=?, role_id=? WHERE id=?";
        let params = [title, description, role_id, announcementId];
        let attachmentName = null;

        if (req.file) {
            attachmentName = req.file.filename;
            query = "UPDATE announcements SET title=?, description=?, role_id=?, attachment=? WHERE id=?";
            params = [title, description, role_id, attachmentName, announcementId];
        }

        await con.query(query, params);
        
        // Fetch the new role name to send to frontend
        let target_role = 'All';
        if (role_id != 0) {
            const [rRows] = await con.query("SELECT role_name FROM roles WHERE id=?", [role_id]);
            if (rRows.length > 0) target_role = rRows[0].role_name;
        }

        const updateData = { id: announcementId, title, description, role_id, target_role, attachment: attachmentName };
        
        req.io.emit('edit_announcement', updateData);

        res.json({ 
            success: true, 
            title, 
            description, 
            role_id, 
            target_role, 
            attachment: attachmentName 
        });
    } catch (err) {
        console.error(err);
        res.status(500).json({ success: false, message: "Error updating announcement" });
    }
});

// GET ROUTE: DELETE ANNOUNCEMENT (Zero Reload Setup)
router.get('/delete-announcement/:id', async (req, res) => {
    try {
        if (req.session.role === 'admin' || req.session.control_type === 'ADMIN') {
            await con.query("DELETE FROM announcements WHERE id=?", [req.params.id]);
            
            req.io.emit('delete_announcement', req.params.id);
            
            res.json({ success: true });
        } else {
            res.status(403).json({ success: false, message: "Unauthorized to delete announcements" });
        }
    } catch (err) {
        console.error(err);
        res.status(500).json({ success: false, message: "Error deleting announcement" });
    }
});

module.exports = router;