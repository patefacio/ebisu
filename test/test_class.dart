library ebisu.test_class;

import 'package:ebisu/ebisu.dart';
import 'package:logging/logging.dart';
import 'package:test/test.dart';

// custom <additional imports>
import 'package:ebisu/ebisu_dart_meta.dart';
// end <additional imports>

final _logger = new Logger('test_class');

// custom <library test_class>

// end <library test_class>

main([List<String> args]) {
  Logger.root.onRecord.listen(
      (LogRecord r) => print("${r.loggerName} [${r.level}]:\t${r.message}"));
  Logger.root.level = Level.OFF;
// custom <main>

  test('class has protect block by default', () {
    expect(darkMatter(class_('a').definition), darkMatter('''
class A {
  // custom <class A>
  // end <class A>
}
'''));
  });

  test('nulling the tag turns off protect block', () {
    expect(darkMatter((class_('a')..tag = null).definition), darkMatter('''
class A {}
'''));
  });

  test('basic hasOpEquals', () {
    expect(
        darkMatter((class_('a')
                  ..members = [member('a'), member('b')]
                  ..hasOpEquals = true)
                .definition)
            .contains(darkMatter('''
  bool operator==(A other) =>
    identical(this, other) ||
    a == other.a &&
    b == other.b;
''')),
        true);

    print((class_('a')
          ..members = [member('a'), member('b')]
          ..hasUntypedOpEquals = true)
        .definition);
    expect(
        darkMatter((class_('a')
                  ..members = [member('a'), member('b')]
                  ..hasUntypedOpEquals = true)
                .definition)
            .contains(darkMatter('''
  bool operator==(other) =>
    identical(this, other) || (runtimeType == other.runtimeType &&
    a == other.a &&
    b == other.b);
''')),
        true);
  });

// end <main>
}
