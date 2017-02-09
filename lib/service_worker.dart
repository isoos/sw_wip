library service_worker;

import 'dart:async';
import 'dart:html' show Blob, Event, FormData, MessagePort, Worker;
import 'dart:html';
import "dart:typed_data" show ByteBuffer;

import 'package:js/js.dart';
import 'package:js/js_util.dart' as js_util;

import 'src/js_async_adapter.dart';
import 'src/js_facade/service_worker_api.dart' as facade;

import 'src/js_facade/service_worker_api.dart' show CacheOptions;

class ServiceWorkerGlobalScope {
  static ServiceWorkerGlobalScope _instance =
      new ServiceWorkerGlobalScope._(facade.globalScope);

  facade.ServiceWorkerGlobalScope _delegate;
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
  CacheStorage get caches =>
      _caches ??= new CacheStorage._(_getProperty(_delegate, 'caches'));

  /// Contains the Clients object associated with the service worker.
  ServiceWorkerClients get clients => _clients ??=
      new ServiceWorkerClients._(_getProperty(_delegate, 'clients'));

  /// Contains the ServiceWorkerRegistration object that represents the
  /// service worker's registration.
  ServiceWorkerRegistration get registration =>
      _registration ??
      new ServiceWorkerRegistration._(_getProperty(_delegate, 'registration'));

  /// An event handler fired whenever an activate event occurs — when a
  /// ServiceWorkerRegistration acquires a new ServiceWorkerRegistration.active
  /// worker.
  Stream<ExtendableEvent> get onActivate => _onActivate ??= callbackToStream(
      _delegate, 'onactivate', (j) => new ExtendableEvent._(j));

  /// An event handler fired whenever a fetch event occurs — when a fetch()
  /// is called.
  Stream<FetchEvent> get onFetch => _onFetch ??=
      callbackToStream(_delegate, 'onfetch', (j) => new FetchEvent._(j));

  /// An event handler fired whenever an install event occurs — when a
  /// ServiceWorkerRegistration acquires a new
  /// ServiceWorkerRegistration.installing worker.
  Stream<InstallEvent> get onInstall => _onInstall ??=
      callbackToStream(_delegate, 'oninstall', (j) => new InstallEvent._(j));

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
      _onMessage ??= callbackToStream(
          _delegate, 'onmessage', (j) => new ExtendableMessageEvent._(j));

  /// An event handler fired whenever a notificationclick event occurs — when
  /// a user clicks on a displayed notification.
  Stream<NotificationEvent> get onNotificationClick =>
      _onNotificationClick ??= callbackToStream(
          _delegate, 'onnotificationclick', (j) => new NotificationEvent._(j));

  /// An event handler fired whenever a push event occurs — when a server
  /// push notification is received.
  Stream<PushEvent> get onPush => _onPush ??=
      callbackToStream(_delegate, 'onpush', (j) => new PushEvent._(j));

  /// An event handler fired whenever a pushsubscriptionchange event occurs —
  /// when a push subscription has been invalidated, or is about to be
  /// invalidated (e.g. when a push service sets an expiration time).
  Stream<PushEvent> get onPushSubscriptionChange =>
      _onPushSubscriptionChange ??= callbackToStream(
          _delegate, 'onpushsubscriptionchange', (j) => new PushEvent._(j));

  /// Allows the current service worker registration to progress from waiting
  /// to active state while service worker clients are using it.
  Future<Null> skipWaiting() =>
      promiseToFuture(_callMethod(_delegate, 'skipWaiting', []));

  ///
  addEventListener<K>(String type, listener(K event), [bool useCapture]) =>
      _callMethod(_delegate, 'addEventListener',
          [type, allowInterop(listener), useCapture]);

  /// Fetches the [request] and returns the [Response]
  /// TODO: add RequestInit parameter
  Future<Response> fetch(dynamic /*Request|String*/ request) => promiseToFuture(
      _callMethod(_delegate, 'fetch', [_wrapRequest(request)]),
      (j) => new Response._(j));
}

