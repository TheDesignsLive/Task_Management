const express = require('express');
const router = express.Router();

router.get("/home", (req, res) => {

    if (!req.session.role) {
        return res.redirect("/");
    }

    res.render("home");  // no need to send members, adminName etc
});

module.exports = router;
