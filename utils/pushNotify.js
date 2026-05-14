// utils/pushNotify.js desktop version file
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
async function sendPushToUsers(userIds, title, body, url = '/', isMobile = false) {
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
const baseUrl = 'https://tms.thedesigns.live';
const mobileUrl = 'https://m-tms.thedesigns.live';
const logoUrl = `${baseUrl}/images/tms_logo.jpeg`;

await beamsClient.publishToUsers(chunk, {
    web: {
        notification: {
            title,
            body,
            icon: logoUrl,
            deep_link: `${baseUrl}${url}`,
        },
    },
fcm: {
        notification: {
            title,
            body,
            // ✅ FCM icon must be a relative path OR a publicly accessible URL
            // Use desktop URL — always reachable from FCM servers
            icon: logoUrl,
        },
        data: {
            url: `${mobileUrl}${url}`,
            // ✅ Pass icon in data so service worker can use it too
            icon: logoUrl,
            deep_link: `${mobileUrl}${url}`,
        },
        android: {
            priority: 'high',
            ttl: '86400s',
            notification: {
                sound: 'default',
                // ✅ channel_id (snake_case) is the correct FCM field
                channel_id: 'tms_tasks',
                priority: 'high',
                default_sound: true,
                // ✅ Remove icon from here — FCM ignores URL icons in notification block
                // Android uses the app icon from the installed PWA instead
                image: logoUrl,
            },
        },
    },
    apns: {
        aps: {
            alert: { title, body },
            sound: 'default',
            badge: 1,
            contentAvailable: true,
        },
        data: {
            url: `${mobileUrl}${url}`,   // ✅ Opens mobile app URL on iOS
        },
        headers: {
            'apns-priority': '10',
            'apns-expiration': String(Math.floor(Date.now() / 1000) + 86400),
        },
        fcm_options: {
            image: logoUrl,          // ✅ Logo on iOS notification
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