part of pwa_worker;

final String _dateKey = 'pwa-cache-date';

class PwaCache {
  final String name;
  final Duration maxAge;
  final int maxEntries;
  final bool populateOnFetch;

  PwaCache(
    this.name, {
    this.maxAge,
    this.maxEntries,
    this.populateOnFetch: true,
  });

  Future cacheUrls(List<String> urls) =>
      _open().then((Cache c) => c.addAll(urls));

  Future evictUrls(List<String> urls) =>
      _open().then((Cache c) => urls.forEach((url) => c.delete(url)));

  Future deleteCache() => caches.delete(name);

  Future update(
    List<String> urls, {
    bool purge: false,
    DateTime fetchBefore,
    bool forceFetch: false,
  }) async {
    Cache cache = await _open();
    if (purge) {
      List<Request> keys = await cache.keys();
      for (Request r in keys) {
        if (urls.contains(r.url)) continue;
        cache.delete(r);
      }
    }
    List<String> urlsToUpdate = [];
    if (forceFetch) {
      urlsToUpdate.addAll(urls);
    } else {
      await Future.wait(urls.map((String url) async {
        Response r = await cache.match(url);
        DateTime dt = _getDateHeaderValue(r?.headers);
        if (dt == null || (fetchBefore != null && dt.isBefore(fetchBefore))) {
          urlsToUpdate.add(url);
        }
      }));
    }
    print('Will update URLs: ${urlsToUpdate}');
    if (urlsToUpdate.isEmpty) return;
    await Future.wait(urlsToUpdate.map((String url) async {
      Response r = await fetch(url, new RequestInit(cache: 'reload'));
      return _putInCache(cache, url, r);
    }));
  }

  Future<Response> cacheOnly(Request request) async {
    Cache cache = await _open();
    Response response = await cache.match(request.clone());
    if (response != null && maxAge != null) {
      Duration age = _getAge(response.headers);
      if (age != null && age > maxAge) {
        cache.delete(request.url);
        return null;
      }
    }
    return response;
  }

  Future<Response> networkOnly(Request request) {
    Future<Response> f = fetch(request.clone());
    if (populateOnFetch == true) {
      f = f.then((Response response) {
        if (isValidResponse(response)) {
          _add(request, response.clone());
        }
        return response;
      });
    }
    return f;
  }

  Future<Response> cacheFirst(Request request) =>
      serialHandlers([cacheOnly, networkOnly])(request);

  Future<Response> networkFirst(Request request) =>
      serialHandlers([networkOnly, cacheOnly])(request);

  Future<Response> fastest(Request request) =>
      raceHandlers([cacheOnly, networkOnly])(request);

  Future<Cache> _open() => caches.open(name);

  Duration _getAge(Headers headers) {
    DateTime dt = _getDateHeaderValue(headers);
    if (dt == null) return null;
    Duration diff = new DateTime.now().difference(dt);
    return diff;
  }

  DateTime _getDateHeaderValue(Headers headers) {
    if (headers == null) return null;
    String dateHeader = headers[_dateKey] ?? headers['date'];
    if (dateHeader == null) return null;
    try {
      return DateTime.parse(dateHeader);
    } catch (e) {
      // ignore malformed date header
    }
    return null;
  }

  Future _add(Request request, Response response) async {
    Cache cache = await _open();
    // intentionally not calling await
    _removeOldAndExcessEntries(cache);

    Response old = await cache.match(request);
    if (old != null) {
      String etag = response.headers['etag'];
      if (etag != null && old.headers['etag'] == etag) {
        // same entry, do not update
        return false;
      }
    }
    return _putInCache(cache, request, response);
  }

  Future _putInCache(Cache cache, dynamic request, Response response) async {
    String headerTimestamp = new DateTime.now().toIso8601String();
    response = await response.cloneWith(headers: {
      _dateKey: headerTimestamp,
    });
    return cache.put(request, response);
  }

  Future _removeOldAndExcessEntries(Cache cache) async {
    if (maxAge != null || maxEntries != null) {
      List<Request> keys = await cache.keys();
      List<Request> remaining = [];
      for (Request rq in keys) {
        Response rs = await cache.match(rq);
        Duration age = _getAge(rs.headers);
        if (age != null && age > maxAge) {
          cache.delete(rq);
        } else {
          remaining.add(rq);
        }
      }
      if (maxEntries != null && maxEntries > 0) {
        while (remaining.length > maxEntries) {
          cache.delete(remaining.removeLast());
        }
      }
    }
  }
}
