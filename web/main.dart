import 'dart:html';

main() async {
  querySelector('#output').text = 'Your Dart app is running.';
  try {
    await window.navigator.serviceWorker.register('sw.dart.js');
    print('registered');
  } catch (e) {
    print('error: $e');
  }
}
