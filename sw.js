// ═══════════════════════════════════════════════════════════════════════════
// CUME — Service Worker
// Cache simples: guarda o index.html e ícones pra abrir offline e
// deixar o app rodar mesmo sem internet (dados do Supabase continuam
// exigindo conexão, mas o app carrega e mostra último estado salvo).
// ═══════════════════════════════════════════════════════════════════════════

const CACHE = 'cume-v1';
const ASSETS = [
  './',
  './index.html',
  './manifest.json',
  './icon-192.png',
  './icon-512.png',
  './apple-touch-icon.png'
];

self.addEventListener('install', (ev) => {
  ev.waitUntil(
    caches.open(CACHE).then(c => c.addAll(ASSETS)).then(() => self.skipWaiting())
  );
});

self.addEventListener('activate', (ev) => {
  ev.waitUntil(
    caches.keys().then(names =>
      Promise.all(names.filter(n => n !== CACHE).map(n => caches.delete(n)))
    ).then(() => self.clients.claim())
  );
});

self.addEventListener('fetch', (ev) => {
  const req = ev.request;
  const url = new URL(req.url);

  // Supabase/APIs externas: sempre network (não cachear dados)
  if (url.hostname.includes('supabase.co') ||
      url.hostname.includes('cdnjs.cloudflare.com') ||
      url.hostname.includes('cdn.jsdelivr.net') ||
      url.hostname.includes('fonts.googleapis.com') ||
      url.hostname.includes('fonts.gstatic.com')) {
    return; // deixa o browser tratar normalmente
  }

  // App shell: cache-first, atualiza em background
  if (req.method === 'GET') {
    ev.respondWith(
      caches.match(req).then(cached => {
        const net = fetch(req).then(resp => {
          if (resp && resp.ok && resp.type === 'basic') {
            const clone = resp.clone();
            caches.open(CACHE).then(c => c.put(req, clone));
          }
          return resp;
        }).catch(() => cached);
        return cached || net;
      })
    );
  }
});
