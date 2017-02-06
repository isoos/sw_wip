part of service_worker;

/// FetchEvent represents a fetch action that is dispatched on the
/// ServiceWorkerGlobalScope of a ServiceWorker. It contains information about
/// the request and resulting response, and provides the [respondWith] method,
/// which allows us to provide an arbitrary response back to the controlled page.
class FetchEvent {
  final js.JsObject _self;
  Request _request;

  FetchEvent._(this._self);

  /// Returns the [Request] that triggered the event handler.
  Request get request => _request ??= new Request._(_self['request']);

  /// Resolves event by returning a [Response] or a network error to Fetch.
  void respondWith(Future<Response> response) {
    final p = response == null
        ? null
        : promise.futureToJsPromise(response.then((r) => r._self));
    _self.callMethod('respondWith', [p]);
  }
}

class Request {
  final js.JsObject _self;
  Request._(this._self);

  String get url => _self['url'];

  @override
  String toString() => 'Request(url: $url)';
}

class Response {
  final js.JsObject _self;
  Response._(this._self);

  String get type => _self['type'];
  String get url => _self['url'];

  @override
  String toString() => 'Response(type: $type, url: $url)';
}
