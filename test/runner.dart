import 'package:unittest/unittest.dart';
import 'package:unittest/vm_config.dart';
import 'test_basic_class.dart' as test_basic_class;

void testCore(Configuration config) {
  unittestConfiguration = config;
  main();
}

main() {
  test_basic_class.main();
}

