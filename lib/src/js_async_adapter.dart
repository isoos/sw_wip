library js_stream_adapter;

import 'dart:async';

import 'package:func/func.dart';
import 'package:js/js.dart';
import 'package:js/js_util.dart' as js_util;

import 'js_facade/promise.dart';

Stream<T> callbackToStream<J, T>(object, String name, Func1<J, T> unwrapValue) {
  StreamController<T> controller = new StreamController.broadcast(sync: true);
  js_util.setProperty(object, name, allowInterop((J event) {
    controller.add(unwrapValue(event));
  }));
  return controller.stream;
}

Future<T> promiseToFuture<J, T>(Promise<J> promise, [Func1<J, T> unwrapValue]) {
  if (promise is Future) return promise as Future;
  Completer<T> completer = new Completer();
  promise.then(allowInterop((value) {
    T unwrapped = null;
    if (unwrapValue == null) {
      unwrapped = value;
    } else if (value != null) {
      unwrapped = unwrapValue(value);
    }
    completer.complete(unwrapped);
  }), allowInterop((error) {
    completer.completeError(error);
  }));
  return completer.future;
}

Promise<J> futureToPromise<J, T>(Future<T> future, [Func1<T, J> wrapValue]) {
  return new Promise<J>(allowInterop((VoidFunc1<J> resolve, VoidFunc1 reject) {
    future.then((value) {
      J wrapped = null;
      if (wrapValue != null) {
        wrapped = wrapValue(value);
      } else if (value != null) {
        wrapped = value as J;
      }
      resolve(wrapped);
    }).catchError((error) {
      reject(error);
    });
  }));
}
