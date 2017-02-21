import 'dart:async';

typedef Future<S> AsyncFunction<R, S>(R request);
typedef S WireAdapter<R, S>(R input);

abstract class MessageHub {
//  MessageFunctions get functions;
//  MessageStreams get messages;
//  MessageSinks get sinks;

  AsyncFunction<R, S> getFunction<R, S>(String type,
      {WireAdapter<R, dynamic> encoder, WireAdapter<dynamic, S> decoder});

  void setHandler<R, S>(String type, AsyncFunction<R, S> handler,
      {WireAdapter<dynamic, R> decoder, WireAdapter<S, dynamic> encoder});

  Sink<T> getSink<T>(String type, {WireAdapter<T, dynamic> encoder});

  Stream<T> getStream<T>(String type, {WireAdapter<dynamic, T> decoder});
}

//
//abstract class MessageFunctions {
//  AsyncFunction/*<R, S>*/ operator[](String type);
//}
//
//abstract class MessageStreams {
//  Stream/*<T>*/ operator[](String type);
//}
//
//abstract class MessageSinks {
//  Sink/*<T>*/ operator[](String type);
//}

/// -------------------------------
/// Messaging between cliens and SW
/// -------------------------------

/// Each message is a Map:
/// - "data" attribute is the parameter of the message
/// - "type" is on request messages, accompanied with "request-id"
/// - "reply-to" is a reference to the request
///
/// Built-in types start with __. Examples:
/// - __updateCache: for the [updateCache] method.
/// - __pushNotification: for the push notification stream (coming from SW).

/// Request-reply style messaging over postMessage.
/// Wire format:
///   request: {"type": type, "data": data, "request-id": "[random-id]"}
///   response: {"data": data, "reply-to": "[random-id]"}
//  Future<dynamic> sendMessage(String type, dynamic data,
//      {bool broadcast: false});
//
//  /// The processing end (symmetric pair) of [send].
//  void setMessageHandler(String type, Func1<dynamic, FutureOr> handler);
