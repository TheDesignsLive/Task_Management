//notification.routes.js for desktop
const express = require('express');
const router = express.Router();
const con = require('../config/db');
const multer = require('multer');
const path = require('path');
const { notifyMobile } = require('../utils/notifyMobile'); // ✅ ADD

// ================= MULTER =================
const storage = multer.diskStorage({
    destination: (req, file, cb) => cb(null, 'public/uploads'),
    filename: (req, file, cb) => cb(null, Date.now() + "_" + file.originalname)
});
const upload = multer({ storage });
// ✅ Mobile calls this to save attachment on desktop
router.post('/upload-attachment', upload.single('attachment'), (req, res) => {
    const secret = req.headers['x-mobile-secret'];
    if (secret !== 'tms_mobile_bridge_2026') return res.status(403).json({ success: false });
    if (!req.file) return res.status(400).json({ success: false, message: 'No file received.' });
    return res.json({ success: true, filename: req.file.filename });
});


// =======================================================
// GET NOTIFICATION COUNT (for red badge without refresh)
// =======================================================

router.get('/notification-count', async (req, res) => {

    if (!req.session.role) return res.json({ count: 0 });

    const adminId = req.session.adminId;
    const role = req.session.role;
    const userId = (role === "admin" || role === "owner") ? 0 : req.session.userId;

    try {

        let roleFilter = "";
        let params = [adminId];

        if (role === "user") {

            const [u] = await con.query("SELECT role_id FROM users WHERE id=?", [userId]);

            if (u.length > 0) {
                const roleId = u[0].role_id;
                roleFilter = " AND (a.role_id=? OR a.role_id=0)";
                params.push(roleId);
            }
        }

       // ================= ANNOUNCEMENT COUNT =================
const [annRows] = await con.query(
`
SELECT COUNT(*) as total
FROM announcements a
LEFT JOIN announcement_seen s 
ON a.id = s.announcement_id 
AND s.user_id=? 
AND s.role=? 
AND s.admin_id=?
WHERE a.admin_id=? 
${roleFilter}
AND s.id IS NULL
`,
[userId, role, adminId, ...params]
);

let total = annRows[0].total;


// ================= MEMBER REQUEST COUNT (ADMIN/OWNER ONLY) =================
if(role === "admin" || role === "owner"){

    const [reqRows] = await con.query(
        `
        SELECT COUNT(*) as total
        FROM member_requests
        WHERE admin_id=? AND status='PENDING'
        `,
        [adminId]
    );

    total += reqRows[0].total;
}

res.json({ count: total });

    } catch (err) {
        console.error(err);
        res.json({ count: 0 });
    }
});



