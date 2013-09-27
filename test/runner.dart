import 'utils.dart';
import 'package:unittest/unittest.dart';
import 'test_code_generation.dart' as test_code_generation;

get rootPath => packageRootPath;

void testCore(Configuration config) {
  unittestConfiguration = config;
  main();
}

main() {
  test_code_generation.main();
}