/// Represents the storage for Cache objects. It provides a master directory of
/// all the named caches that a ServiceWorker can access and maintains a mapping
/// of string names to corresponding Cache objects.
class CacheStorage {
  facade.CacheStorage _delegate;
  CacheStorage._(this._delegate);

  /// Checks if a given Request is a key in any of the Cache objects that the
  /// CacheStorage object tracks and returns a Promise that resolves
  /// to that match.
  Future<Response> match(dynamic /*Request|String*/ request,
          [facade.CacheOptions options]) =>
      promiseToFuture(
          _callMethod(_delegate, 'match', [_wrapRequest(request), options]),
          (j) => new Response._(j));

  /// Returns a Promise that resolves to true if a Cache object matching
  /// the cacheName exists.
  /// CacheStorage.
  Future<bool> has(String cacheName) =>
      promiseToFuture(_callMethod(_delegate, 'has', [cacheName]));

  /// Returns a Promise that resolves to the Cache object matching
  /// the cacheName.
  Future<Cache> open(String cacheName) => promiseToFuture(
      _callMethod(_delegate, 'open', [cacheName]), (j) => new Cache._(j));

  /// Finds the Cache object matching the cacheName, and if found, deletes the
  /// Cache object and returns a Promise that resolves to true. If no
  /// Cache object is found, it returns false.
  Future<bool> delete(String cacheName) =>
      promiseToFuture(_callMethod(_delegate, 'delete', [cacheName]));

  /// Returns a Promise that will resolve with an array containing strings
  /// corresponding to all of the named Cache objects tracked by the
  /// CacheStorage. Use this method to iterate over a list of all the
  /// Cache objects.
  Future<List<String>> keys() =>
      promiseToFuture(_callMethod(_delegate, 'keys', []));
}

/// Represents the storage for Request / Response object pairs that are cached as
/// part of the ServiceWorker life cycle.
class Cache {
  facade.Cache _delegate;
  Cache._(this._delegate);

  /// Returns a Promise that resolves to the response associated with the first
  /// matching request in the Cache object.
  Future<Response> match(dynamic /*Request|String*/ request,
          [CacheOptions options]) =>
      promiseToFuture(
          _callMethod(_delegate, 'match', [_wrapRequest(request), options]),
          (j) => new Response._(j));

  /// Returns a Promise that resolves to an array of all matching responses in
  /// the Cache object.
  Future<List<Response>> matchAll(dynamic /*Request|String*/ request,
          [CacheOptions options]) =>
      promiseToFuture(
          _callMethod(_delegate, 'matchAll', [_wrapRequest(request), options]),
          (List list) => list?.map((item) => new Response._(item))?.toList());

  /// Returns a Promise that resolves to a new Cache entry whose key
  /// is the request.
  Future<Null> add(dynamic /*Request|String*/ request) =>
      promiseToFuture(_callMethod(_delegate, 'add', [_wrapRequest(request)]));

  /// Returns a Promise that resolves to a new array of Cache entries whose
  /// keys are the requests.
  Future<Null> addAll(List<dynamic /*Request|String*/ > requests) =>
      promiseToFuture(_callMethod(
          _delegate, 'addAll', [requests.map(_wrapRequest).toList()]));

  /// Adds additional key/value pairs to the current Cache object.
  Future<Null> put(Request request, Response response) => promiseToFuture(
      _callMethod(_delegate, 'put', [request._delegate, response._delegate]));

  /// Finds the Cache entry whose key is the request, and if found, deletes the
  /// Cache entry and returns a Promise that resolves to true. If no Cache
  /// entry is found, it returns false.
  Future<bool> delete(dynamic /*Request|String*/ request,
          [CacheOptions options]) =>
      promiseToFuture(
          _callMethod(_delegate, 'delete', [_wrapRequest(request), options]));

  /// Returns a Promise that resolves to an array of Cache keys.
  Future<List<Request>> keys([Request request, CacheOptions options]) =>
      promiseToFuture(
          _callMethod(_delegate, 'keys', [_wrapRequest(request), options]),
          (List list) => list?.map((item) => new Request._(item))?.toList());
}

