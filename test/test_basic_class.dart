library test_basic_class;

import 'dart:async';
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

var author = 'Ignatius J. Reilly';
var pubDoc = 'Test pubspec';
var pubVersion = '1.1.1';
var pubHomepage = 'http://confederacy_of_dunces.com';
var license = 'This is free stuff as in beer';

void generateTestLibraries() {

  // First - nothing up the sleeve - remove any preexisting generated code
  destroyTempData();

  var testSystem = tempSystem('test_basic_class')
    ..license = license
    ..includeHop = true
    ..pubSpec.doc = pubDoc
    ..pubSpec.author = author
    ..pubSpec.version = pubVersion
    ..pubSpec.homepage = pubHomepage
    ..pubSpec.addDependency(pubdep('quiver'))
    ..pubSpec.addDevDependency(pubdep('unittest'))
    ..libraries = [
      library('basic_class')
      ..imports = [
        'io',
        'async',
        'package:path/path.dart',
      ]
      ..classes = [
        class_('class_no_init')
        ..members = [
          member('m_string'),
          member('m_int')..type = 'int',
          member('m_double')..type = 'double',
          member('m_bool')..type = 'bool',
          member('m_list_int')..type = 'List<int>',
          member('m_string_string')..type = 'Map<String,String>',
        ],
        class_('class_with_init')
        ..members = [
          member('m_string')..classInit = 'foo',
          member('m_int')..type = 'int'..classInit = '0',
          member('m_double')..type = 'double'..classInit = '0.0',
          member('m_num')..type = 'num'..classInit = 3.14,
          member('m_bool')..type = 'bool'..classInit = 'false',
          member('m_list_int')..type = 'List<int>'..classInit = '[]',
          member('m_string_string')..type = 'Map<String,String>'..classInit = '{}'
        ],
        class_('class_with_inferred_type')
        ..members = [
          member('m_string')..classInit = 'foo',
          member('m_int')..classInit = 0,
          member('m_double')..classInit = 0.0,
          member('m_bool')..classInit = false,
          member('m_list')..classInit = [],
          member('m_map')..classInit = {},
        ],
        class_('class_read_only')
        ..defaultMemberAccess = RO
        ..members = [
          member('m_string')..classInit = 'foo',
          member('m_int')..classInit = 3,
          member('m_double')..classInit = 3.14,
          member('m_bool')..classInit = false,
          member('m_list')..classInit = [1,2,3],
          member('m_map')..classInit = {1:2},
        ],
        class_('class_inaccessible')
        ..defaultMemberAccess = IA
        ..members = [
          member('m_string')..classInit = 'foo',
          member('m_int')..classInit = 3,
          member('m_double')..classInit = 3.14,
          member('m_bool')..classInit = false,
          member('m_list')..classInit = [1,2,3],
          member('m_map')..classInit = {1:2},
        ],
        class_('class_json')
        ..defaultMemberAccess = RO
        ..jsonSupport = true
        ..members = [
          member('m_string')..classInit = 'foo',
          member('m_int')..classInit = 3,
          member('m_double')..classInit = 3.14,
          member('m_bool')..classInit = false,
          member('m_list')..classInit = [1,2,3],
          member('m_map')..classInit = {1:2},
        ],
        class_('class_json_outer')
        ..defaultMemberAccess = RO
        ..jsonSupport = true
        ..members = [
          member('m_nested')
          ..type = 'ClassJson'
          ..classInit = 'new ClassJson()',
        ]
      ],
      library('various_ctors')
      ..classes = [
        class_('various_ctors')
        ..members = [
          member('one')..classInit = 1.00001
          ..ctors = [''],
          member('two')..classInit = 'two'
          ..ctorsOpt = [''],
          member('three')..classInit = 3
          ..ctors = ['fromThreeAndFour']
          ..ctorsOpt = [''],
          member('four')
          ..classInit = 4
          ..ctorInit = '90'
          ..ctorsNamed = ['fromThreeAndFour'],
          member('five')
          ..classInit = 2
          ..ctorInit = '5'
          ..ctorsOpt = ['fromFive'],
        ]
      ]
    ];

  testSystem.generate();

}



// end <library test_basic_class>

main() { 
// custom <main>

  // Logger.root.onRecord.listen((LogRecord r) =>
  //    print("${r.loggerName} [${r.level}]:\t${r.message}"));

  generateTestLibraries();
  
  var libPath = joinAll([tempPath, 'lib']);
  bool exists(String filePath) => new File(filePath).existsSync();

  group('test_basic_class', () {

    group('library contents', () {
      var contents = 
        new File(join(libPath, 'basic_class.dart')).readAsStringSync();
      test("import recognizes 'io'", 
          () => expect(contents.indexOf("import 'dart:io';") >=0, true));
      test("import recognizes 'async'", 
          () => expect(contents.indexOf("import 'dart:async';") >=0, true));
      test("import imports 'path'", 
          () => expect(
            contents.indexOf("import 'package:path/path.dart';") >=0, true));
      test("library defines ClassNoInit", 
          () => expect(contents.indexOf("class ClassNoInit") >=0, true));
      test("library defines ClassWithInit", 
          () => expect(contents.indexOf("class ClassWithInit") >=0, true));
    });        

    group('license contents', () {
      var contents = new File(join(tempPath, 'LICENSE')).readAsStringSync();
      test('license contents', () => expect(contents, license));
    });
    
    group('pubspec contents', () {
      var contents = new File(join(tempPath, 'pubspec.yaml')).readAsStringSync();
      var yaml = loadYaml(contents);
      test('pubspec name', () => expect(yaml['name'], 'test_basic_class'));
      test('pubspec author', () => expect(yaml['author'], author));
      test('pubspec version', () => expect(yaml['version'], pubVersion));
      test('pubspec doc', () => expect(yaml['description'].trim(), pubDoc));
      test('pubspec hop', () => 
          expect(yaml['dev_dependencies']['hop'] != null, true));
      test('pubspec homepage', 
          () => expect(yaml['homepage'].trim(), pubHomepage));
      test('pubspec dep quiver', 
          () => expect(yaml['dependencies']['quiver'] != null, true));
      test('pubspec user supplied dev dep unittest', 
          () => expect(yaml['dev_dependencies']['unittest'] != null, true));
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


  group('subprocesses', () {
    List allDartFilesComplete = [];

    [ 
      'expect_basic_class.dart',
      'expect_various_ctors.dart',
    ].forEach((dartFile) {
      Future subprocess =
        Process
        .run(Platform.executable, [ '--checked', dartFile ])
        .then((ProcessResult processResult) {
          test('$dartFile succeeded', () {
            print("Results of running dart subprocess $dartFile");
            print(processResult.stdout);
            expect(processResult.exitCode, 0);
          });
        });

      allDartFilesComplete.add(subprocess);

    });

  });


// end <main>

}
