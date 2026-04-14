const express = require('express');
const router = express.Router();
const con = require('../config/db');

// ==========================================
// 1. MASTER PANEL HOME (ALL COMPANIES)
// Matches: http://localhost:3000/masterpage
// ==========================================
router.get('/', async (req, res) => {
    if (!req.session.role) return res.redirect('/');

    try {
        // Optimized query to fetch all companies and count their data instantly
        const [companies] = await con.query(`
            SELECT 
                a.id, 
                a.name as admin_name, 
                a.company_name, 
                a.email,
                (SELECT COUNT(*) FROM users WHERE admin_id = a.id) as total_users,
                (SELECT COUNT(*) FROM teams WHERE admin_id = a.id) as total_teams,
                (SELECT COUNT(*) FROM tasks WHERE admin_id = a.id) as total_tasks
            FROM admins a
            ORDER BY a.id DESC
        `);

        res.render('master_panel', {
            session: req.session,
            companies,
            activePage: 'master'
        });

    } catch (err) {
        console.error(err);
        res.status(500).send("Database Error loading Master Panel");
    }
});

// ==========================================
// 2. API TO FETCH EXPANDED DETAILS (AJAX)
// Matches: http://localhost:3000/masterpage/api/company-details/:id
// ==========================================
router.get('/api/company-details/:id', async (req, res) => {
    if (!req.session.role) return res.status(401).json({ success: false });
    
    const adminId = req.params.id;

    try {
        // Fetch Users + Their Roles
        const [users] = await con.query(`
            SELECT u.id, u.name, u.email, u.phone, u.status, r.role_name, r.control_type 
            FROM users u 
            LEFT JOIN roles r ON u.role_id = r.id 
            WHERE u.admin_id = ?
        `, [adminId]);

        // Fetch Teams with User Count
        const [teams] = await con.query(`
            SELECT t.id, t.name, t.created_at,
            (SELECT COUNT(*) FROM roles r JOIN users u ON u.role_id = r.id WHERE r.team_id = t.id AND u.admin_id = ?) as user_count
            FROM teams t 
            WHERE t.admin_id = ?
        `, [adminId, adminId]);

        // Fetch All Tasks
        const [tasks] = await con.query(`
            SELECT id, title, description, priority, status, section, DATE_FORMAT(due_date, '%Y-%m-%d') as due_date
            FROM tasks 
            WHERE admin_id = ? 
            ORDER BY created_at DESC
        `, [adminId]);

        res.json({ success: true, users, teams, tasks });

    } catch (err) {
        console.error(err);
        res.status(500).json({ success: false });
    }
});

// ==========================================
// 3. NEW TAB IMPERSONATION REDIRECT
// Matches: http://localhost:3000/masterpage/impersonate/:id
// ==========================================
router.get('/impersonate/:id', async (req, res) => {
    if (!req.session.role) return res.redirect('/');
    
    try {
        const targetAdminId = req.params.id;
        
        // Save the master session ID so they can revert back later if needed
        req.session.masterId = req.session.userId || req.session.adminId; 
        
        // Override the current session to become the Target Admin
        req.session.adminId = parseInt(targetAdminId);
        req.session.userId = null; 
        req.session.role = 'admin'; 
        req.session.control_type = 'ADMIN';
        
        // Because this was opened in target="_blank", this redirects the NEW tab to home
        res.redirect('/home');
    } catch (err) {
        console.error(err);
        res.status(500).send("Impersonation Error");
    }
});

module.exports = router;