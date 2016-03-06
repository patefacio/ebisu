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

  test('courtesy ctor required parms', () {
    makeClass() => class_('def_ctor')
      ..members = [member('a')..classInit = 3, member('b')..access = RO];

    expect(
        darkMatter((makeClass()..defaultCtorStyle = requiredParms).definition)
            .contains(darkMatter('DefCtor(this.a, this._b);')),
        true);

    expect(
        darkMatter((makeClass()..defaultCtorStyle = namedParms).definition)
            .contains(darkMatter('DefCtor({ a, b }) : a = a??3, _b = b;')),
        true);

    expect(
        darkMatter((makeClass()..defaultCtorStyle = positionalParms).definition)
            .contains(darkMatter('DefCtor([ a, this._b ]) : a = a ?? 3;')),
        true);
  });

  test('ctor sans new', () {
    makeClass() => class_('some_class')
      ..hasCtorSansNew = true
      ..members = [
        member('a')..classInit = 3,
        member('b')
          ..access = RO
          ..ctors = ['']
      ];

    expect(
        darkMatter((makeClass()
              ..members.add(member('c')
                ..type = 'Point'
                ..init = 'new Point()'
                ..ctorsOpt = ['']))
            .definition),
        darkMatter('''
class SomeClass {
  SomeClass(this._b, [c]) : c = c ?? new Point();

  int a = 3;
  String get b => _b;
  Point c = new Point();

  // custom <class SomeClass>
  // end <class SomeClass>

  String _b;
}

/// Create SomeClass without new, for more declarative construction
SomeClass someClass(String b, [Point c]) => new SomeClass(b, c);
'''));

    expect(
        darkMatter((makeClass()
              ..members.add(member('c')
                ..type = 'Point'
                ..init = 'new Point()'
                ..ctorsNamed = ['']))
            .definition),
        darkMatter('''
class SomeClass {
  SomeClass(this._b, {c}) : c = c ?? new Point();

  int a = 3;
  String get b => _b;
  Point c = new Point();

  // custom <class SomeClass>
  // end <class SomeClass>

  String _b;
}

/// Create SomeClass without new, for more declarative construction
SomeClass someClass(String b, {Point c}) => new SomeClass(b, c:c);
'''));
  });

  test('withCtor', () {
    final c = class_('some_class')
      ..withCtor(
          'xx',
          (Ctor ctor) => ctor
            ..tag = 'boooya'
            ..snippets.add('// boing'))
      ..members = [
        member('a')..classInit = 3,
        member('b')
          ..access = RO
          ..ctors = ['']
      ];

    expect(darkMatter(c.definition), darkMatter('''
class SomeClass {
  SomeClass(this._b);

  SomeClass.xx() {
    // custom <boooya>
    // end <boooya>

    // boing
  }

  int a = 3;
  String get b => _b;

  // custom <class SomeClass>
  // end <class SomeClass>

  String _b;
}
'''));
  });

// end <main>
}
