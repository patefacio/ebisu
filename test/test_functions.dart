library ebisu.test.test_functions;

import 'package:args/args.dart';
import 'package:ebisu/ebisu.dart';
import 'package:logging/logging.dart';
import 'package:unittest/unittest.dart';
// custom <additional imports>
import 'package:id/id.dart';
// end <additional imports>

final _logger = new Logger('test_functions');

// custom <library test_functions>
// end <library test_functions>

main([List<String> args]) {
  Logger.root.onRecord.listen(
      (LogRecord r) => print("${r.loggerName} [${r.level}]:\t${r.message}"));
  Logger.root.level = Level.OFF;
// custom <main>

  test('chomp removes one trailing newline',
      () => expect(chomp("test\n\n"), "test\n"));

  test('chomp can remove multiple new lines',
      () => expect(chomp("test\n\n\n", true), "test"));

  test('indentBlock indents a block, 2 space default', () => expect(indentBlock(
      '''
class C {
  int x;
}
'''), '''
  class C {
    int x;
  }
'''));

  test('indentBlock can indent block 4 spaces', () => expect(indentBlock('''
class C {
  int x;
}
''', '    '), '''
    class C {
      int x;
    }
'''));

  test('prepJoin adds suffix to all but last', () => expect(
      prepJoin(['a', 'b', 'c']).toString(), ['a,', 'b,', 'c'].toString()));

  test('formatFill joins with spaces by default',
      () => expect(formatFill(['a', 'b', 'c']), 'a b c'));

  test('formatFill joins with what you want',
      () => expect(formatFill(['a', 'b', 'c'], sep: ','), 'a,b,c'));

  test('formatFill breaks up long lines', () => expect(formatFill([
    'void foo(',
    'GobbledeeGook fingerPaint,',
    'SpookyCooky fenderBender,',
    'GlobalThermoNuclearWar ww3',
    ')'
  ]), '''void foo( GobbledeeGook fingerPaint, SpookyCooky fenderBender,
  GlobalThermoNuclearWar ww3 )'''));

  test('formatFill breaks up long lines', () => expect(formatFill([
    'void foo(Ding ding,',
    'GobbledeeGook fingerPaint,',
    'SpookyCooky fenderBender,',
    'GlobalThermoNuclearWar ww3)',
  ]), '''
void foo(Ding ding, GobbledeeGook fingerPaint, SpookyCooky fenderBender,
  GlobalThermoNuclearWar ww3)'''));

  test('codeEquivalent ignores space', () => expect(
      codeEquivalent('class C { int x; }', 'class C {\nint x;\n}'), true));

  test('codeEquivalent returns false on mismatch', () => expect(
      codeEquivalent('class C { int x; }', 'Klass C {\nint x;\n}'), false));

  {
    const first = '''
class C {
   // this is a code smell
   int x;
}
''';

    const second = '''
class C {
   // this is good stuff
   int x;
}
''';

    test('codeEquivalent includes line comments',
        () => expect(codeEquivalent(first, second), false));

    test('codeEquivalent can ignore line comments',
        () => expect(codeEquivalent(first, second, stripComments: true), true));
  }

  {
    const first = '''
class C {
   /*
     this is a code smell
    */
   int x;
}
''';

    const second = '''
class C {
   /* this is
      good stuff */
   int x;
}
''';

    test('codeEquivalent includes block comments',
        () => expect(codeEquivalent(first, second), false));

    test('codeEquivalent can ignore block comments',
        () => expect(codeEquivalent(first, second, stripComments: true), true));
  }

  test('addPrefixToId', () {
    expect(addPrefixToId('t', 'bone_steak').snake, 't_bone_steak');
    expect(addPrefixToId(idFromString('t'), idFromString('bone_steak')).snake,
        't_bone_steak');
  });

  test('addSuffixToId', () {
    expect(addSuffixToId('t', 'bone_steak').snake, 'bone_steak_t');
    expect(addSuffixToId(idFromString('t'), idFromString('bone_steak')).snake,
        'bone_steak_t');
  });

  test('br/brCompact/combine', () {
    expect(br(['a', 'b', 'c']), 'a\n\nb\n\nc\n\n');
    expect(br(['a', 'b', 'c'], '\n'), 'a\nb\nc\n');
    expect(br(['a', 'b', 'c'], '\n\n'), 'a\n\nb\n\nc\n\n');

    expect(br(['a', null, 'b', null, 'c']), 'a\n\nb\n\nc\n\n');
    expect(br([null, 'a', 'b', 'c', null], '\n'), 'a\nb\nc\n');
    expect(br(['a', 'b', null, null, 'c'], '\n\n'), 'a\n\nb\n\nc\n\n');

    expect(
        br(['a', [null], [['b']], null, ['c', ['d']]]), 'a\n\nb\n\nc\n\nd\n\n');

    expect(combine(['a', 'b', 'c']), 'abc');
    expect(combine(['a', 'b', 'c'], ''), 'abc');
    expect(combine(['a', 'b', 'c'], ''), 'abc');

    expect(combine(['a', null, 'b', null, 'c']), 'abc');
    expect(combine([null, 'a', 'b', 'c', null], ''), 'abc');
    expect(combine(['a', 'b', null, null, 'c'], ''), 'abc');

    expect(combine(['a', [null], [['b']], null, ['c', ['d']]]), 'abcd');
    expect(brCompact([null, null, 'a\n\n\n', null, null, 'b']), 'a\nb\n');
  });

  test('scriptComment', () {
    expect(darkSame(scriptComment('''
this is
a test'''), '''
#   this is
#   a test
'''), true);

    expect(darkSame(scriptComment('''
this is
a test''', ' '), '''
# this is
# a test
'''), true);
  });

// end <main>

}
