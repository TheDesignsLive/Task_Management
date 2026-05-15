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

async function sendPushToUsers(userIds, title, body, url = '/') {
    if (!userIds || userIds.length === 0) return;

    const baseUrl   = 'https://tms.thedesigns.live';
    const mobileUrl = 'https://m-tms.thedesigns.live';
    const logoUrl   = `${baseUrl}/images/tms_logo.jpeg`;

    // ✅ Deduplicate — prevents double notifications for same user
    const uniqueIds = [...new Set(userIds.map(id => String(id)))];

    // Pusher Beams limit: 100 users per call
    const chunks = [];
    for (let i = 0; i < uniqueIds.length; i += 100) {
        chunks.push(uniqueIds.slice(i, i + 100));
    }

    await Promise.all(chunks.map(async chunk => {
        try {
            // ✅ ONE single publishToUsers call — web + fcm combined
            // This is the fix: two separate calls caused duplicate/missed notifications
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
                    },
                    data: {
                        url:       `${mobileUrl}${url}`,
                        deep_link: `${mobileUrl}${url}`,
                        icon:      logoUrl,
                    },
                    android: {
                        priority: 'high',
                        ttl: '86400s',
                        notification: {
                            sound:        'default',
                            channelId:    'tms_tasks',
                            priority:     'high',
                            defaultSound: true,
                        },
                    },
                },
            });
            console.log('[Beams] ✅ Push sent to:', chunk);
} catch (err) {
            // Combined call failed — log and move on, never blocks the response
            console.error('[Beams] ❌ Push failed:', err.message);
        }
    }));
}

module.exports = { sendPushToUsers, beamsClient };