library ebisu.setup;

import 'dart:io';
import 'package:ebisu/ebisu_dart_meta.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart';
import 'package:test/test.dart';

// custom <additional imports>
// end <additional imports>

final _logger = new Logger('setup');

String _scratchRemoveMeFolder;

// custom <library setup>

String get tempPath {
  if (_scratchRemoveMeFolder == null) {
    String packageRootPath =
        dirname(dirname(absolute(Platform.script.toFilePath())));
    _scratchRemoveMeFolder =
        joinAll([packageRootPath, 'test', 'scratch_remove_me']);
  }

  return _scratchRemoveMeFolder;
}

System tempSystem(String id) => system(id)..rootPath = tempPath;

void destroyTempData() {
  var dir = new Directory(tempPath);
  if (dir.existsSync()) {
    dir.deleteSync(recursive: true);
  }
}

// end <library setup>

main([List<String> args]) {
  Logger.root.onRecord.listen(
      (LogRecord r) => print("${r.loggerName} [${r.level}]:\t${r.message}"));
  Logger.root.level = Level.OFF;
// custom <main>

  test('t', () => expect(1, 1));

// end <main>

}