/// Represents a container for a list of Client objects; the main way to access
/// the active service worker clients at the current origin.
class ServiceWorkerClients {
  facade.ServiceWorkerClients _delegate;
  ServiceWorkerClients._(this._delegate);

  /// Gets a service worker client matching a given id and returns it in a Promise.
  Future<ServiceWorkerClient> operator [](String clientId) => promiseToFuture(
      _callMethod(_delegate, 'get', [clientId]),
      (j) => new ServiceWorkerClient._(j));

  /// Gets a list of service worker clients and returns them in a Promise.
  /// Include the options parameter to return all service worker clients whose
  /// origin is the same as the associated service worker's origin. If options
  /// are not included, the method returns only the service worker clients
  /// controlled by the service worker.
  Future<List<ServiceWorkerClient>> matchAll(
          [facade.ServiceWorkerClientsMatchOptions options]) =>
      promiseToFuture(
          _callMethod(_delegate, 'matchAll', [options]),
          (List list) =>
              list?.map((j) => new ServiceWorkerClient._(j))?.toList());

  /// Opens a service worker Client in a new browser window.
  /// in the window.
  Future<WindowClient> openWindow(String url) => promiseToFuture(
      _callMethod(_delegate, 'openWindow', [url]),
      (j) => new WindowClient._(j));

  /// Allows an active Service Worker to set itself as the active worker for a
  /// client page when the worker and the page are in the same scope.
  Future<Null> claim() => promiseToFuture(_callMethod(_delegate, 'claim', []));
}

/// Represents the scope of a service worker client. A service worker client is
/// either a document in a browser context or a SharedWorker, which is controlled
/// by an active worker.
class ServiceWorkerClient {
  facade.ServiceWorkerClient _delegate;
  ServiceWorkerClient._(this._delegate);

  /// Allows a service worker client to send a message to a ServiceWorker.
  /// to a port.
  void postMessage(dynamic message, [dynamic transfer]) {
    _callMethod(_delegate, 'postMessage', [message, transfer]);
  }

  /// Indicates the type of browsing context of the current client.
  /// This value can be one of auxiliary, top-level, nested, or none.
  String get frameType => _getProperty(_delegate, 'frameType');

  /// Returns the id of the Client object.
  String get id => _getProperty(_delegate, 'id');

  /// The URL of the current service worker client.
  String get url => _getProperty(_delegate, 'url');
}

class WindowClient extends ServiceWorkerClient {
  facade.WindowClient _delegate;
  WindowClient._(facade.WindowClient delegate)
      : super._(delegate),
        _delegate = delegate;

  /// Gives user input focus to the current client.
  Future<Null> focus() => promiseToFuture(_callMethod(_delegate, 'focus', []));

  /// A boolean that indicates whether the current client has focus.
  bool get focused => _getProperty(_delegate, 'focused');

  /// Indicates the visibility of the current client. This value can be one of
  /// hidden, visible, prerender, or unloaded.
  String get visibilityState => _getProperty(_delegate, 'visibilityState');
}

/// Represents a service worker registration.
class ServiceWorkerRegistration implements EventTarget {
  facade.ServiceWorkerRegistration _delegate;
  Stream _onUpdateFound;
  ServiceWorkerRegistration._(this._delegate);

  /// Returns a unique identifier for a service worker registration.
  /// This must be on the same origin as the document that registers
  /// the ServiceWorker.
  dynamic get scope => _getProperty(_delegate, 'scope');

  /// Returns a service worker whose state is installing. This is initially
  /// set to null.
  ServiceWorker get installing =>
      new ServiceWorker._(_getProperty(_delegate, 'installing'));

  /// Returns a service worker whose state is installed. This is initially
  /// set to null.
  ServiceWorker get waiting =>
      new ServiceWorker._(_getProperty(_delegate, 'waiting'));

  /// Returns a service worker whose state is either activating or activated.
  /// This is initially set to null. An active worker will control a
  /// ServiceWorkerClient if the client's URL falls within the scope of the
  /// registration (the scope option set when ServiceWorkerContainer.register
  /// is first called).
  ServiceWorker get active =>
      new ServiceWorker._(_getProperty(_delegate, 'active'));

