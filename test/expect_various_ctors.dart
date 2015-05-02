library ebisu.expect_various_ctors;

import 'package:unittest/unittest.dart';
import 'scratch_remove_me/lib/various_ctors.dart';
import 'package:logging/logging.dart';
import 'package:unittest/unittest.dart';
import 'package:args/args.dart';
// custom <additional imports>
// end <additional imports>

final _logger = new Logger('expect_various_ctors');

// custom <library expect_various_ctors>
// end <library expect_various_ctors>

main([List<String> args]) {
  Logger.root.onRecord.listen(
      (LogRecord r) => print("${r.loggerName} [${r.level}]:\t${r.message}"));
  Logger.root.level = Level.OFF;
// custom <main>

  test('should generate ctor with first member required initialized',
      () => expect(new VariousCtors(7.5).one, 7.5));
  test('should generate default ctor with second and third optional', () {
    expect(new VariousCtors(7.5, '8').two, '8');
    expect(new VariousCtors(7.5, '8', 9).three, 9);
  });

  test('should generate named ctor with single optional', () {
    expect(new VariousCtors.fromFive().five, 5);
    expect(new VariousCtors.fromFive(6).five, 6);
  });

  test('should generate named ctor with one required and one optional', () {
    expect(new VariousCtors.fromThreeAndFour(5).three, 5);
    expect(new VariousCtors.fromThreeAndFour(5).four, 90);
    expect(new VariousCtors.fromThreeAndFour(-1, four: -2).three, -1);
    expect(new VariousCtors.fromThreeAndFour(-1, four: -2).four, -2);
  });

// end <main>

}
