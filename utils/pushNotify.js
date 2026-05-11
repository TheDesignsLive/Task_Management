//pushNotify.js in utils
const PusherPushNotifications = require('@pusher/push-notifications-server');

const BeamsClient = PusherPushNotifications.default || PusherPushNotifications.Client || PusherPushNotifications;

const beamsClient = new BeamsClient({
    instanceId: '423440a8-1fc5-4373-8e6b-0085dccafc58',
    secretKey:  '75EBE2088425312400AD5D15B2476EA23E3CEA61B7DE841FCA0A62E822C3135F',
});

async function sendPushToUsers(userIds, title, body, url = '/') {
    if (!userIds || userIds.length === 0) return;

    // ✅ Match the format used in beams-auth:
    // Regular users → String(id), Admins → "admin_" + id
    // For regular user notifications, just use the userId directly:
    const chunks = [];
    for (let i = 0; i < userIds.length; i += 100) {
        chunks.push(userIds.slice(i, i + 100));
    }

    for (const chunk of chunks) {
        try {
            // publishToUsers uses the authenticated user IDs (not interests)
            await beamsClient.publishToUsers(
                chunk.map(id => String(id)), // must match setUserId value
                {
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
                    },
                    apns: {
                        aps: { alert: { title, body }, sound: 'default' },
                        data: { url: `https://tms.thedesigns.live${url}` },
                    },
                }
            );
            console.log('[Beams] ✅ Push sent to users:', chunk);
        } catch (err) {
            console.error('[Beams] ❌ Push error:', err.message);
        }
    }
}

module.exports = { sendPushToUsers };