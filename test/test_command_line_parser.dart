library ebisu.test_command_line_parser;

import 'package:ebisu/ebisu.dart';
import 'package:logging/logging.dart';
import 'package:test/test.dart';

// custom <additional imports>
// end <additional imports>

final Logger _logger = new Logger('test_command_line_parser');

// custom <library test_command_line_parser>
// end <library test_command_line_parser>

void main([List<String> args]) {
  if (args?.isEmpty ?? false) {
    Logger.root.onRecord.listen(
        (LogRecord r) => print("${r.loggerName} [${r.level}]:\t${r.message}"));
    Logger.root.level = Level.OFF;
  }
// custom <main>

  group('command line parser', () {
    test('short form one arg', () {
      final clp = new CommandLineParser('-s');
      expect(clp.argDetails[0],
          new ArgDetails(0, parsedOption: new ParsedOption('-s', null)));
    });

    test('short form', () {
      final clp = new CommandLineParser('-s -x stuff -y -z foo bar goo');
      expect(clp.argDetails[0],
          new ArgDetails(0, parsedOption: new ParsedOption('-s', null)));
      expect(clp.argDetails[1],
          new ArgDetails(1, parsedOption: new ParsedOption('-x', 'stuff')));
      expect(clp.argDetails[2],
          new ArgDetails(3, parsedOption: new ParsedOption('-y', null)));
      expect(clp.argDetails[3],
          new ArgDetails(4, parsedOption: new ParsedOption('-z', 'foo')));
    });

    test('long form', () {
      final clp = new CommandLineParser(
          '--long-arg=foo --long-arg again -x --another-long-arg stuff --final-long-arg no-equals foo');

      expect(
          clp.argDetails[0],
          new ArgDetails(0,
              parsedOption: new ParsedOption('--long-arg', 'foo')));
      expect(
          clp.argDetails[1],
          new ArgDetails(1,
              parsedOption: new ParsedOption('--long-arg', 'again')));
      expect(clp.argDetails[2],
          new ArgDetails(3, parsedOption: new ParsedOption('-x', null)));
      expect(
          clp.argDetails[3],
          new ArgDetails(4,
              parsedOption: new ParsedOption('--another-long-arg', 'stuff')));
      expect(
          clp.argDetails[4],
          new ArgDetails(6,
              parsedOption: new ParsedOption('--final-long-arg', 'no-equals')));
    });
  });

// end <main>
}
