const express = require('express');
const router = express.Router();

// Logout Route
// router.get('/logout', (req, res) => {
//     req.session.destroy((err) => {
//         if (err) {
//             console.log("Logout Error:", err);
//             return res.send("Error logging out");
//         }

//         res.clearCookie('connect.sid'); // destroy session cookie
//         res.redirect('/'); // go to signup page
//     });
// });

module.exports = router;
