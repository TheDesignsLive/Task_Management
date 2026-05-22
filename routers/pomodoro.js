const express = require('express');
const router = express.Router();
// ── POMODORO DONE — send push to self ──
router.post('/send-pomodoro-done', async (req, res) => {
  if (!req.session.role) return res.status(403).json({ success: false });

  try {
    const { interest } = req.body;
    if (!interest) return res.status(400).json({ success: false });

    const { beamsClient } = require('../utils/pushNotify');

    await beamsClient.publishToInterests([interest], {
      web: {
        notification: {
          title: '🍅 Pomodoro Done!',
          body: 'Your timer has ended !',
          icon: 'https://tms.thedesigns.live/images/tms_logo.jpeg',
          deep_link: 'https://tms.thedesigns.live',
        }
      },
      fcm: {
        notification: {
          title: '🍅 Pomodoro Done!',
          body: 'Your timer has ended !',
        },
        data: { type: 'pomodoro' }
      },
      apns: {
        aps: {
          alert: {
            title: '🍅 Pomodoro Done!',
            body: 'Your timer has ended !',
          },
          sound: 'default'
        }
      }
    });

    console.log('[Pomodoro] ✅ Push sent to:', interest);
    res.json({ success: true });

  } catch (err) {
    console.error('[Pomodoro] ❌ Push failed:', err.message);
    res.status(500).json({ success: false });
  }
});
module.exports = router;