  /// Returns an interface to for managing push subscriptions, including
  /// subcribing, getting an anctive subscription, and accessing push
  /// permission status.
  PushManager get pushManager => _getProperty(_delegate, 'pushManager');

  /// An EventListener property called whenever an event of type updatefound
  /// is fired; it is fired any time the ServiceWorkerRegistration.installing
  /// property acquires a new service worker.
  Stream<Null> get onUpdateFound => _onUpdateFound ??=
      callbackToStream(_delegate, 'onupdatefound', (j) => null);

  /// Allows you to update a service worker.
  void update() => _callMethod(_delegate, 'update', []);

  /// Unregisters the service worker registration and returns a promise
  /// (see Promise). The service worker will finish any ongoing operations
  /// before it is unregistered.
  Future<bool> unregister() =>
      promiseToFuture(_callMethod(_delegate, 'unregister', []));

  @override
  void addEventListener(String type, EventListener listener,
      [bool useCapture]) {
    _callMethod(_delegate, 'addEventListener',
        [type, allowInterop(listener), useCapture]);
  }

  @override
  bool dispatchEvent(Event event) =>
      _callMethod(_delegate, 'dispatchEvent', [event]);

  @override
  Events get on => _getProperty(_delegate, 'on');

  @override
  void removeEventListener(String type, EventListener listener,
          [bool useCapture]) =>
      throw new UnimplementedError();
}

/// Extends the lifetime of the install and activate events dispatched on the
/// ServiceWorkerGlobalScope as part of the service worker lifecycle. This
/// ensures that any functional events (like FetchEvent) are not dispatched to
/// the ServiceWorker until it upgrades database schemas, deletes outdated cache
/// entries, etc.
class ExtendableEvent implements Event {
  facade.ExtendableEvent _delegate;
  ExtendableEvent._(this._delegate);

  /// Extends the lifetime of the event.
  /// It is intended to be called in the install EventHandler for the
  /// installing worker and on the active EventHandler for the active worker.
  void waitUntil(Future<dynamic> future) {
    _callMethod(_delegate, 'waitUntil', [futureToPromise(future)]);
  }

  @override
  EventTarget get target => _getProperty(_delegate, 'target');

  @override
  int get timeStamp => _getProperty(_delegate, 'timeStamp');

  @override
  String get type => _getProperty(_delegate, 'type');

  @override
  bool get bubbles => _getProperty(_delegate, 'bubbles');

  @override
  bool get cancelable => _getProperty(_delegate, 'cancelable');

  @override
  EventTarget get currentTarget => _getProperty(_delegate, 'currentTarget');

  @override
  bool get defaultPrevented => _getProperty(_delegate, 'defaultPrevented');

  @override
  int get eventPhase => _getProperty(_delegate, 'eventPhase');

  @override
  Element get matchingTarget => _getProperty(_delegate, 'matchingTarget');

  @override
  List<EventTarget> get path => _getProperty(_delegate, 'path');

  @override
  void preventDefault() => _callMethod(_delegate, 'preventDefault', []);

  @override
  void stopImmediatePropagation() =>
      _callMethod(_delegate, 'stopImmediatePropagation', []);

  @override
  void stopPropagation() => _callMethod(_delegate, 'stopPropagation', []);
}

/// The parameter passed into the ServiceWorkerGlobalScope.onfetch handler,
/// FetchEvent represents a fetch action that is dispatched on the
/// ServiceWorkerGlobalScope of a ServiceWorker. It contains information about
/// the request and resulting response, and provides the FetchEvent.respondWith()
/// method, which allows us to provide an arbitrary response back to the
/// controlled page.
class FetchEvent implements Event {
  facade.FetchEvent _delegate;
  Request _request;
  ServiceWorkerClient _client;
  FetchEvent._(this._delegate);

  /// Returns a Boolean that is true if the event was dispatched with the
  /// user's intention for the page to reload, and false otherwise. Typically,
  /// pressing the refresh button in a browser is a reload, while clicking a
  /// link and pressing the back button is not.
  bool get isReload => _getProperty(_delegate, 'isReload');

