library ebisu.test_annotation;

import 'package:ebisu/ebisu.dart';
import 'package:logging/logging.dart';
import 'package:test/test.dart';

// custom <additional imports>
import 'package:ebisu/ebisu_dart_meta.dart';
// end <additional imports>

final Logger _logger = new Logger('test_annotation');

// custom <library test_annotation>

// end <library test_annotation>

void main([List<String> args]) {
  Logger.root.onRecord.listen(
      (LogRecord r) => print("${r.loggerName} [${r.level}]:\t${r.message}"));
  Logger.root.level = Level.OFF;
// custom <main>

  test('class annotations', () {
    final cls = class_('goo')
      ..includesProtectBlock = false
      ..annotations = [annotation('@deprecated'), annotation('@proxy')]
      ..members = [member('str')];

    expect(darkMatter(cls.definition), darkMatter('''
@deprecated @proxy class Goo { String str; }
'''));
  });

// end <main>
}
