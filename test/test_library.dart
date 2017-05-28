library ebisu.test_library;

import 'package:logging/logging.dart';
import 'package:test/test.dart';

// custom <additional imports>

import 'package:ebisu/ebisu_dart_meta.dart';

// end <additional imports>

final Logger _logger = new Logger('test_library');

// custom <library test_library>
// end <library test_library>

void main([List<String> args]) {
  if (args?.isEmpty ?? false) {
    Logger.root.onRecord.listen(
        (LogRecord r) => print("${r.loggerName} [${r.level}]:\t${r.message}"));
    Logger.root.level = Level.OFF;
  }
// custom <main>

  test('export statement', () {
    final l = library('has_exports')
      ..exports = [
        'src/details.dart',
      ];
    expect(l.tar.contains("export 'src/details.dart';"), true);
  });

  test('library group', () {
    final s = system('sys')
      ..libraryGroups = [
        libraryGroup('feature_set')
          ..externalLibraries = [
            library('clean'),
          ]
          ..internalLibraries = [
            library('details'),
          ]
      ];

    s.setAsRoot();
    final lg = s.libraryGroups.first;
    final cleanLib = lg.externalLibraries.first;
    final detailsLib = lg.internalLibraries.first;

    expect(cleanLib.path, 'null/lib');
    expect(detailsLib.path, 'null/lib/src/feature_set');
  });

  test('library path', () {
    final sys = system('sys')
      ..rootPath = '/goo'
      ..libraries = [
        library('normal_lib'),
        library('private_lib')..isPrivate = true,
        library('placed_lib')..path = '/wherever/foo/boo',
      ]
      ..setAsRoot();

    expect(sys.libraries.first.libStubPath, '/goo/lib/normal_lib.dart');
    expect(sys.libraries[1].libStubPath, '/goo/lib/src/private_lib.dart');
    expect(sys.libraries.last.libStubPath, '/wherever/foo/boo/placed_lib.dart');
  });

// end <main>
}
