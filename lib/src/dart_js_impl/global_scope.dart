part of service_worker;

class ServiceWorkerGlobalScope {
  final js.JsObject _self;
  CacheStorage _caches;
  StreamController<FetchEvent> _fetchController;

  ServiceWorkerGlobalScope._(this._self);

  factory ServiceWorkerGlobalScope([js.JsObject self]) =>
      new ServiceWorkerGlobalScope._(self ?? js.context);

  /// Contains the CacheStorage object associated with the service worker.
  CacheStorage get caches => _caches ??= new CacheStorage._(_self['caches']);

  /// An event stream fired whenever a fetch event occurs - when a fetch() is
  /// called.
  Stream<FetchEvent> get onFetch {
    if (_fetchController == null) {
      _fetchController = new StreamController.broadcast(sync: true);
      _self.callMethod('addEventListener', [
        'fetch',
        (event) {
          _fetchController
              .add(new FetchEvent._(new js.JsObject.fromBrowserObject(event)));
        }
      ]);
    }
    return _fetchController.stream;
  }

  /// Fetches the [request] and returns the [Response]
  /// TODO: add RequestInit parameter
  /// TODO: add `String url` version
  Future<Response> fetch(Request request) {
    var p = _self.callMethod('fetch', [request._self]);
    return promise
        .jsPromiseToFuture(p)
        .then((response) => new Response._(response));
  }
}
