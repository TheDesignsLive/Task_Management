const express = require('express');
const router = express.Router();
const con = require('../config/db');


// ================= APPROVE MEMBER =================
router.get('/approve-member/:id', async (req, res) => {

    if (!req.session.role || req.session.role !== 'admin') {
        return res.status(401).json({ success: false, message: 'Unauthorized Action.' });
    }

    const requestId = req.params.id;

    try {
        //  GET REQUEST DATA
        const [rows] = await con.query(
            "SELECT * FROM member_requests WHERE id=? AND status='PENDING'",
            [requestId]
        );

        if (rows.length === 0) {
            return res.json({ success: false, message: 'This request is no longer available or has already been processed.' });
        }

        const request = rows[0];

        //  CHECK DUPLICATE EMAIL IN USERS TABLE
        const [existingUser] = await con.query(
            "SELECT id FROM users WHERE email=?",
            [request.email]
        );

        if (existingUser.length > 0) {
            return res.json({ success: false, message: 'A user with this email address already exists in the system.' });
        }

        //  INSERT INTO USERS TABLE
        await con.query(
            `INSERT INTO users 
            (admin_id, role_id, name, email, password, profile_pic, created_by, status) 
            VALUES (?,?,?,?,?,?,?, 'ACTIVE')`,
            [
                request.admin_id,
                request.role_id,
                request.name,
                request.email,
                request.password,
                request.profile_pic,
                request.requested_by
            ]
        );

        //  UPDATE REQUEST STATUS
        await con.query(
            "UPDATE member_requests SET status='APPROVED' WHERE id=?",
            [requestId]
        );
        // 🔴 AUTO REFRESH FOR ALL USERS (ROLE UPDATED)
        req.io.emit('update_members');
        
        //  DELETE REQUEST AFTER APPROVE
        await con.query(
            "DELETE FROM member_requests WHERE id=?",
            [requestId]
        );
        // 🔴 AUTO REFRESH FOR ALL USERS (ROLE UPDATED)
        req.io.emit('update_members');

        return res.json({ success: true, message: 'The member has been successfully approved and added to the system.' });

    } catch (err) {
        console.error(err);
        res.status(500).json({ success: false, message: 'An error occurred while approving this member. Please try again.' });
    }
});



// ================= REJECT MEMBER =================
router.get('/reject-member/:id', async (req, res) => {

    if (!req.session.role || req.session.role !== 'admin') {
        return res.status(401).json({ success: false, message: 'Unauthorized Action.' });
    }

    const requestId = req.params.id;

    try {
        // 🔹 UPDATE STATUS TO REJECTED
        await con.query(
            "UPDATE member_requests SET status='REJECTED' WHERE id=?",
            [requestId]
        );
        // 🔴 AUTO REFRESH FOR ALL USERS (ROLE UPDATED)
        req.io.emit('update_members');

        //  DELETE REQUEST AFTER REJECT
        await con.query(
            "DELETE FROM member_requests WHERE id=?",
            [requestId]
        );
        // 🔴 AUTO REFRESH FOR ALL USERS (ROLE UPDATED)
        req.io.emit('update_members');

        return res.json({ success: true, message: 'The member request has been rejected and removed.' });

    } catch (err) {
        console.error(err);
        res.status(500).json({ success: false, message: 'An error occurred while rejecting this request. Please try again.' });
    }
});

// ================= CONFIRM DELETION REQUEST =================
router.get('/confirm-deletion/:id', async (req, res) => {
    if (!req.session.role || req.session.role !== 'admin') {
        return res.status(401).json({ success: false, message: 'Unauthorized Action.' });
    }

    const requestId = req.params.id;

    try {
        // 1. Get the request data to find the user's email
        const [rows] = await con.query(
            "SELECT email FROM member_requests WHERE id=? AND request_type='DELETE'",
            [requestId]
        );

        if (rows.length > 0) {
            const userEmail = rows[0].email;

            // 2. Delete the actual user from the users table
            await con.query("DELETE FROM users WHERE email=?", [userEmail]);
            // 🔴 AUTO REFRESH FOR ALL USERS (ROLE UPDATED)
            req.io.emit('update_members');

            // 3. Delete the request from member_requests table
            await con.query("DELETE FROM member_requests WHERE id=?", [requestId]);
            // 🔴 AUTO REFRESH FOR ALL USERS (ROLE UPDATED)
            req.io.emit('update_members');
        }

        return res.json({ success: true, message: 'The member profile has been permanently deleted.' });
    } catch (err) {
        console.error(err);
        res.status(500).json({ success: false, message: 'An error occurred while processing the deletion. Please try again.' });
    }
});

// ================= REJECT DELETION REQUEST =================
router.get('/reject-deletion/:id', async (req, res) => {
    if (!req.session.role || req.session.role !== 'admin') {
        return res.status(401).json({ success: false, message: 'Unauthorized Action.' });
    }

    const requestId = req.params.id;

    try {
        // To reject a deletion request, we simply remove the request from the list.
        // This keeps the member safely in the users table.
        await con.query("DELETE FROM member_requests WHERE id=?", [requestId]);

        // 🔴 AUTO REFRESH FOR ALL USERS (ROLE UPDATED)
        req.io.emit('update_members');

        return res.json({ success: true, message: 'Deletion rejected. The member profile has been preserved.' });
    } catch (err) {
        console.error(err);
        res.status(500).json({ success: false, message: 'An error occurred while rejecting the deletion request. Please try again.' });
    }
});

module.exports = router;