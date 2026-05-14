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
 *
 * ⚠️  Only send the platforms you have configured in Pusher Beams dashboard.
 *     Sending fcm/apns without credentials causes the ENTIRE call to fail,
 *     including web — which breaks desktop-to-desktop notifications too.
 */
async function sendPushToUsers(userIds, title, body, url = '/') {
    if (!userIds || userIds.length === 0) return;

    const baseUrl   = 'https://tms.thedesigns.live';
    const mobileUrl = 'https://m-tms.thedesigns.live';
    const logoUrl   = `${baseUrl}/images/tms_logo.jpeg`;

    // ✅ Deduplicate IDs — prevent double notifications
    const uniqueIds = [...new Set(userIds.map(id => String(id)))];

    // Pusher Beams limit: 100 users per call
    const chunks = [];
    for (let i = 0; i < uniqueIds.length; i += 100) {
        chunks.push(uniqueIds.slice(i, i + 100));
    }

    await Promise.all(chunks.map(async chunk => {
        // ── 1. WEB push (desktop Chrome/Edge/Firefox) ──────────────────────
        // Always safe — web push works as long as Beams instance exists
        try {
            await beamsClient.publishToUsers(chunk, {
                web: {
                    notification: {
                        title,
                        body,
                        icon: logoUrl,
                        deep_link: `${baseUrl}${url}`,
                    },
                },
            });
            console.log('[Beams] ✅ Web push sent to:', chunk);
        } catch (err) {
            console.error('[Beams] ❌ Web push error:', err.message);
        }

        // ── 2. FCM push (Android mobile PWA) ───────────────────────────────
        // Only fires if FCM is configured in Pusher Beams dashboard.
        // If not configured, this block is skipped — web push above still works.
        try {
            await beamsClient.publishToUsers(chunk, {
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
                            imageUrl:     logoUrl,
                        },
                    },
                },
            });
            console.log('[Beams] ✅ FCM push sent to:', chunk);
        } catch (err) {
            // ✅ Silently skip — FCM not configured in Beams dashboard is expected
            // This will NOT affect web/desktop notifications
            console.warn('[Beams] ⚠️ FCM push skipped (configure FCM in Pusher dashboard to enable):', err.message);
        }
    }));
}

module.exports = { sendPushToUsers };