library pwa.offline;

import 'dart:io';

import 'package:dart_style/dart_style.dart';

main(List<String> args) {
  // TODO: make these configurable
  String baseDir = 'build/web';
  String defaultFile = 'index.html';
  File output = new File('lib/pwa/offline.g.dart');
  // TODO: remove these from Angular build in another way?
  // TODO: provide reasonable defaults for common files that can be ignored
  List<String> excludes = ['*.ng_meta.json', '*.ng_summary.json'];

  // derived regex
  // TODO: use better pattern-matching library
  List<RegExp> excludePatterns = excludes.map(_toPattern).toList();

  List<String> list = new Directory('build/web')
      .listSync(recursive: true)
      .where((fse) => fse is File)
      .map((file) => file.path.substring(baseDir.length))
      .where((String path) =>
          !excludePatterns.any((RegExp pattern) => pattern.hasMatch(path)))
      .map((String path) {
        if (path.endsWith('/$defaultFile')) {
          return path.substring(0, path.length - defaultFile.length);
        } else {
          return path;
        }
      })
      .map((url) => '\'$url\',')
      .toList()..sort();

  String src = '''
    /// URLs of the output files in build/web
    final List<String> offlineUrls = [${list.join()}];
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
