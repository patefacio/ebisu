library ebisu.test_drudge_script;

import 'package:drudge/drudge.dart';
import 'package:logging/logging.dart';
import 'package:test/test.dart';

// custom <additional imports>
// end <additional imports>

final _logger = new Logger('test_drudge_script');

// custom <library test_drudge_script>
// end <library test_drudge_script>

main([List<String> args]) {
  Logger.root.onRecord.listen(
      (LogRecord r) => print("${r.loggerName} [${r.level}]:\t${r.message}"));
  Logger.root.level = Level.OFF;
// custom <main>
// end <main>
}
