import 'package:unittest/unittest.dart';
import 'package:logging/logging.dart';
import 'test_functions.dart' as test_functions;
import 'test_code_generation.dart' as test_code_generation;

void testCore(Configuration config) {
  unittestConfiguration = config;
  main();
}

main() {
  Logger.root.level = Level.OFF;
  Logger.root.onRecord.listen((LogRecord rec) {
    print('${rec.level.name}: ${rec.time}: ${rec.message}');
  });

  test_functions.main();
  test_code_generation.main();
}

