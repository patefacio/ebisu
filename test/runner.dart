import 'package:logging/logging.dart';
import 'test_dart_meta.dart' as test_dart_meta;
import 'test_functions.dart' as test_functions;
import 'test_code_block.dart' as test_code_block;
import 'test_library.dart' as test_library;
import 'test_enums.dart' as test_enums;
import 'test_class.dart' as test_class;
import 'test_annotation.dart' as test_annotation;
import 'test_member.dart' as test_member;
import 'test_entity.dart' as test_entity;
import 'test_code_generation.dart' as test_code_generation;
import 'test_ebisu_project.dart' as test_ebisu_project;
import 'test_command_line_parser.dart' as test_command_line_parser;

void main() {
  Logger.root.level = Level.OFF;
  Logger.root.onRecord.listen((LogRecord rec) {
    print('${rec.level.name}: ${rec.time}: ${rec.message}');
  });

  test_dart_meta.main(null);
  test_functions.main(null);
  test_code_block.main(null);
  test_library.main(null);
  test_enums.main(null);
  test_class.main(null);
  test_annotation.main(null);
  test_member.main(null);
  test_entity.main(null);
  test_code_generation.main(null);
  test_ebisu_project.main(null);
  test_command_line_parser.main(null);
}
