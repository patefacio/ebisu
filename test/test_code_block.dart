library ebisu.test_code_block;

import 'package:ebisu/ebisu.dart';
import 'package:logging/logging.dart';
import 'package:test/test.dart';

// custom <additional imports>
// end <additional imports>

final Logger _logger = new Logger('test_code_block');

// custom <library test_code_block>
// end <library test_code_block>

void main([List<String> args]) {
  if (args?.isEmpty ?? false) {
    Logger.root.onRecord.listen(
        (LogRecord r) => print("${r.loggerName} [${r.level}]:\t${r.message}"));
    Logger.root.level = Level.OFF;
  }
// custom <main>

test('code block snippets first', () {
  final cb = codeBlock('cb_1')..snippets = [
    '...this',
    '...is a test'
  ];
  expect(cb.hasSnippetsFirst, false);
  expect(darkMatter(cb),
  darkMatter('''
// custom <cb_1>
// end <cb_1>
...this
...is a test  
  '''));

  final cb2 = cb.copy();
  expect(cb2.hasSnippetsFirst, false);
  cb2.hasSnippetsFirst = true;
  cb2.snippets[0] = '...that';
  /// copy was deep
  expect(cb.snippets[0], '...this');
  expect(darkMatter(cb2),
  darkMatter('''
...that
...is a test
// custom <cb_1>
// end <cb_1>
  '''));

});



// end <main>
}
