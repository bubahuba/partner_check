'use strict';

// Minimal service worker for Safari PWA install (macOS Add to Dock, iOS 16.4+ manifest).
// Flutter's default flutter_service_worker.js is deprecated and self-unregisters.

self.addEventListener('install', (event) => {
  self.skipWaiting();
});

self.addEventListener('activate', (event) => {
  event.waitUntil(self.clients.claim());
});

// No fetch handler: passthrough fetch() rejects on network errors and breaks
// navigation (FetchEvent "Failed to fetch"). Install + activate are enough for
// Safari/macOS PWA install eligibility; the browser handles requests normally.
