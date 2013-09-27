import 'utils.dart';
import 'package:unittest/unittest.dart';
import 'test_it.dart' as test_it;

get rootPath => packageRootPath;

void testCore(Configuration config) {
  unittestConfiguration = config;
  main();
}

main() {
  test_it.main();
}

