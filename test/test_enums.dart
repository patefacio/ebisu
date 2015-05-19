library ebisu.test_enums;

import 'package:args/args.dart';
import 'package:logging/logging.dart';
import 'package:test/test.dart';

// custom <additional imports>
import 'package:ebisu/ebisu.dart';
import 'package:ebisu/ebisu_dart_meta.dart';
// end <additional imports>

final _logger = new Logger('test_enums');

// custom <library test_enums>
// end <library test_enums>

main([List<String> args]) {
  Logger.root.onRecord.listen(
      (LogRecord r) => print("${r.loggerName} [${r.level}]:\t${r.message}"));
  Logger.root.level = Level.OFF;
// custom <main>

  test('simple enum', () {
    final colorEnum = enum_('rgb')
      ..doc = 'Colors'
      ..owner = null
      ..values = ['red', 'green', 'blue'];
    expect(darkMatter(colorEnum.define()), darkMatter('''
/// Colors
enum Rgb {
  red,
  green,
  blue
}'''));
  });

// end <main>

}
