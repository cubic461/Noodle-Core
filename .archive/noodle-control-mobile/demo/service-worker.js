const CACHE_NAME = 'noodlecontrol-pwa-v1';
const OFFLINE_URL = '/offline.html';

// List of files to cache for offline functionality
const STATIC_CACHE_URLS = [
  '/',
  '/index.html',
  '/offline.html',
  '/script.js',
  '/manifest.json',
  'https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500;700&display=swap',
  'https://fonts.googleapis.com/icon?family=Material+Icons'
];

// Install event - cache static resources
self.addEventListener('install', event => {
  console.log('[Service Worker] Install');
  
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then(cache => {
        console.log('[Service Worker] Caching all: app shell and content');
        return cache.addAll(STATIC_CACHE_URLS);
      })
      .then(() => {
        console.log('[Service Worker] Skip waiting on install');
        return self.skipWaiting();
      })
  );
});

// Activate event - clean up old caches
self.addEventListener('activate', event => {
  console.log('[Service Worker] Activate');
  
  event.waitUntil(
    caches.keys()
      .then(keyList => {
        return Promise.all(keyList.map(key => {
          if (key !== CACHE_NAME) {
            console.log('[Service Worker] Removing old cache', key);
            return caches.delete(key);
          }
        }));
      })
      .then(() => {
        console.log('[Service Worker] Claiming clients');
        return self.clients.claim();
      })
  );
});

// Fetch event - serve from cache when offline
self.addEventListener('fetch', event => {
  // Skip cross-origin requests
  if (!event.request.url.startsWith(self.location.origin)) {
    // For external resources, try network first, then cache
    event.respondWith(
      fetch(event.request)
        .catch(() => {
          // If network fails, try to serve from cache
          return caches.match(event.request);
        })
    );
    return;
  }
  
  // For same-origin requests, try cache first, then network
  event.respondWith(
    caches.match(event.request)
      .then(response => {
        // Cache hit - return response
        if (response) {
          console.log('[Service Worker] Serving from cache:', event.request.url);
          return response;
        }
        
        // Not in cache - fetch from network
        console.log('[Service Worker] Fetching from network:', event.request.url);
        return fetch(event.request)
          .then(response => {
            // Check if we received a valid response
            if (!response || response.status !== 200 || response.type !== 'basic') {
              return response;
            }
            
            // Clone the response since it's a stream and can only be consumed once
            const responseToCache = response.clone();
            
            // Add the new response to the cache
            caches.open(CACHE_NAME)
              .then(cache => {
                cache.put(event.request, responseToCache);
              });
            
            return response;
          })
          .catch(error => {
            console.error('[Service Worker] Fetch failed:', error);
            
            // If the request is for a page, serve the offline page
            if (event.request.destination === 'document') {
              return caches.match(OFFLINE_URL);
            }
            
            // For API requests, return a custom offline response
            if (event.request.url.includes('/api/')) {
              return new Response(
                JSON.stringify({
                  error: 'Offline',
                  message: 'No network connection available. Some features may be limited.',
                  data: null
                }),
                {
                  status: 503,
                  statusText: 'Service Unavailable',
                  headers: {
                    'Content-Type': 'application/json'
                  }
                }
              );
            }
          });
      })
  );
});

// Handle background sync for when the app comes back online
self.addEventListener('sync', event => {
  console.log('[Service Worker] Background sync', event.tag);
  
  if (event.tag === 'background-sync') {
    event.waitUntil(
      // Perform any background sync tasks here
      console.log('[Service Worker] Background sync completed')
    );
  }
});

// Handle push notifications
self.addEventListener('push', event => {
  console.log('[Service Worker] Push received');
  
  const options = {
    body: event.data ? event.data.text() : 'New notification from NoodleControl',
    icon: '/icons/icon-192x192.png',
    badge: '/icons/icon-72x72.png',
    vibrate: [100, 50, 100],
    data: {
      dateOfArrival: Date.now(),
      primaryKey: 1
    },
    actions: [
      {
        action: 'explore',
        title: 'Explore',
        icon: '/icons/icon-96x96.png'
      },
      {
        action: 'close',
        title: 'Close',
        icon: '/icons/icon-96x96.png'
      }
    ]
  };
  
  event.waitUntil(
    self.registration.showNotification('NoodleControl', options)
  );
});

// Handle notification click
self.addEventListener('notificationclick', event => {
  console.log('[Service Worker] Notification click received');
  
  event.notification.close();
  
  if (event.action === 'explore') {
    // Open the app
    event.waitUntil(
      clients.openWindow('/')
    );
  }
});