@JS()
library promise_js_facade;

import 'dart:async';

import 'package:func/func.dart';
import 'package:js/js.dart';

@JS('Promise')
class Promise<T> extends Thenable<T> {
  external Promise(VoidFunc2<VoidFunc1, VoidFunc1> resolver);
  external static Promise<List> all(List<Promise> values);
  external static Promise reject(error);
  external static Promise resolve(value);
}

@JS('Thenable')
abstract class Thenable<T> {
  external Thenable JS$catch([VoidFunc1 reject]);
  external Thenable then([VoidFunc1 resolve, VoidFunc1 reject]);
}
