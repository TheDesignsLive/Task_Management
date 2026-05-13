// utils/pushNotify.js
const PusherPushNotifications = require('@pusher/push-notifications-server');

const BeamsClient =
    PusherPushNotifications.default ||
    PusherPushNotifications.Client ||
    PusherPushNotifications;

const beamsClient = new BeamsClient({
    instanceId: '423440a8-1fc5-4373-8e6b-0085dccafc58',
    secretKey: '75EBE2088425312400AD5D15B2476EA23E3CEA61B7DE841FCA0A62E822C3135F',
});

/**
 * Send push notification to specific users only.
 * userIds must match the format used in beams-auth:
 *   - Regular users  → String(userId)   e.g. "42"
 *   - Admins         → "admin_" + adminId  e.g. "admin_5"
 */
async function sendPushToUsers(userIds, title, body, url = '/') {
    if (!userIds || userIds.length === 0) return;

    // ✅ Deduplicate IDs — prevent double notifications
    const uniqueIds = [...new Set(userIds.map(id => String(id)))];

    // Pusher Beams limit: 100 users per call
    const chunks = [];
    for (let i = 0; i < uniqueIds.length; i += 100) {
        chunks.push(uniqueIds.slice(i, i + 100));
    }

    // ✅ All chunks fire at same time — fast even with 200+ users
    await Promise.all(chunks.map(async chunk => {
        try {
 await beamsClient.publishToUsers(chunk, {
    web: {
        notification: {
            title,
            body,
            icon: 'https://tms.thedesigns.live/images/tms_logo.jpeg',
            deep_link: `https://tms.thedesigns.live${url}`,
        },
    },
    fcm: {
        notification: { title, body },
        data: { url: `https://tms.thedesigns.live${url}` },
        android: {
            priority: 'high',                   // ✅ Force immediate delivery on Android
            ttl: '86400s',                       // ✅ Store 24hrs if device offline
            notification: {
                sound: 'default',
                channelId: 'tms_tasks',
                priority: 'high',
                defaultSound: true,
            },
        },
    },
    apns: {
        aps: {
            alert: { title, body },
            sound: 'default',
            badge: 1,
            contentAvailable: true,              // ✅ Wake app in background
        },
        data: { url: `https://tms.thedesigns.live${url}` },
        headers: {
            'apns-priority': '10',               // ✅ Immediate delivery (5=low, 10=high)
            'apns-expiration': String(Math.floor(Date.now() / 1000) + 86400), // 24hr TTL
        },
    },
});
            console.log('[Beams] ✅ Push sent to:', chunk);
        } catch (err) {
            console.error('[Beams] ❌ Push error:', err.message);
        }
    }));
}

module.exports = { sendPushToUsers };