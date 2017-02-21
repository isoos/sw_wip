library pwa.offline;

import 'dart:io';

//import 'package:crypto/crypto.dart';
import 'package:dart_style/dart_style.dart';

main(List<String> args) {
  // TODO: make these configurable
  String baseDir = 'build/web';
  String defaultFile = 'index.html';
  File output = new File('lib/pwa/offline.g.dart');
  // TODO: remove these from Angular build in another way?
  // TODO: provide reasonable defaults for common files that can be ignored
  List<String> excludes = ['*.ng_meta.json', '*.ng_summary.json', 'sw.dart.js'];

  // derived regex
  // TODO: use better pattern-matching library
  List<RegExp> excludePatterns = excludes.map(_toPattern).toList();

  List<_Entry> list = new Directory('build/web')
      .listSync(recursive: true)
      .where((fse) => fse is File)
      .where((File file) {
    String path = file.path.substring(baseDir.length);
    return !excludePatterns.any((RegExp pattern) => pattern.hasMatch(path));
  }).map((File file) {
    String url;
    String path = file.path.substring(baseDir.length);
    if (path.endsWith('/$defaultFile')) {
      url = path.substring(0, path.length - defaultFile.length);
    } else {
      url = path;
    }
//    String hash = sha1.convert(file.readAsBytesSync()).toString();
//    hash = '${file.lengthSync()}:$hash';
    return new _Entry(url, file.lastModifiedSync());
  }).toList();
  list.sort((a, b) => Comparable.compare(a.url, b.url));

//  String mapItems =
//      list.map((_Entry e) => '\'${e.url}\':\'${e.hash}\',').join();
  String listItems = list.map((_Entry e) => '\'${e.url}\',').join();

  DateTime lastModified;
  for (_Entry e in list) {
    lastModified = (lastModified?.isBefore(e.lastModified) ?? true)
        ? e.lastModified
        : lastModified;
  }
  if (lastModified == null) {
    lastModified = new DateTime.now();
  }

  String src = '''
    /// URLs from build/web
    final List<String> assetUrls = [$listItems];
    /// Last modified timestamp in build/web
    final DateTime assetsLastModified = new DateTime.fromMicrosecondsSinceEpoch(${lastModified.toUtc().millisecondsSinceEpoch}, isUtc: true);
  ''';
  src = new DartFormatter().format(src);

  if (output.existsSync()) {
    String oldContent = output.readAsStringSync();
    if (oldContent == src) {
      // No need to override the file
      return;
    }
  } else {
    output.parent.createSync(recursive: true);
  }
  output.writeAsStringSync(src);
}

RegExp _toPattern(String pattern) {
  if (pattern.startsWith('*')) {
    pattern = pattern.replaceAll('.', '\\.');
    pattern = '.$pattern\$';
  }
  return new RegExp(pattern);
}

class _Entry {
  String url;
  DateTime lastModified;
//
//  String hash;

  _Entry(this.url, this.lastModified);
}
