import 'dart:async';
import 'dart:html' show MessageEvent;

import 'package:angular2/core.dart';
import 'package:service_worker/window.dart' as sw;
import 'package:sw_wip/pwa_on_pub/client.dart';

@Component(
  selector: 'my-app',
  templateUrl: 'app_component.html',
)
class AppComponent implements AfterViewInit {
  String log = '';
  PwaClient pwaClient;

  // AppComponent(this.pwaClient);

  @override
  void ngAfterViewInit() {
    _initSw();
    // _log('ready ${pwaClient}');
  }

  void _log(String text) {
    log += '$text\n';
  }

  Future _initSw() async {
    try {
      await sw.register('sw.dart.js');
      _log('registered');

      sw.ServiceWorkerRegistration registration = await sw.ready;
      _log('ready');

      sw.onMessage.listen((MessageEvent event) {
        _log('message reply received: ${event.data}');
      });

      sw.ServiceWorker active = registration.active;
      active.postMessage('x');
      _log('postMessage sent');

      sw.PushSubscription subs = await registration.pushManager
          .subscribe(new sw.PushSubscriptionOptions(userVisibleOnly: true));
      _log('subscription endpoint: ${subs.endpoint}');
    } catch (e) {
      _log('error: $e');
    }
  }
}
