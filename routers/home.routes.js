const express = require('express');
const router = express.Router();

router.get("/home", (req, res) => {
    if (req.session.userId) {
        console.log(req.session);
        return res.render("home");   
    }
    res.redirect("/");
});

module.exports = router;
