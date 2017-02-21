library pwa_worker;

import 'dart:async';

import 'package:service_worker/worker.dart';

part 'src/cache.dart';
part 'src/route.dart';

class PwaWorker {
  Route route = new Route();
  PwaCache offline = new PwaCache(
    'pwa-offline',
    populateOnFetch: true,
  );

  void init() {
    print('PWA init.');
  }

  Future install() async {
    print('PWA installing.');
  }

  Future activate() async {
    print('PWA activating.');
  }

  void main() {
    init();

    onInstall.listen((InstallEvent event) {
      event.waitUntil(install());
    });

    onActivate.listen((ExtendableEvent event) {
      event.waitUntil(activate());
    });

    onFetch.listen((FetchEvent event) {
      Future<Response> f;
      if (route == null) {
        f = fetch(event.request);
      } else {
        f = route.respond(event.request);
      }
      event.respondWith(f);
    });
  }
}
