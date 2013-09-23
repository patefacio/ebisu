import 'package:unittest/unittest.dart';
import 'package:unittest/vm_config.dart';
import 'test_basic_class.dart' as test_basic_class;
import 'test_member_access.dart' as test_member_access;
import 'test_multipart_library.dart' as test_multipart_library;

void testCore(Configuration config) {
  unittestConfiguration = config;
  main();
}

main() {
  test_basic_class.main();
  test_member_access.main();
  test_multipart_library.main();
}

