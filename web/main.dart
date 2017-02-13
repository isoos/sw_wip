import 'dart:html';

import 'package:sw_wip/service_worker.dart' as sw;

main() async {
  querySelector('#output').text = 'Your Dart app is running.';
  try {
    await sw.container.register('sw.dart.js');
    print('registered');

    sw.ServiceWorkerRegistration registration = await sw.container.ready;
    print('ready');

    sw.container.onMessage.listen((MessageEvent event) {
      print('reply received: ${event.data}');
    });

    sw.ServiceWorker active = registration.active;
    active.postMessage('x');
    print('sent');

    sw.PushSubscription subs = await registration.pushManager
        .subscribe(new sw.PushSubscriptionOptions(userVisibleOnly: true));
    print('endpoint: ${subs.endpoint}');

  } catch (e) {
    print('error: $e');
  }
}
