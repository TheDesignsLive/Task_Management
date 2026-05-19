// public/service-worker.js — Desktop version (FINAL CLEAN)

// ❌ DO NOT import Beams service worker (same as mobile)
// importScripts('https://js.pusher.com/beams/service-worker.js'); // REMOVED

// ✅ Activate immediately
self.addEventListener('install', () => self.skipWaiting());
self.addEventListener('activate', (event) => event.waitUntil(clients.claim()));


// ✅ Notification click handler
self.addEventListener('notificationclick', (event) => {
    event.notification.close();

    const url =
        (event.notification.data && event.notification.data.url) ||
        'https://tms.thedesigns.live/home';

    event.waitUntil(
        clients.matchAll({ type: 'window', includeUncontrolled: true }).then((windowClients) => {
            for (let client of windowClients) {
                if (client.url.includes('tms.thedesigns.live') && 'focus' in client) {
                    return client.focus().then(() => {
                        if ('navigate' in client) return client.navigate(url);
                    });
                }
            }
            if (clients.openWindow) return clients.openWindow(url);
        })
    );
});


// ✅ PUSH HANDLER (FULL CONTROL — SAME AS MOBILE)
self.addEventListener('push', (event) => {
    if (!event.data) return;

    event.waitUntil(
        (async () => {
            try {
                const payload = event.data.json();

                // ✅ sender id (backend se)
                const senderId = payload?.data?.sender_id;

                // ✅ apni ID cache se
                const cache = await caches.open('tms-user-data');
                const cachedResponse = await cache.match('/my-id');
                const myId = cachedResponse ? await cachedResponse.text() : null;

                // ✅ SELF-NOTIFICATION BLOCK
                if (senderId && myId && senderId === myId) {
                    console.log('[SW-DESKTOP] Self notification blocked:', myId);
                    return;
                }

                // ✅ Extract notification safely
                const n =
                    payload?.notification ||
                    payload?.data?.notification ||
                    payload?.aps?.alert ||
                    null;

                const title =
                    n?.title ||
                    payload?.title ||
                    payload?.data?.title ||
                    'TMS Workspace';

                const body =
                    n?.body ||
                    payload?.body ||
                    payload?.data?.body ||
                    '';

                const deepLink =
                    payload?.data?.url ||
                    payload?.data?.deep_link ||
                    'https://tms.thedesigns.live/home';

                if (!title) return;

                // ✅ SHOW NOTIFICATION (NO COLLAPSE)
                await self.registration.showNotification(title, {
                    body: body,
                    icon: 'https://tms.thedesigns.live/images/tms_logo.jpeg',
                    badge: 'https://tms.thedesigns.live/images/tms_logo.jpeg',
                    tag: 'tms-task-' + Date.now(), // unique
                    data: { url: deepLink },
                    requireInteraction: false,
                    silent: false,
                });

                // ✅ Send message to open tabs (real-time UI update)
                const windowClients = await clients.matchAll({
                    type: 'window',
                    includeUncontrolled: true,
                });

                windowClients.forEach((client) => {
                    client.postMessage({
                        type: 'BEAMS_PUSH_RECEIVED',
                        title: title,
                        body: body,
                    });
                });

            } catch (err) {
                console.error('[SW-DESKTOP] Push error:', err);
            }
        })()
    );
});