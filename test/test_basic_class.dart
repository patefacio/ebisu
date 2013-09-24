library test_basic_class;

import 'dart:io';
import 'package:ebisu/ebisu_dart_meta.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart';
import 'package:unittest/unittest.dart';
import 'package:yaml/yaml.dart';
import 'setup.dart';
// custom <additional imports>
// end <additional imports>


final _logger = new Logger("test_basic_class");

// custom <library test_basic_class>
// end <library test_basic_class>

main() { 
// custom <main>

  //Logger.root.onRecord.listen((LogRecord r) =>
  //    print("${r.loggerName} [${r.level}]:\t${r.message}"));

  var author = 'Ignatius J. Reilly';
  var pubDoc = 'Test pubspec';
  var pubVersion = '1.1.1';

  var testSystem = tempSystem('test_basic_class')
    ..includeHop = true
    ..pubSpec.doc = pubDoc
    ..pubSpec.author = author
    ..pubSpec.version = pubVersion
    ..libraries = [
      library('test_basic_class')
      ..imports = [
        'io',
        'async',
      ]
      ..classes = [
        class_('class_no_init')
        ..members = [
          member('m_string'),
          member('m_int')..type = 'int',
          member('m_double')..type = 'double',
          member('m_list_int')..type = 'List<int>',
          member('m_string_string')..type = 'Map<String,String>'
        ],
        class_('class_with_init')
        ..members = [
          member('m_string')..classInit = 'foo',
          member('m_int')..type = 'int'..classInit = '0',
          member('m_double')..type = 'double'..classInit = '0.0',
          member('m_list_int')..type = 'List<int>'..classInit = '[]',
          member('m_string_string')..type = 'Map<String,String>'..classInit = '{}'
        ]
      ]
    ];

  testSystem.generate();

  var libPath = joinAll([tempPath, 'lib']);
  bool exists(String filePath) => new File(filePath).existsSync();

  group('test_basic_class', () {
    test('library file exists', () =>
        expect(exists(join(libPath, 'test_basic_class.dart')), true));
    group('library contents', () {
      var contents = 
        new File(join(libPath, 'test_basic_class.dart')).readAsStringSync();
      test("import recognizes 'io'", 
          () => expect(contents.indexOf("import 'dart:io';") >=0, true));
      test("import recognizes 'async'", 
          () => expect(contents.indexOf("import 'dart:async';") >=0, true));
      test("library defines ClassNoInit", 
          () => expect(contents.indexOf("class ClassNoInit") >=0, true));
      test("library defines ClassWithInit", 
          () => expect(contents.indexOf("class ClassWithInit") >=0, true));
    });        
    
    test('pubspec exists', () =>
        expect(exists(join(tempPath, 'pubspec.yaml')), true));
    group('pubspec contents', () {
      var contents = new File(join(tempPath, 'pubspec.yaml')).readAsStringSync();
      var yaml = loadYaml(contents);
      test('pubspec name', () => expect(yaml['name'], 'test_basic_class'));
      test('pubspec author', () => expect(yaml['author'], author));
      test('pubspec version', () => expect(yaml['version'], pubVersion));
      test('pubspec doc', () => expect(yaml['description'].trim(), pubDoc));
      test('pubspec hop', () => 
          expect(yaml['dev_dependencies']['hop'] != null, true));
    });
    test('.gitignore exists', () =>
        expect(exists(join(tempPath, '.gitignore')), true));
    test('tool/hop_runner.dart exists', () =>
        expect(exists(joinAll([tempPath, 'tool', 'hop_runner.dart'])), true));
    test('test/utils.dart exists', () =>
        expect(exists(joinAll([tempPath, 'test', 'utils.dart'])), true));
    test('test/runner.dart exists', () =>
        expect(exists(joinAll([tempPath, 'test', 'runner.dart'])), true));
  });

  var runCode = (code) {
    print("Running $code");
    
  };

  group('code_usage', () {
    test('basic_usage', () {
      runCode('''
import 'scratch_remove_me/lib/test_basic_class.dart';

''');
    });
  });

// end <main>

}
