library sw;

import 'dart:async';

import 'package:sw_wip/pwa_on_pub/worker.dart';
import 'package:sw_wip/pwa/offline.g.dart';

main(List<String> args) {
  print('SW started.');
  new MyPwaWorker().main();

//  onMessage.listen((ExtendableMessageEvent event) {
//    print('onMessage received ${event.data}');
//    event.source.postMessage('reply from SW');
//    print('replied');
//  });
//
//  onPush.listen((PushEvent event) {
//    print('onPush received: ${event.data}');
//    registration.showNotification('Notification: ${event.data}');
//  });
}

class MyPwaWorker extends PwaWorker {
  PwaCache youtubeImages = new PwaCache(
    'youtube-images',
    maxAge: new Duration(hours: 1),
    maxEntries: 200,
  );

  @override
  void init() {
    super.init();
    route.get('http://localhost:8080/', offline.fastest);
    route.get('https://img.youtube.com/', youtubeImages.cacheFirst);
  }

  @override
  Future install() async {
    await super.install();
    await offline.update(assetUrls,
        purge: true, fetchBefore: assetsLastModified);
  }
}