// =======================================================
// NOTIFICATION PAGE
// =======================================================

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

        const [aRows] = await con.query(
            "SELECT name FROM admins WHERE id=?",
            [adminId]
        );

        if (aRows.length > 0) adminName = aRows[0].name;


        const [rRows] = await con.query(
            "SELECT id, role_name FROM roles WHERE admin_id=?",
            [adminId]
        );

        roles = rRows;


        // ================= MEMBERS =================

        if (sessionRole === "admin" || sessionRole === "owner") {

            const [mRows] = await con.query(
                "SELECT id,name FROM users WHERE admin_id=? AND status='ACTIVE'",
                [adminId]
            );

            members = mRows;

        } else {

            const [mRows] = await con.query(
                "SELECT id,name FROM users WHERE admin_id=? AND status='ACTIVE' AND id!=?",
                [adminId, sessionUserId]
            );

            members = mRows;
        }



        // ================= CONTROL TYPE =================

        if (sessionRole === "user") {

            const [currentUser] = await con.query(
                "SELECT role_id FROM users WHERE id=?",
                [sessionUserId]
            );

            if (currentUser.length > 0) {

                const roleId = currentUser[0].role_id;

                const [roleData] = await con.query(
                    "SELECT control_type FROM roles WHERE id=?",
                    [roleId]
                );

                controlType = roleData.length > 0
                    ? roleData[0].control_type
                    : "NONE";

            } else {
                controlType = "NONE";
            }

        } else {
            controlType = "ADMIN";
        }



        // ================= ADMIN REQUESTS =================

        if (sessionRole === "admin" || sessionRole === "owner") {

            const [reqRows] = await con.query(
                `
                SELECT mr.*,r.role_name,u.name AS requested_by_name
                FROM member_requests mr
                JOIN roles r ON r.id=mr.role_id
                JOIN users u ON u.id=mr.requested_by
                WHERE mr.admin_id=? 
                AND mr.status='PENDING' 
                AND mr.request_type='ADD'
                ORDER BY mr.created_at DESC
                `,
                [adminId]
            );

            memberRequests = reqRows;



            const [delRows] = await con.query(
                `
                SELECT mr.*,r.role_name,u.name AS requested_by_name
                FROM member_requests mr
                JOIN roles r ON r.id=mr.role_id
                JOIN users u ON u.id=mr.requested_by
                WHERE mr.admin_id=? 
                AND mr.status='PENDING' 
                AND mr.request_type='DELETE'
                ORDER BY mr.created_at DESC
                `,
                [adminId]
            );

            deletionRequests = delRows;
        }



        // ================= ANNOUNCEMENTS =================

        if (sessionRole === "admin" || sessionRole === "owner") {

            const [annRows] = await con.query(
                `
                SELECT a.*,
                IF(a.role_id=0,'All',r.role_name) AS target_role,
                CASE
                    WHEN a.who_added='ADMIN' THEN CONCAT(adm.name,' (Admin)')
                    WHEN a.who_added='OWNER' THEN CONCAT(usr.name,' (Admin)')
                    ELSE usr.name
                END AS added_by_name
                FROM announcements a
                LEFT JOIN roles r ON a.role_id=r.id
                LEFT JOIN admins adm ON a.added_by=adm.id AND a.who_added='ADMIN'
                LEFT JOIN users usr ON a.added_by=usr.id AND (a.who_added='USER' OR a.who_added='OWNER')
                WHERE a.admin_id=?
                ORDER BY a.created_at DESC
                `,
                [adminId]
            );

            announcements = annRows;

        } else {

            const [annRows] = await con.query(
                `
                SELECT a.*,
                CASE
                    WHEN a.who_added='ADMIN' THEN CONCAT(adm.name,' (Admin)')
                    WHEN a.who_added='OWNER' THEN CONCAT(usr.name,' (Admin)')
                    ELSE usr.name
                END AS added_by_name
                FROM announcements a
                LEFT JOIN admins adm ON a.added_by=adm.id AND a.who_added='ADMIN'
                LEFT JOIN users usr ON a.added_by=usr.id AND (a.who_added='USER' OR a.who_added='OWNER')
                WHERE a.admin_id=? 
                AND (a.role_id=? OR a.role_id=0)
                ORDER BY a.created_at DESC
                `,
                [adminId, req.session.role_id]
            );

            announcements = annRows;
        }



        // ================= MARK AS SEEN =================

        const role = sessionRole;
        const userId = (role === "admin" || role === "owner") ? 0 : sessionUserId;

        for (let ann of announcements) {

            await con.query(
                `
                INSERT IGNORE INTO announcement_seen
                (announcement_id,user_id,role,admin_id)
                VALUES (?,?,?,?)
                `,
                [ann.id, userId, role, adminId]
            );
        }



        res.render('notifications', {
            members,
            adminName,
            memberRequests,
            deletionRequests,
            roles,
            announcements,
            session: req.session,
            activePage: "notifications"
        });

    } catch (err) {
        console.error(err);
        res.send("Error loading notifications");
    }
});



// =======================================================
// ADD ANNOUNCEMENT
// =======================================================

