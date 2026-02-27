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
            res.send(`
                <div style="position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.6); backdrop-filter: blur(4px); display: flex; justify-content: center; align-items: center; z-index: 9999; font-family: Arial, sans-serif;">
                    <div style="background: white; width: 380px; padding: 30px; border-radius: 12px; text-align: center; box-shadow: 0 15px 40px rgba(0,0,0,0.25);">
                        <div style="color: #d9534f; font-size: 50px; margin-bottom: 15px;">
                            <i class="fa-solid fa-circle-check"></i>
                        </div>
                        <h3 style="margin-top: 0; color: #333;">Deleted!</h3>
                        <p style="color: #555; font-size: 15px; margin-bottom: 25px;">Member has been removed successfully.</p>
                        <button onclick="window.location='/view_member'" style="width: 100%; height: 44px; background-color: #d9534f; color: white; border: none; border-radius: 8px; font-weight: bold; cursor: pointer; font-size: 15px;">Done</button>
                    </div>
                </div>
            `);
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
            res.send(`
                <div style="position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.6); backdrop-filter: blur(4px); display: flex; justify-content: center; align-items: center; z-index: 9999; font-family: Arial, sans-serif;">
                    <div style="background: white; width: 380px; padding: 30px; border-radius: 12px; text-align: center; box-shadow: 0 15px 40px rgba(0,0,0,0.25);">
                        <h3 style="margin-top: 0; color: #095959;">Success!</h3>
                        <p style="color: #555; font-size: 15px; margin-bottom: 25px;">Deletion request sent to admin successfully.</p>
                        <button onclick="window.location='/view_member'" style="width: 100%; height: 44px; background-color: #095959; color: white; border: none; border-radius: 8px; font-weight: bold; cursor: pointer; font-size: 15px; transition: 0.2s;">Okay</button>
                    </div>
                </div>
            `);
        }

    } catch (error) {
        console.error('Delete/Request Error:', error);
        res.status(500).send("<script>alert('Operation failed'); window.location='/view_member';</script>");
    }
});

module.exports = router;