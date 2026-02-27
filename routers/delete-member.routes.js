const express = require('express');
const router = express.Router();
const con = require('../config/db'); // mysql2 promise pool

// DELETE MEMBER (Handles both direct deletion and user requests)
router.get('/delete-member/:id', async (req, res) => {
    try {
        if (!req.session.role) return res.redirect('/');
        
        const memberId = req.params.id;

        if (req.session.role === 'admin') {
            // ADMIN: Direct deletion
            await con.execute('DELETE FROM users WHERE id = ?', [memberId]);
            res.send("<script>alert('Member deleted successfully'); window.location='/view_member';</script>");
        } else if (req.session.role === 'user') {
            // USER: Save request in member_requests table
            
            // 1. Get details of the member to be deleted
            const [memberData] = await con.execute('SELECT * FROM users WHERE id = ?', [memberId]);
            
            if (memberData.length === 0) {
                return res.send("<script>alert('Member not found'); window.location='/view_member';</script>");
            }

            const member = memberData[0];

            // 2. Insert into member_requests with request_type 'DELETE'
            // Assuming your table has these columns based on your signup logic
            await con.execute(
                `INSERT INTO member_requests 
                (admin_id, role_id, request_type, requested_by, name, email, phone, profile_pic, status, created_at) 
                VALUES (?, ?, 'DELETE', ?, ?, ?, ?, ?, 'PENDING', NOW())`,
                [
                    member.admin_id, 
                    member.role_id, 
                    req.session.userId, 
                    member.name, 
                    member.email, 
                    member.phone, 
                    member.profile_pic
                ]
            );

            res.send("<script>alert('Deletion request sent to admin successfully'); window.location='/view_member';</script>");
        }

    } catch (error) {
        console.error('Delete/Request Error:', error);
        res.status(500).send("<script>alert('Operation failed'); window.location='/view_member';</script>");
    }
});

module.exports = router;