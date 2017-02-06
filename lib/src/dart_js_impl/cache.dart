part of service_worker;

/// An CacheOptions object allowing you to set specific control options for the
/// matching done in the match operation.
class CacheOptions {
  /// Specifies whether the matching process should ignore the query string in
  /// the url.  If set to true, the ?value=bar part of
  /// http://foo.com/?value=bar would be ignored when performing a match.
  /// It defaults to false.
  final bool ignoreSearch;

  /// When set to true, prevents matching operations from validating the Request
  /// http method (normally only GET and HEAD are allowed.)
  /// It defaults to false.
  final bool ignoreMethod;

  /// When set to true tells the matching operation not to perform VARY header
  /// matching — i.e. if the URL matches you will get a match regardless of the
  /// Response object having a VARY header or not.
  /// It defaults to false.
  final bool ignoreVary;

  /// Represents a specific cache to search within.
  /// Note that this option is ignored by Cache.match().
  final String cacheName;

  CacheOptions(
      {this.ignoreSearch: false,
      this.ignoreMethod: false,
      this.ignoreVary: false,
      this.cacheName});

  js.JsObject toJsObject() => new js.JsObject.jsify({
        'ignoreSearch': ignoreSearch,
        'ignoreMethod': ignoreMethod,
        'ignoreVary': ignoreVary,
        'cacheName': cacheName,
      });
}

/// Represents the storage for Request / Response object pairs that are cached
/// as part of the ServiceWorker life cycle.
class Cache {
  final js.JsObject _self;
  Cache._(this._self);

  /// Returns a Future that completes when the [url] is added to the cache.
  Future<Null> addUrl(String url) =>
      promise.jsPromiseToFuture(_self.callMethod('add', [url]));

  /// Returns a Future that completes when the [urls] are added to the cache.
  Future<Null> addAllUrls(List<String> urls) =>
      promise.jsPromiseToFuture(_self.callMethod('addAll', [
        new js.JsObject.jsify(urls),
      ]));

  /// Returns a Promise that resolves to the response associated with the first
  /// matching request in the Cache object.
  ///
  /// [request] The Request you are attempting to find in the Cache.
  /// [options] An object that sets options for the match operation.
  ///
  /// TODO: handle `String url` version of [request]
  Future<Response> match(Request request, [CacheOptions options]) {
    js.JsObject methodResult =
        _self.callMethod('match', [request._self, options?.toJsObject()]);
    return promise.jsPromiseToFuture(methodResult).then(
        (js.JsObject response) =>
            response == null ? null : new Response._(response));
  }
}

/// Represents the storage for Cache objects. It provides a master directory of
/// all the named caches that a ServiceWorker can access and maintains a mapping
/// of string names to corresponding Cache objects.
class CacheStorage {
  Map<String, Cache> _caches = new Map();

  final js.JsObject _self;
  CacheStorage._(this._self);

  /// Resolves to the Cache object matching the [cacheName].
  Future<Cache> open(String cacheName) async {
    Cache cache = _caches[cacheName];
    if (cache != null) return cache;
    cache = await promise
        .jsPromiseToFuture(_self.callMethod('open', [cacheName]))
        .then((js.JsObject cache) => new Cache._(cache));
    _caches[cacheName] = cache;
    return cache;
  }

  /// Checks if a given [request] is a key in any of the Cache objects that the
  /// [CacheStorage] object tracks and returns a Future that resolves
  /// to that match.
  ///
  /// [request] The Request you are looking for a match for in the CacheStorage.
  /// [options] An object that sets options for the match operation.
  ///
  /// TODO: handle `String url` version of [request]
  Future<Response> match(Request request, [CacheOptions options]) {
    js.JsObject methodResult =
        _self.callMethod('match', [request._self, options?.toJsObject()]);
    return promise.jsPromiseToFuture(methodResult).then(
        (js.JsObject response) =>
            response == null ? null : new Response._(response));
  }
}
