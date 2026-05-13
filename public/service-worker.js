// public/service-worker.js
importScripts('https://js.pusher.com/beams/service-worker.js');

self.addEventListener('notificationclick', (event) => {
    event.notification.close();

    // ✅ Pusher Beams puts the URL in deep_link inside the notification data
    const url = (event.notification.data && event.notification.data.deep_link)
              || 'https://tms.thedesigns.live/home';

    event.waitUntil(
        clients.matchAll({ type: 'window', includeUncontrolled: true }).then((windowClients) => {

            // ✅ Check if any tab of our site is already open
            for (let i = 0; i < windowClients.length; i++) {
                const client = windowClients[i];
                if (client.url.includes('tms.thedesigns.live') && 'focus' in client) {
                    // ✅ Focus the existing tab and navigate it — works in Chrome, Edge, Firefox
                    return client.focus().then(() => {
                        if ('navigate' in client) {
                            return client.navigate(url);
                        }
                    });
                }
            }

            // ✅ No tab open — open a new one
            if (clients.openWindow) {
                return clients.openWindow(url);
            }
        })
    );
});