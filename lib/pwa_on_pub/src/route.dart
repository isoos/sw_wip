part of pwa_worker;

typedef bool Matcher(Request request);

typedef Future<Response> Handler(Request request);

final Handler defaultFetchHandler = fetch;

class Route {
  List<_RouteRule> _rules = [];
  final Handler defaultHandler;

  Route({this.defaultHandler});

  void add(Matcher matcher, Handler handler) {
    _rules.add(new _RouteRule(matcher, handler));
  }

  void get(Pattern urlPattern, Handler handler) {
    add(urlPatternMatcher('get', urlPattern), handler);
  }

  void post(Pattern urlPattern, Handler handler) {
    add(urlPatternMatcher('post', urlPattern), handler);
  }

  void start() {
    onFetch.listen((FetchEvent event) {
      event.respondWith(respond(event.request));
    });
  }

  Future<Response> respond(Request request) {
    for (_RouteRule rule in _rules) {
      if (rule.matcher(request)) {
        return rule.handler(request);
      }
    }
    Handler handler = defaultHandler ?? defaultFetchHandler;
    return handler(request);
  }
}

Matcher urlPatternMatcher(String method, Pattern urlPattern) {
  String methodLowerCase = method.toLowerCase();
  return (Request request) {
    if (request.method.toLowerCase() != methodLowerCase) return false;
    return urlPattern.matchAsPrefix(request.url) != null;
  };
}

class _RouteRule {
  final Matcher matcher;
  final Handler handler;
  _RouteRule(this.matcher, this.handler);
}

bool isValidResponse(Response response) {
  if (response == null) return false;
  if (response.type == 'error') return false;
  return true;
}

/// Return a composite [Handler] that joins the [handlers] in serial processing,
/// completing with the first valid response. If none of the [handlers]
/// provide a valid response, it will complete with an error.
Handler serialHandlers(List<Handler> handlers) => (Request request) async {
      for (Handler handler in handlers) {
        try {
          Response response = await handler(request.clone());
          if (isValidResponse(response)) return response;
        } catch (_) {}
      }
      return new Response.error();
    };

/// Returns a composite [Handler] that runs the [handlers] in parallel and
/// completes with the first valid response. If none of the [handlers]
/// provide a valid response, it will complete with an error.
Handler raceHandlers(List<Handler> handlers) => (Request request) {
      Completer<Response> completer = new Completer();
      int remaining = handlers.length;
      final complete = (Response response) {
        remaining--;
        if (completer.isCompleted) return;
        if (isValidResponse(response)) {
          completer.complete(response);
          return;
        }
        if (remaining == 0) {
          completer.complete(new Response.error());
        }
      };
      for (Handler handler in handlers) {
        handler(request.clone()).then((Response response) {
          complete(response);
        }, onError: (e) {
          complete(null);
        });
      }
      return completer.future;
    };
