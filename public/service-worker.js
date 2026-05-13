// public/service-worker.js
importScripts('https://js.pusher.com/beams/service-worker.js');

self.addEventListener('notificationclick', (event) => {
    event.notification.close();

    // ✅ Use deep_link from notification data if present
    const url = event.notification.data?.url
             || event.notification.data?.deep_link
             || 'https://tms.thedesigns.live/home';

    event.waitUntil(
        clients.matchAll({ type: 'window', includeUncontrolled: true }).then((windowClients) => {
            for (const client of windowClients) {
                if (client.url.includes('tms.thedesigns.live') && 'focus' in client) {
                    client.focus();
                    client.navigate(url);
                    return;
                }
            }
            if (clients.openWindow) return clients.openWindow(url);
        })
    );
});