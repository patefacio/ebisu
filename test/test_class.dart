library ebisu.test_class;

import 'package:ebisu/ebisu.dart';
import 'package:logging/logging.dart';
import 'package:test/test.dart';

// custom <additional imports>
import 'package:ebisu/ebisu_dart_meta.dart';
// end <additional imports>

final Logger _logger = new Logger('test_class');

// custom <library test_class>

// end <library test_class>

void main([List<String> args]) {
  if (args?.isEmpty ?? false) {
    Logger.root.onRecord.listen(
        (LogRecord r) => print("${r.loggerName} [${r.level}]:\t${r.message}"));
    Logger.root.level = Level.OFF;
  }
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
      ..members = [member('a')..init = 3, member('b')..access = RO];

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

    // with front and back parms
    makeClassWithCtorParms() => class_('def_ctor')
      ..members = [member('m1')..init = 3, member('m2')..access = RO]
      ..withDefaultCtor((Ctor ctor) => ctor
        ..frontParms = ['int a', 'String b']
        ..backParms = ['int y', 'String z']);

    expect(
        darkMatter((makeClassWithCtorParms()..defaultCtorStyle = requiredParms)
                .definition)
            .contains(darkMatter('''
  DefCtor(int a, String b, this.m1, this._m2, int y, String z);
''')),
        true);

    expect(
        darkMatter((makeClassWithCtorParms()
                  ..defaultCtorStyle = positionalParms)
                .definition)
            .contains(darkMatter('''
  DefCtor(int a, String b, [ m1, this._m2, int y,String z ])
  : m1 = m1 ?? 3
''')),
        true);

    expect(
        darkMatter((makeClassWithCtorParms()..defaultCtorStyle = namedParms)
                .definition)
            .contains(darkMatter('''
  DefCtor(int a, String b, { m1, m2, int y, String z })
  : m1 = m1 ?? 3, _m2 = m2
''')),
        true);

    /// test with superArgs
    expect(
        darkMatter((makeClassWithCtorParms()
                  ..defaultCtorStyle = namedParms
                  ..withDefaultCtor((ctor) => ctor..superArgs = ['m1', 'm2']))
                .definition)
            .contains(darkMatter('''
  DefCtor(int a, String b, { m1, m2, int y, String z })
  : super(m1, m2), m1 = m1 ?? 3, _m2 = m2
''')),
        true);
  });

  test('ctor sans new', () {
    makeClass() => class_('some_class')
      ..hasCtorSansNew = true
      ..members = [
        member('a')..init = 3,
        member('b')
          ..access = RO
          ..ctors = ['']
      ];

    expect(
        darkMatter((makeClass()
              ..withDefaultCtor((ctor) => ctor
                ..frontParms = ['int a']
                ..backParms = ['String z'])
              ..members.add(member('c')
                ..type = 'Point'
                ..init = 'new Point()'
                ..ctorsOpt = ['']))
            .definition),
        darkMatter('''
class SomeClass {
  SomeClass(int a, this._b, [c, String z]) : c = c ?? new Point();

  int a = 3;
  String get b => _b;
  Point c = new Point();

  // custom <class SomeClass>
  // end <class SomeClass>

  String _b;
}

/// Create SomeClass without new, for more declarative construction
SomeClass someClass(int a, String b, [Point c, String z]) => new SomeClass(a, b, c, z);
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
        member('a')..init = 3,
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

  test('isIn... members', () {
    final c = class_('c')
      ..hasOpEquals = true
      ..isComparable = true
      ..members = [
        member('in_equality'),
        member('not_in_equality')..isInEquality = false,
        member('in_comparable'),
        member('not_in_compare_to')..isInComparable = false,
        member('in_hash_code'),
        member('not_in_hash_code')..isInHashCode = false,
      ];

    expect(darkMatter(c.definition).contains(darkMatter('''
  @override
  bool operator==(C other) =>
    identical(this, other) ||
    inEquality == other.inEquality &&
    inComparable == other.inComparable &&
    notInCompareTo == other.notInCompareTo &&
    inHashCode == other.inHashCode &&
    notInHashCode == other.notInHashCode;

  @override
  int get hashCode => hashObjects([
    inEquality,
    notInEquality,
    inComparable,
    notInCompareTo,
    inHashCode]);

  int compareTo(C other) {
    int result = 0;
    ((result = inEquality.compareTo(other.inEquality)) == 0) &&
    ((result = notInEquality.compareTo(other.notInEquality)) == 0) &&
    ((result = inComparable.compareTo(other.inComparable)) == 0) &&
    ((result = inHashCode.compareTo(other.inHashCode)) == 0) &&
    ((result = notInHashCode.compareTo(other.notInHashCode)) == 0);
    return result;
  }
''')), true);
  });

// end <main>
}
