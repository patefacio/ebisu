library ebisu.test.test_dart_meta;

import 'package:args/args.dart';
import 'package:ebisu/ebisu_dart_meta.dart';
import 'package:logging/logging.dart';
import 'package:unittest/unittest.dart';
// custom <additional imports>
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

// end <main>

}
