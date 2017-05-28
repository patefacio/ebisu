library ebisu.test_enums;

import 'package:logging/logging.dart';
import 'package:test/test.dart';

// custom <additional imports>
import 'package:ebisu/ebisu.dart';
import 'package:ebisu/ebisu_dart_meta.dart';
// end <additional imports>

final Logger _logger = new Logger('test_enums');

// custom <library test_enums>
// end <library test_enums>

void main([List<String> args]) {
  if (args?.isEmpty ?? false) {
    Logger.root.onRecord.listen(
        (LogRecord r) => print("${r.loggerName} [${r.level}]:\t${r.message}"));
    Logger.root.level = Level.OFF;
  }
// custom <main>

  test('simple enum', () {
    final colorEnum = enum_('rgb')
      ..doc = 'Colors'
      ..setAsRoot()
      ..values = ['red', 'green', 'blue'];
    expect(darkMatter(colorEnum.define()), darkMatter('''
/// Colors
enum Rgb {
  red,
  green,
  blue
}'''));
  });

  test('string casing', () {
    expect(
        darkMatter((enum_('rgb')
                  ..hasCustom = true
                  ..isShoutString = true
                  ..values = ['red', 'green', 'blue'])
                .define())
            .contains(darkMatter('''
  String toString() {
    switch(this) {
      case RED: return "RED";
      case GREEN: return "GREEN";
      case BLUE: return "BLUE";
    }
    return null;
  }

  static Rgb fromString(String s) {
    if(s == null) return null;
    switch(s) {
      case "RED": return RED;
      case "GREEN": return GREEN;
      case "BLUE": return BLUE;
      default: return null;
    }
  }
''')),
        true);

    expect(
        darkMatter((enum_('rgb')
                  ..hasCustom = true
                  ..isSnakeString = true
                  ..values = ['red', 'green', 'blue'])
                .define())
            .contains(darkMatter('''
  String toString() {
    switch(this) {
      case RED: return "red";
      case GREEN: return "green";
      case BLUE: return "blue";
    }
    return null;
  }

  static Rgb fromString(String s) {
    if(s == null) return null;
    switch(s) {
      case "red": return RED;
      case "green": return GREEN;
      case "blue": return BLUE;
      default: return null;
    }
  }
''')),
        true);
  });

// end <main>
}
