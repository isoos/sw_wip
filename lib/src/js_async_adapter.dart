library js_stream_adapter;

import 'dart:async';

import 'package:func/func.dart';
import 'package:js/js.dart';

import 'js_facade/promise.dart';

Stream<T> callbackToStream<J, T>(
    VoidFunc1<VoidFunc1<J>> setter, Func1<J, T> transformer) {
  StreamController<T> controller = new StreamController.broadcast(sync: true);
  setter(allowInterop((J event) {
    controller.add(transformer == null ? event : transformer(event));
  }));
  return controller.stream;
}

Future<T> promiseToFuture<T>(Promise<T> promise) {
  Completer<T> completer = new Completer();
  promise.then(allowInterop((value) {
    completer.complete(value);
  }), allowInterop((error) {
    completer.completeError(error);
  }));
  return completer.future;
}

Promise futureToPromise<T>(Future<T> future) {
  return new Promise(allowInterop((Function resolve, Function reject) {
    future.then((value) {
      resolve(value);
    }).catchError((error) {
      reject(error);
    });
  }));
}