  /// Returns the Request that triggered the event handler.
  Request get request =>
      _request ??= new Request._(_getProperty(_delegate, 'request'));

  /// Returns the Client that the current service worker is controlling.
  ServiceWorkerClient get client =>
      _client ??= new ServiceWorkerClient._(_getProperty(_delegate, 'client'));

  /// Returns the id of the client that the current service worker is controlling.
  String get clientId => _getProperty(_delegate, 'clientId');

  void respondWith(Future<Response> response) {
    _callMethod(_delegate, 'respondWith',
        [futureToPromise(response, (Response r) => r._delegate)]);
  }

  @override
  EventTarget get target => _getProperty(_delegate, 'target');

  @override
  int get timeStamp => _getProperty(_delegate, 'timeStamp');

  @override
  String get type => _getProperty(_delegate, 'type');

  @override
  bool get bubbles => _getProperty(_delegate, 'bubbles');

  @override
  bool get cancelable => _getProperty(_delegate, 'cancelable');

  @override
  EventTarget get currentTarget => _getProperty(_delegate, 'currentTarget');

  @override
  bool get defaultPrevented => _getProperty(_delegate, 'defaultPrevented');

  @override
  int get eventPhase => _getProperty(_delegate, 'eventPhase');

  @override
  Element get matchingTarget => _getProperty(_delegate, 'matchingTarget');

  @override
  List<EventTarget> get path => _getProperty(_delegate, 'path');

  @override
  void preventDefault() => _callMethod(_delegate, 'preventDefault', []);

  @override
  void stopImmediatePropagation() =>
      _callMethod(_delegate, 'stopImmediatePropagation', []);

  @override
  void stopPropagation() => _callMethod(_delegate, 'stopPropagation', []);
}

/// The parameter passed into the oninstall handler, the InstallEvent interface
/// represents an install action that is dispatched on the
/// ServiceWorkerGlobalScope of a ServiceWorker. As a child of ExtendableEvent,
/// it ensures that functional events such as FetchEvent are not dispatched
/// during installation.
class InstallEvent extends ExtendableEvent {
  facade.InstallEvent _delegate;
  ServiceWorker _activeWorker;
  InstallEvent._(facade.InstallEvent delegate)
      : super._(delegate),
        _delegate = delegate;

  /// Returns the ServiceWorker that is currently actively controlling the page.
  ServiceWorker get activeWorker => _activeWorker ??=
      new ServiceWorker._(_getProperty(_delegate, 'activeWorker'));
}

/// Represents a service worker. Multiple browsing contexts (e.g. pages, workers,
/// etc.) can be associated with the same ServiceWorker object.
class ServiceWorker implements Worker {
  facade.ServiceWorker _delegate;
  Stream<Event> _onStateChange;
  ServiceWorker._(this._delegate);

  /// Returns the ServiceWorker serialized script URL defined as part of
  /// ServiceWorkerRegistration. The URL must be on the same origin as the
  /// document that registers the ServiceWorker.
  String get scriptURL => _getProperty(_delegate, 'scriptURL');

  /// Returns the state of the service worker. It returns one of the following
  /// values: installing, installed, activating, activated, or redundant.
  String get state => _getProperty(_delegate, 'state');

  /// An EventListener property called whenever an event of type statechange
  /// is fired; it is basically fired anytime the ServiceWorker.state changes.
  Stream<Event> get onStateChange =>
      _onStateChange ??= callbackToStream(_delegate, 'onstatechange', (j) => j);

  @override
  void addEventListener(String type, EventListener listener,
      [bool useCapture]) {
    _callMethod(_delegate, 'addEventListener',
        [type, allowInterop(listener), useCapture]);
  }

  @override
  bool dispatchEvent(Event event) =>
      _callMethod(_delegate, 'dispatchEvent', [event]);

  @override
  Events get on => _getProperty(_delegate, 'on');

  @override
  Stream<Event> get onError => throw new UnimplementedError();

  @override
  Stream<MessageEvent> get onMessage => throw new UnimplementedError();

  @override
  void postMessage(message, [List<MessagePort> transfer]) {
    _callMethod(_delegate, 'postMessage', [message, transfer]);
  }

