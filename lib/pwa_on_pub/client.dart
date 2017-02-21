library pwa.client;

import 'dart:async';

import 'package:func/func.dart';
import 'package:service_worker/window.dart' as sw;

import 'message_hub.dart';
export 'message_hub.dart';

/// Hides:
/// - ready state
/// - registration
///
/// Provides:
/// - message passing logic
/// - configuration updater
abstract class PwaClient {
  /// [workerUrl]: TODO: should transparently register the .js version
  factory PwaClient({String workerUrl: '/pwa.dart'}) => null;

  bool get isSupported;

  /// TODO: decide how this should work.
  /// See: example-config.json
  /// TODO: make it part of the constructor
  Future updateConfiguration(dynamic complexConfigOrJsonUrl);

  /// -----
  /// Cache
  /// -----

  /// TODO: decide how this should work. Ideally, the two parameters should be
  /// enough, as the rest is controlled by the SW configuration.
  Future updateCache(String pwaCache, List<String> urls);

  MessageHub get messageHub;

  /// ------------------
  /// Push Notifications
  /// ------------------

  /// Check and if needed registers a subscription to push notifications.
  /// Returns null if notifications are denied, or the serialized format if it
  /// is available:
  /// {"endpoint": "[url]", "keys": {"whatever": "[base64]"} }
  Future<Map> subscribeNotifications();

  /// Normally there is no notification in the client app, but we can make it
  /// transparent for the app.
  Stream get onPushNotification;
}
