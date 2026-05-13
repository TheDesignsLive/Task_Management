// public/service-worker.js
// public/service-worker.js
importScripts('https://js.pusher.com/beams/service-worker.js');

// ✅ Force show notification when tab IS open (browsers skip it by default)
self.addEventListener('push', (event) => {
    // Let Beams handle its own push first — this catches any Beams misses
    if (!event.data) return;

    try {
        const payload = event.data.json();
        const notification = payload?.notification || payload?.data;
        if (!notification || !notification.title) return;

        // ✅ Show even when tab is open
        event.waitUntil(
            self.registration.showNotification(notification.title, {
                body: notification.body || '',
                icon: 'https://tms.thedesigns.live/images/tms_logo.jpeg',
                badge: 'https://tms.thedesigns.live/images/tms_logo.jpeg',
                data: { url: notification.deep_link || 'https://tms.thedesigns.live/home' },
                requireInteraction: false,
                silent: false,
            })
        );
    } catch (e) {
        // Beams formats differently — let Beams handle it
    }
});

// ✅ Notification click handler
self.addEventListener('notificationclick', (event) => {
    event.notification.close();

    const url = (event.notification.data && event.notification.data.url)
              || (event.notification.data && event.notification.data.deep_link)
              || 'https://tms.thedesigns.live/home';

    event.waitUntil(
        clients.matchAll({ type: 'window', includeUncontrolled: true }).then((windowClients) => {
            for (let i = 0; i < windowClients.length; i++) {
                const client = windowClients[i];
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

// ✅ Activate immediately
self.addEventListener('install', () => self.skipWaiting());
self.addEventListener('activate', (event) => event.waitUntil(clients.claim()));