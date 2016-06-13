library ebisu.test_member;

import 'package:ebisu/ebisu.dart';
import 'package:logging/logging.dart';
import 'package:test/test.dart';

// custom <additional imports>

import 'package:ebisu/ebisu_dart_meta.dart';

// end <additional imports>

final Logger _logger = new Logger('test_member');

// custom <library test_member>
// end <library test_member>

void main([List<String> args]) {
  Logger.root.onRecord.listen(
      (LogRecord r) => print("${r.loggerName} [${r.level}]:\t${r.message}"));
  Logger.root.level = Level.OFF;
// custom <main>

  test('isOverride', () {
    final cls = class_('foo')..members.add(member('foo')..isOverride = true);
    expect(
        darkMatter(cls.definition).contains(darkMatter('@override String foo')),
        true);
  });

  test('isObservable', () {
    final cls = class_('foo')..members.add(member('foo')..isObservable = true);
    expect(
        darkMatter(cls.definition).contains(darkMatter('@observable String foo')),
        true);
  });

// end <main>
}
