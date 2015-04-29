library ebisu.test.test_dart_meta;

import 'package:args/args.dart';
import 'package:ebisu/ebisu_dart_meta.dart';
import 'package:logging/logging.dart';
import 'package:unittest/unittest.dart';
// custom <additional imports>
import 'package:ebisu/ebisu.dart';
// end <additional imports>

final _logger = new Logger('test_dart_meta');

// custom <library test_dart_meta>
// end <library test_dart_meta>

main([List<String> args]) {
  Logger.root.onRecord.listen(
      (LogRecord r) => print("${r.loggerName} [${r.level}]:\t${r.message}"));
  Logger.root.level = Level.OFF;
// custom <main>

  test('cleanImports', () {
    expect(cleanImports([
      'dart',
      'io',
      '"packages:awesome/awesome.dart" as awesome',
      "'packages:awesome/awesome.dart' as awesome",
    ]), ["'packages:awesome/awesome.dart' as awesome", 'dart', 'io']);
  });

  group('mainCustomBlock', () {
    final l1 = library('x')..mainCustomBlock.snippets.add('// foo');
    final l2 = library('x')
      ..mainCustomBlock.snippets.add('// foo')
      ..includesMain = true;

    [l1, l2].forEach((Library l) {
      expect(darkMatter(l.tar).contains('// foo'), true);
    });
  });

// end <main>

}
