import 'package:logging/logging.dart';
import 'test_dart_meta.dart' as test_dart_meta;
import 'test_functions.dart' as test_functions;
import 'test_library.dart' as test_library;
import 'test_enums.dart' as test_enums;
import 'test_class.dart' as test_class;
import 'test_annotation.dart' as test_annotation;
import 'test_member.dart' as test_member;
import 'test_entity.dart' as test_entity;
import 'test_drudge_script.dart' as test_drudge_script;
import 'test_code_generation.dart' as test_code_generation;
import 'test_ebisu_project.dart' as test_ebisu_project;
import 'test_command_line_parser.dart' as test_command_line_parser;

main() {
  Logger.root.level = Level.OFF;
  Logger.root.onRecord.listen((LogRecord rec) {
    print('${rec.level.name}: ${rec.time}: ${rec.message}');
  });

  test_dart_meta.main();
  test_functions.main();
  test_library.main();
  test_enums.main();
  test_class.main();
  test_annotation.main();
  test_member.main();
  test_entity.main();
  test_drudge_script.main();
  test_code_generation.main();
  test_ebisu_project.main();
  test_command_line_parser.main();
}
