import 'utils.dart';
import 'package:unittest/unittest.dart';
import 'test_functions.dart' as test_functions;
import 'test_code_generation.dart' as test_code_generation;

get rootPath => packageRootPath;

void testCore(Configuration config) {
  unittestConfiguration = config;
  main();
}

main() {
  test_functions.main();
  test_code_generation.main();
}

