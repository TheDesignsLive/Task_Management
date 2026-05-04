const express = require('express');
const router = express.Router();
const con = require('../config/db');
const { notifyMobile } = require('../utils/notifyMobile'); // ✅ ADD

// ================= VIEW TEAMS =================
router.get('/view-teams', async (req, res) => {

    if (!req.session.role) {
        return res.redirect('/');
    }

    let teams = [];
    let members = [];
    let adminId = null;
    let adminName = null;

    try {

         adminId = req.session.adminId;
        // ================= ADMIN =================
        if (req.session.role === "admin") {

           

            // Admin name
            const [aRows] = await con.query(
                "SELECT name FROM admins WHERE id=?",
                [adminId]
            );
            if (aRows.length > 0) adminName = aRows[0].name;

            // Members (users under admin)
            const [mRows] = await con.query(
                "SELECT id, name FROM users WHERE admin_id=? AND status='ACTIVE'",
                [adminId]
            );
            members = mRows;

            // Teams (admin specific)
            const [tRows] = await con.query(
                "SELECT * FROM teams WHERE admin_id=? ORDER BY id DESC",
                [adminId]
            );
            teams = tRows;
        }

        // ================= OWNER =================
        else if (req.session.role === "owner") {

            const ownerId = req.session.userId;

            // Owner name (from users table)
            const [oRows] = await con.query(
                "SELECT name FROM users WHERE id=?",
                [ownerId]
            );
            if (oRows.length > 0) adminName = oRows[0].name;

            // Owner sees ALL users
            const [mRows] = await con.query(
    "SELECT id, name FROM users WHERE admin_id=? AND status='ACTIVE'",
    [adminId]
);

            // Owner sees ALL teams
        const [tRows] = await con.query(
    "SELECT * FROM teams WHERE admin_id=? ORDER BY id DESC",
    [adminId]
);
            teams = tRows;
        }

        res.render('view_teams', {
            teams,
            members,
            adminName,
            session: req.session,
            activePage: "teams"
        });

    } catch (err) {
        console.error(err);
        res.send("Error loading teams");
    }
});


// ================= ADD TEAM =================
router.post('/add-team', async (req, res) => {
    try {

        if (!req.session.role) {
            return res.json({ success: false, message: 'Unauthorized' });
        }

        const { name } = req.body;

        if (!name) {
            return res.json({ success: false, message: 'Team name required' });
        }

        // ADMIN → save admin_id
        if (req.session.role === "admin") {

            const adminId = req.session.adminId;

            await con.execute(
                "INSERT INTO teams (admin_id, name) VALUES (?, ?)",
                [adminId, name]
            );
        }

        // OWNER → admin_id NULL or 0
        else if (req.session.role === "owner") {

            await con.execute(
                "INSERT INTO teams (admin_id, name) VALUES (?, ?)",
                [req.session.adminId, name]// owner creates global team
            );
        }
req.io.emit('update_teams');
        notifyMobile('teams'); // ✅ PUSH TO MOBILE
        res.json({ success: true, message: 'Team successfully created' });

    } catch (err) {
        console.error(err);
        res.status(500).json({ success: false, message: 'Error creating team' });
    }
});


// ================= EDIT TEAM =================
router.post('/edit-team/:id', async (req, res) => {
    try {

        if (!req.session.role) {
            return res.json({ success: false, message: 'Unauthorized' });
        }

        const teamId = req.params.id;
        const { name } = req.body;

        if (!name) {
            return res.json({ success: false, message: 'Team name required' });
        }

        // ADMIN → only own teams
        if (req.session.role === "admin") {

            const adminId = req.session.adminId;

            await con.query(
                "UPDATE teams SET name=? WHERE id=? AND admin_id=?",
                [name, teamId, adminId]
            );
        }

        // OWNER → can edit ANY team
        else if (req.session.role === "owner") {

            await con.query(
                "UPDATE teams SET name=? WHERE id=?",
                [name, teamId]
            );
        }

 req.io.emit('update_teams');
        notifyMobile('teams'); // ✅ PUSH TO MOBILE
        res.json({ success: true, message: 'Team successfully updated' });

    } catch (err) {
        console.error(err);
        res.status(500).json({ success: false, message: 'Database Error' });
    }
});


// ================= DELETE TEAM =================
router.get('/delete-team/:id', async (req, res) => {
    try {

        if (!req.session.role) {
            return res.json({ success: false, message: 'Unauthorized' });
        }

        const teamId = req.params.id;

        // ADMIN → delete only own team
        if (req.session.role === "admin") {

            const adminId = req.session.adminId;

            await con.execute(
                "DELETE FROM teams WHERE id=? AND admin_id=?",
                [teamId, adminId]
            );
        }

        // OWNER → delete ANY team
        else if (req.session.role === "owner") {

            await con.execute(
                "DELETE FROM teams WHERE id=?",
                [teamId]
            );
        }

req.io.emit('update_teams');
        notifyMobile('teams'); // ✅ PUSH TO MOBILE
        res.json({ success: true, message: 'Team successfully deleted' });

    } catch (err) {
        console.error(err);
        res.status(500).json({ success: false, message: 'Error deleting team' });
    }
});

module.exports = router;
