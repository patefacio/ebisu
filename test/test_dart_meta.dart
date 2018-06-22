library ebisu.test_dart_meta;

import 'package:ebisu/ebisu_dart_meta.dart';
import 'package:logging/logging.dart';
import 'package:test/test.dart';

// custom <additional imports>

// end <additional imports>

final Logger _logger = new Logger('test_dart_meta');

// custom <library test_dart_meta>
// end <library test_dart_meta>

void main([List<String> args]) {
  if (args?.isEmpty ?? false) {
    Logger.root.onRecord.listen(
        (LogRecord r) => print("${r.loggerName} [${r.level}]:\t${r.message}"));
    Logger.root.level = Level.OFF;
  }
// custom <main>

  test('cleanImports', () {
    expect(
        cleanImports([
          'dart',
          'io',
          '"packages:awesome/awesome.dart" as awesome',
          "'packages:awesome/awesome.dart' as awesome",
        ]),
        ["'packages:awesome/awesome.dart' as awesome", 'dart', 'io']);
  });

  group('mainCustomBlock', () {
    final l1 = library_('x')..mainCustomBlock.snippets.add('// foo');
    final l2 = library_('x')
      ..mainCustomBlock.snippets.add('// foo')
      ..includesMain = true;

    test('tar shows contents', () {
      [l1, l2].forEach((Library l) {
        expect(l.tar.contains('// foo'), true);
        //expect(l.tar.contains('// foo'));
      });
    });
  });

// end <main>
}