  @override
  void removeEventListener(String type, EventListener listener,
          [bool useCapture]) =>
      throw new UnimplementedError();

  @override
  void terminate() {
    _callMethod(_delegate, 'terminate', []);
  }
}

/// The ExtendableMessageEvent interface of the ServiceWorker API represents
/// the event object of a message event fired on
/// a service worker (when a channel message is received on
/// the ServiceWorkerGlobalScope from another context)
/// — extends the lifetime of such events.
class ExtendableMessageEvent extends ExtendableEvent {
  facade.ExtendableMessageEvent _delegate;
  ExtendableMessageEvent._(facade.ExtendableMessageEvent delegate)
      : super._(delegate),
        _delegate = delegate;

  /// Returns the event's data. It can be any data type.
  dynamic get data => _getProperty(_delegate, 'data');

  String get origin => _getProperty(_delegate, 'origin');

  /// Represents, in server-sent events, the last event ID of the event source.
  String get lastEventId => _getProperty(_delegate, 'lastEventId');

  /// Returns a reference to the service worker that sent the message.
  ServiceWorkerClient get source =>
      new ServiceWorkerClient._(_getProperty(_delegate, 'source'));

  /// Returns the array containing the MessagePort objects
  /// representing the ports of the associated message channel.
  List<MessagePort> get ports => _getProperty(_delegate, 'ports');
}

/// The parameter passed into the onnotificationclick handler,
/// the NotificationEvent interface represents
/// a notification click event that is dispatched on
/// the ServiceWorkerGlobalScope of a ServiceWorker.
class NotificationEvent extends ExtendableEvent {
  facade.NotificationEvent _delegate;
  NotificationEvent._(facade.NotificationEvent delegate)
      : super._(delegate),
        _delegate = delegate;

  /// Returns a Notification object representing
  /// the notification that was clicked to fire the event.
  dynamic get notification => _getProperty(_delegate, 'notification');

  /// Returns the string ID of the notification button the user clicked.
  /// This value returns undefined if the user clicked
  /// the notification somewhere other than an action button,
  /// or the notification does not have a button.
  String get action => _getProperty(_delegate, 'action');
}

/// The PushEvent interface of the Push API represents
/// a push message that has been received.
/// This event is sent to the global scope of a ServiceWorker.
/// It contains the information sent from an application server to a PushSubscription.
class PushEvent extends ExtendableEvent {
  facade.PushEvent _delegate;
  PushEvent._(facade.PushEvent delegate)
      : super._(delegate),
        _delegate = delegate;

  /// Returns a reference to a PushMessageData object containing
  /// data sent to the PushSubscription.
  PushMessageData get data =>
      new PushMessageData._(_getProperty(_delegate, 'data'));
}

/// The PushMessageData interface of the Push API provides
/// methods which let you retrieve the push data sent by a server in various formats.
class PushMessageData {
  facade.PushMessageData _delegate;
  PushMessageData._(this._delegate);

  /// Extracts the data as a ByteBuffer object.
  ByteBuffer arrayBuffer() => _callMethod(_delegate, 'arrayBuffer', []);

  /// Extracts the data as a Blob object.
  Blob blob() => _callMethod(_delegate, 'blob', []);

  /// Extracts the data as a JSON object.
  T json<T>() => _callMethod(_delegate, 'json', []);

  /// Extracts the data as a plain text string.
  String text() => _callMethod(_delegate, 'text', []);
}

class Body {
  facade.Body _delegate;
  Body._(this._delegate);

  /// indicates whether the body has been read yet
  bool get bodyUsed => _getProperty(_delegate, 'bodyUsed');

  /// Extracts the data as a ByteBuffer object.
  Future<ByteBuffer> arrayBuffer() =>
      promiseToFuture(_callMethod(_delegate, 'arrayBuffer', []));

  /// Extracts the data as a Blob object.
  Future<Blob> blob() => promiseToFuture(_callMethod(_delegate, 'blob', []));

  Future<FormData> formData() =>
      promiseToFuture(_callMethod(_delegate, 'formData', []));

