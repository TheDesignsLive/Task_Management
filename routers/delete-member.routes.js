const express = require('express');
const router = express.Router();
const con = require('../config/db'); // mysql2 promise pool

// DELETE MEMBER (Handles both direct deletion and user requests)
router.get('/delete-member/:id', async (req, res) => {
    try {
        if (!req.session.role) return res.json({ success: false, message: 'Unauthorized' });
        
        const memberId = req.params.id;

        if (req.session.role === 'admin') {
            // ADMIN: Direct deletion
            await con.execute('DELETE FROM users WHERE id = ?', [memberId]);
            req.io.emit('update_members');
            res.json({ success: true, message: 'Member has been removed successfully.' });
        } else if (req.session.role === 'user') {
            // USER: Save request in member_requests table
            
            // 1. Get details of the member to be deleted
            const [memberData] = await con.execute('SELECT * FROM users WHERE id = ?', [memberId]);
            
            if (memberData.length === 0) {
                return res.json({ success: false, message: 'Member not found' });
            }

            const member = memberData[0];

            // 2. Insert into member_requests with request_type 'DELETE'
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
            req.io.emit('update_members');
            res.json({ success: true, message: 'Deletion request sent to admin successfully.' });
        }

    } catch (error) {
        console.error('Delete/Request Error:', error);
        res.status(500).json({ success: false, message: 'Operation failed' });
    }
});

module.exports = router;