router.post('/add-announcement', upload.single('attachment'), async (req, res) => {
    try {
        const { title, description, role_id } = req.body;
        const attachment = req.file ? req.file.filename : null;
        const adminId = req.session.adminId;
        const addedBy = req.session.role === 'admin' ? req.session.adminId : req.session.userId;
        const whoAdded = req.session.role.toUpperCase();

        const [result] = await con.query(
            "INSERT INTO announcements (admin_id, added_by, who_added, role_id, title, description, attachment) VALUES (?,?,?,?,?,?,?)",
            [adminId, addedBy, whoAdded, role_id, title, description, attachment]);

        // Mark as seen by poster
        const userId = (req.session.role === 'admin' || req.session.role === 'owner') ? 0 : req.session.userId;
        await con.query(
            "INSERT IGNORE INTO announcement_seen (announcement_id, user_id, role, admin_id) VALUES (?,?,?,?)",
            [result.insertId, userId, req.session.role, adminId]);

        // Fetch full row with both target_role and target_team_name so desktop + mobile clients both work
        const [rows] = await con.query(`
            SELECT a.*, IF(a.role_id=0,'All',r.role_name) AS target_role,
            IF(a.role_id=0,'All Members',t.name) AS target_team_name,
            CASE WHEN a.who_added='ADMIN' THEN CONCAT(adm.name,' (Admin)')
                 WHEN a.who_added='OWNER' THEN CONCAT(usr.name,' (Admin)')
                 ELSE usr.name END AS added_by_name
            FROM announcements a
            LEFT JOIN roles r ON a.role_id=r.id
            LEFT JOIN teams t ON a.role_id=t.id
            LEFT JOIN admins adm ON a.added_by=adm.id AND a.who_added='ADMIN'
            LEFT JOIN users usr ON a.added_by=usr.id AND (a.who_added='USER' OR a.who_added='OWNER')
            WHERE a.id=?`, [result.insertId]);

        const ann = rows[0];
        req.io.emit('new_announcement', ann);
        notifyMobile('announcement_add', { id: ann.id });

        res.json({ success: true, announcement: ann });
    } catch (err) {
        console.error(err);
        res.status(500).json({ success: false });
    }
});

// GET ROUTE: DELETE ANNOUNCEMENT (Zero Reload Setup)
router.get('/delete-announcement/:id', async (req, res) => {
    try {
        if (req.session.role !== 'admin' && req.session.role !== 'owner' && req.session.control_type !== 'ADMIN') {
            return res.status(403).json({ success: false, message: 'Unauthorized' });
        }
        const id = req.params.id;
        // Verify ownership
        const [check] = await con.query(
            "SELECT id FROM announcements WHERE id=? AND admin_id=?", [id, req.session.adminId]);
        if (!check.length) return res.status(404).json({ success: false });

        await con.query("DELETE FROM announcements WHERE id=? AND admin_id=?", [id, req.session.adminId]);
        req.io.emit('delete_announcement', id);
        notifyMobile('announcement_delete', { id });
        res.json({ success: true });
    } catch (err) {
        console.error(err);
        res.status(500).json({ success: false });
    }
});

// POST ROUTE: EDIT ANNOUNCEMENT (Zero Reload Setup)
router.post('/edit-announcement/:id', upload.single('attachment'), async (req, res) => {
    try {
        const { title, description, role_id } = req.body;
        const announcementId = req.params.id;
        const adminId = req.session.adminId;

        // Verify ownership
        const [check] = await con.query(
            "SELECT id FROM announcements WHERE id=? AND admin_id=?", [announcementId, adminId]);
        if (!check.length) return res.status(404).json({ success: false });

        if (req.file) {
            await con.query(
                "UPDATE announcements SET title=?, description=?, role_id=?, attachment=? WHERE id=? AND admin_id=?",
                [title, description, role_id, req.file.filename, announcementId, adminId]);
        } else {
            await con.query(
                "UPDATE announcements SET title=?, description=?, role_id=? WHERE id=? AND admin_id=?",
                [title, description, role_id, announcementId, adminId]);
        }

        // Fetch fresh row with both field name variants
        const [rows] = await con.query(`
            SELECT a.*, IF(a.role_id=0,'All',r.role_name) AS target_role,
            IF(a.role_id=0,'All Members',t.name) AS target_team_name,
            CASE WHEN a.who_added='ADMIN' THEN CONCAT(adm.name,' (Admin)')
                 WHEN a.who_added='OWNER' THEN CONCAT(usr.name,' (Admin)')
                 ELSE usr.name END AS added_by_name
            FROM announcements a
            LEFT JOIN roles r ON a.role_id=r.id
            LEFT JOIN teams t ON a.role_id=t.id
            LEFT JOIN admins adm ON a.added_by=adm.id AND a.who_added='ADMIN'
            LEFT JOIN users usr ON a.added_by=usr.id AND (a.who_added='USER' OR a.who_added='OWNER')
            WHERE a.id=?`, [announcementId]);

        const ann = rows[0];
        req.io.emit('edit_announcement', ann);
        notifyMobile('announcement_edit', { id: announcementId });

        res.json({ success: true, title, description,
            role_id, target_role: ann.target_role, attachment: ann.attachment || null });
    } catch (err) {
        console.error(err);
        res.status(500).json({ success: false });
    }
});


module.exports = router;