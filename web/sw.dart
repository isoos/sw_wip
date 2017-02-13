@JS()
library sw;

import 'dart:async';

import 'package:js/js.dart';

import 'package:sw_wip/service_worker.dart';

@JS('self.console.dir')
external dir(o);

@JS('self.console.dir')
external log([a, b, c, d, e, f]);

main(List<String> args) {
  print('SW started.');

  globalScope.onInstall.listen((InstallEvent event) {
    print('Installing.');
    event.waitUntil(_initCache());
  });

  globalScope.onActivate.listen((ExtendableEvent event) {
    print('Activating.');
  });

  globalScope.onFetch.listen((FetchEvent event) {
    print('fetch request: ${event.request}');
    event.respondWith(_getCachedOrFetch(event.request));
  });

  globalScope.onMessage.listen((ExtendableMessageEvent event) {
    print('onMessage received ${event.data}');
    event.source.postMessage('reply from SW');
    print('replied');
  });

  globalScope.onPush.listen((PushEvent event) {
    print('onPush received: ${event.data}');
    globalScope.registration
        .showNotification('Notification: ${event.data}');
  });
}

Future<Response> _getCachedOrFetch(Request request) async {
  Response r = await globalScope.caches.match(request);
  if (r != null) {
    print('Found in cache: ${request.url} $r');
    return r;
  }
  if (r == null) {
    print('No cached version. Fetching: ${request.url}');
    r = await globalScope.fetch(request);
    print('Got for ${request.url}: ${r}');
  }
  return r;
}

Future _initCache() async {
//  print('Init cache...');
//  Cache cache = await globalScope.caches.open('offline-v1');
//  await cache.addAll([
//    '/',
//    '/main.dart',
//    '/main.dart.js',
//    '/styles.css',
//    '/packages/browser/dart.js',
//  ]);
//  print('Cache initialized.');
}
