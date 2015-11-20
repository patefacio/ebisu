library ebisu.test_library;

import 'package:logging/logging.dart';
import 'package:test/test.dart';

// custom <additional imports>

import 'package:ebisu/ebisu_dart_meta.dart';

// end <additional imports>

final _logger = new Logger('test_library');

// custom <library test_library>
// end <library test_library>

main([List<String> args]) {
  Logger.root.onRecord.listen(
      (LogRecord r) => print("${r.loggerName} [${r.level}]:\t${r.message}"));
  Logger.root.level = Level.OFF;
// custom <main>

  test('export statement', () {
    final l = library('has_exports')..exports = ['src/details.dart',];
    expect(l.tar.contains("export 'src/details.dart';"), true);
  });

  test('library group', () {
    final s = system('sys')
      ..libraryGroups = [
        libraryGroup('feature_set')
          ..externalLibraries = [library('clean'),]
          ..internalLibraries = [library('details'),]
      ];

    s.setAsRoot();
    final lg = s.libraryGroups.first;
    final cleanLib = lg.externalLibraries.first;
    final detailsLib = lg.internalLibraries.first;

    expect(cleanLib.path, 'null/lib');
    expect(detailsLib.path, 'null/lib/src/feature_set');
  });

// end <main>
}
