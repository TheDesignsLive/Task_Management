// Service Worker (Basic version)
self.addEventListener('install', (event) => {
  console.log('Service Worker installed');
});

self.addEventListener('fetch', (event) => {
  // Filhal ye sirf requests ko pass hone dega
  event.respondWith(fetch(event.request));
});