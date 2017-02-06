library service_worker;

import 'dart:async';

import 'package:js/js.dart';

import 'src/js_async_adapter.dart';
import 'src/js_facade/service_worker_api.dart' as js;

class ServiceWorkerGlobalScope {
  static ServiceWorkerGlobalScope _instance =
      new ServiceWorkerGlobalScope._(js.globalScope);

  js.ServiceWorkerGlobalScope _delegate;
  CacheStorage _caches;
  ServiceWorkerClients _clients;
  ServiceWorkerRegistration _registration;
  Stream<ExtendableEvent> _onActivate;
  Stream<FetchEvent> _onFetch;
  Stream<InstallEvent> _onInstall;
  Stream<ExtendableMessageEvent> _onMessage;
  Stream<NotificationEvent> _onNotificationClick;
  Stream<PushEvent> _onPush;
  Stream<PushEvent> _onPushSubscriptionChange;

  ServiceWorkerGlobalScope._(this._delegate);
  factory ServiceWorkerGlobalScope() => _instance;

  /// Contains the CacheStorage object associated with the service worker.
  CacheStorage get caches => _caches ??= new CacheStorage._(_delegate.caches);

  /// Contains the Clients object associated with the service worker.
  ServiceWorkerClients get clients =>
      _clients ??= new ServiceWorkerClients._(_delegate.clients);

  /// Contains the ServiceWorkerRegistration object that represents the
  /// service worker's registration.
  ServiceWorkerRegistration get registration =>
      _registration ?? new ServiceWorkerRegistration._(_delegate.registration);

  /// An event handler fired whenever an activate event occurs — when a
  /// ServiceWorkerRegistration acquires a new ServiceWorkerRegistration.active
  /// worker.
  Stream<ExtendableEvent> get onActivate => _onActivate ??= callbackToStream(
      (fn) => _delegate.onactivate = fn, (j) => new ExtendableEvent._(j));

  /// An event handler fired whenever a fetch event occurs — when a fetch()
  /// is called.
  Stream<FetchEvent> get onFetch => _onFetch ??= callbackToStream(
      (fn) => _delegate.onfetch = fn, (j) => new FetchEvent._(j));

  /// An event handler fired whenever an install event occurs — when a
  /// ServiceWorkerRegistration acquires a new
  /// ServiceWorkerRegistration.installing worker.
  Stream<InstallEvent> get onInstall => _onInstall ??= callbackToStream(
      (fn) => _delegate.oninstall = fn, (j) => new InstallEvent._(j));

  /// An event handler fired whenever a message event occurs — when incoming
  /// messages are received. Controlled pages can use the
  /// MessagePort.postMessage() method to send messages to service workers.
  /// The service worker can optionally send a response back via the
  /// MessagePort exposed in event.data.port, corresponding to the controlled
  /// page.
  /// `onmessage` is actually fired with `ExtendableMessageEvent`, but
  /// since we are merging the interface into `Window`, we should
  /// make sure it's compatible with `window.onmessage`
  /// onmessage: (messageevent: ExtendableMessageEvent) => void;
  Stream<ExtendableMessageEvent> get onMessage =>
      _onMessage ??= callbackToStream((fn) => _delegate.onmessage = fn,
          (j) => new ExtendableMessageEvent._(j));

  /// An event handler fired whenever a notificationclick event occurs — when
  /// a user clicks on a displayed notification.
  Stream<NotificationEvent> get onNotificationClick =>
      _onNotificationClick ??= callbackToStream(
          (fn) => _delegate.onnotificationclick = fn,
          (j) => new NotificationEvent._(j));

  /// An event handler fired whenever a push event occurs — when a server
  /// push notification is received.
  Stream<PushEvent> get onPush => _onPush ??= callbackToStream(
      (fn) => _delegate.onpush = fn, (j) => new PushEvent._(j));

  /// An event handler fired whenever a pushsubscriptionchange event occurs —
  /// when a push subscription has been invalidated, or is about to be
  /// invalidated (e.g. when a push service sets an expiration time).
  Stream<PushEvent> get onPushSubscriptionChange =>
      _onPushSubscriptionChange ??= callbackToStream(
          (fn) => _delegate.onpushsubscriptionchange = fn,
          (j) => new PushEvent._(j));

  /// Allows the current service worker registration to progress from waiting
  /// to active state while service worker clients are using it.
  Future<Null> skipWaiting() => promiseToFuture(_delegate.skipWaiting());

  ///
  addEventListener<K>(String type, listener(K event), [bool useCapture]) =>
      _delegate.addEventListener(type, allowInterop(listener), useCapture);
}

// TODO
class CacheStorage {
  js.CacheStorage _delegate;
  CacheStorage._(this._delegate);

  /// Returns a Promise that resolves to the Cache object matching
  /// the cacheName.
  Future<Cache> open(String cacheName) =>
      promiseToFuture(_delegate.open(cacheName));
}

// TODO
class Cache {
  js.Cache _delegate;
  Cache._(this._delegate);

  /// Returns a Promise that resolves to a new Cache entry whose key
  /// is the request.
  Future<Null> add(dynamic /*Request|String*/ request) =>
      promiseToFuture(_delegate.add(request));
}

// TODO
class ServiceWorkerClients {
  js.ServiceWorkerClients _delegate;
  ServiceWorkerClients._(this._delegate);
}

// TODO
class ServiceWorkerRegistration {
  js.ServiceWorkerRegistration _delegate;
  ServiceWorkerRegistration._(this._delegate);
}

// TODO
class ExtendableEvent {
  js.ExtendableEvent _delegate;
  ExtendableEvent._(this._delegate);
}

// TODO
class FetchEvent {
  js.FetchEvent _delegate;
  FetchEvent._(this._delegate);
}

// TODO
class InstallEvent {
  js.InstallEvent _delegate;
  InstallEvent._(this._delegate);
}

// TODO
class ExtendableMessageEvent {
  js.ExtendableMessageEvent _delegate;
  ExtendableMessageEvent._(this._delegate);
}

// TODO
class NotificationEvent {
  js.NotificationEvent _delegate;
  NotificationEvent._(this._delegate);
}

// TODO
class PushEvent {
  js.PushEvent _delegate;
  PushEvent._(this._delegate);
}