  /// Extracts the data as a JSON object.
  Future<T> json<T>() => promiseToFuture(_callMethod(_delegate, 'json', []));

  /// Extracts the data as a plain text string.
  Future<String> text() => promiseToFuture(_callMethod(_delegate, 'text', []));
}

class Request extends Body {
  facade.Request _delegate;
  Headers _headers;

  Request._(facade.Request delegate)
      : super._(delegate),
        _delegate = delegate;

  String get method => _getProperty(_delegate, 'method');
  String get url => _getProperty(_delegate, 'url');

  Headers get headers =>
      _headers ??= new Headers._(_getProperty(_delegate, 'headers'));

  /// ''|'audio'|'font'|'image'|'script'|'style'|'track'|'video'
  String get type => _getProperty(_delegate, 'type');

  /// ''|'document'|'embed'|'font'|'image'|'manifest'|'media'|'object'|'report'|'script'|'serviceworker'|'sharedworker'|'style'|'worker'|'xslt'
  String get destination => _getProperty(_delegate, 'destination');

  String get referrer => _getProperty(_delegate, 'referrer');

  /// ''|'no-referrer'|'no-referrer-when-downgrade'|'same-origin'|'origin'|'strict-origin'|'origin-when-cross-origin'|'strict-origin-when-cross-origin'|'unsafe-url'
  String get referrerPolicy => _getProperty(_delegate, 'referrerPolicy');

  /// 'navigate'|'same-origin'|'no-cors'|'cors'
  String get mode => _getProperty(_delegate, 'mode');

  /// 'omit'|'same-origin'|'include'
  String get credentials => _getProperty(_delegate, 'credentials');

  /// 'default'|'no-store'|'reload'|'no-cache'|'force-cache'|'only-if-cached'
  String get cache => _getProperty(_delegate, 'cache');

  /// 'follow'|'error'|'manual'
  String get redirect => _getProperty(_delegate, 'redirect');

  String get integrity => _getProperty(_delegate, 'integrity');

  Request clone() => new Request._(_callMethod(_delegate, 'clone', []));
}

class Response extends Body {
  facade.Response _delegate;
  Headers _headers;
  Response._(facade.Response delegate)
      : super._(delegate),
        _delegate = delegate;

  factory Response.redirect(String url, [int status]) =>
      new Response._(facade.Response.redirect(url, status));

  factory Response.error() => new Response._(facade.Response.error());

  /// 'basic'|'cors'|'default'|'error'|'opaque'|'opaqueredirect'
  String get type => _getProperty(_delegate, 'type');

  String get url => _getProperty(_delegate, 'url');

  bool get redirected => _getProperty(_delegate, 'redirected');

  int get status => _getProperty(_delegate, 'status');

  String get statusText => _getProperty(_delegate, 'statusText');

  bool get ok => _getProperty(_delegate, 'ok');

  Headers get headers =>
      _headers ??= new Headers._(_getProperty(_delegate, 'headers'));

  dynamic get body => _getProperty(_delegate, 'body');

  Response clone() => new Response._(_callMethod(_delegate, 'clone', []));
}

class Headers {
  facade.Headers _delegate;
  Headers._(this._delegate);

  void append(String name, String value) =>
      _callMethod(_delegate, 'append', [name, value]);

  void delete(String name) => _callMethod(_delegate, 'delete', [name]);

  String operator [](String name) => _callMethod(_delegate, 'get', [name]);
  operator []=(String name, String value) =>
      _callMethod(_delegate, 'set', [name, value]);
  List<String> getAll(String name) => _callMethod(_delegate, 'getAll', [name]);

  bool has(String name) => _callMethod(_delegate, 'has', [name]);

  Iterable<String> keys() => _callMethod(_delegate, 'keys', []);
}

// Utility method to mask the typed JS facade as JSObject
_callMethod(object, String method, List args) =>
    js_util.callMethod(object, method, args);

// Utility method to mask the typed JS facade as JSObject
_getProperty(object, String name) => js_util.getProperty(object, name);

_wrapRequest(dynamic /*Request|String*/ request) {
  if (request == null) return null;
  if (request is String) return request;
  return (request as Request)._delegate;
}
