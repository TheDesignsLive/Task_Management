// routers/pusher-auth.routes.js — Desktop NEW FILE
const express = require('express');
const router  = express.Router();
const { pusher } = require('../utils/pushNotify');

router.post('/pusher/auth', (req, res) => {
  if (!req.session.role) return res.status(401).send('Unauthorized');

  const socketId = req.body.socket_id;
  const channel  = req.body.channel_name;

  const role    = req.session.role;
  const myId    = role === 'admin'
    ? 'admin_' + req.session.adminId
    : String(req.session.userId);

  if (channel !== 'private-user-' + myId) {
    return res.status(403).send('Forbidden');
  }

  const auth = pusher.authorizeChannel(socketId, channel);
  res.send(auth);
});

module.exports = router;