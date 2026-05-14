// public/service-worker.js desktop version file
importScripts('https://js.pusher.com/beams/service-worker.js');

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

// ✅ Required: activate SW immediately so Beams subscription works on first load
// Without these, Chrome waits for old SW to die — Beams breaks on fresh installs
self.addEventListener('install', () => self.skipWaiting());
self.addEventListener('activate', (event) => event.waitUntil(clients.claim()));

// ✅ Show ALL missed notifications when browser was closed
// Without this, Chrome collapses multiple notifications into one (shows only latest)
self.addEventListener('push', (event) => {
    if (!event.data) return;
    try {
        const payload = event.data.json();
        const n = payload?.notification || payload?.data;
        if (!n || !n.title) return;

        // ✅ Unique tag per notification = all notifications show, none replaced
        event.waitUntil(
            self.registration.showNotification(n.title, {
                body:               n.body || '',
                icon:               'https://tms.thedesigns.live/images/tms_logo.jpeg',
                badge:              'https://tms.thedesigns.live/images/tms_logo.jpeg',
                tag:                'tms-' + Date.now(),   // ✅ unique = no collapse
                data:               { url: n.deep_link || 'https://tms.thedesigns.live/home' },
                requireInteraction: false,
                silent:             false,
            })
        );
    } catch (e) {
        // Beams handles its own format — this catches any edge cases
    }
});