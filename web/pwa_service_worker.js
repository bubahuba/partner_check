'use strict';

// Minimal service worker for Safari PWA install (macOS Add to Dock, iOS 16.4+ manifest).
// Flutter's default flutter_service_worker.js is deprecated and self-unregisters.

self.addEventListener('install', (event) => {
  self.skipWaiting();
});

self.addEventListener('activate', (event) => {
  event.waitUntil(self.clients.claim());
});

self.addEventListener('fetch', (event) => {
  event.respondWith(fetch(event.request));
});
