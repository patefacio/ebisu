import 'package:test/test.dart';
import 'package:logging/logging.dart';
import 'test_dart_meta.dart' as test_dart_meta;
import 'test_functions.dart' as test_functions;
import 'test_enums.dart' as test_enums;
import 'test_class.dart' as test_class;
import 'test_entity.dart' as test_entity;
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

  test_dart_meta.main();
  test_functions.main();
  test_enums.main();
  test_class.main();
  test_entity.main();
  test_code_generation.main();
}
