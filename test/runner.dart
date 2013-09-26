import 'package:unittest/unittest.dart';
import 'package:unittest/vm_config.dart';
import 'test_code_generation.dart' as test_code_generation;

void testCore(Configuration config) {
  unittestConfiguration = config;
  main();
}

main() {
  test_code_generation.main();
}

