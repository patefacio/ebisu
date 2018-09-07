library ebisu.test_code_generation;

import 'dart:async';
import 'dart:io';
import 'package:ebisu/ebisu_dart_meta.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart';
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';
import 'setup.dart';

// custom <additional imports>

import 'package:ebisu/ebisu.dart';

// end <additional imports>

final Logger _logger = new Logger('test_code_generation');

// custom <library test_code_generation>

var author = 'Ignatius J. Reilly';
var pubDoc = 'Test pubspec';
var pubVersion = '1.1.1';
var pubHomepage = 'http://confederacy_of_dunces.com';
var license = 'This is free stuff as in beer';

void generateTestLibraries() {
  // First - nothing up the sleeve - remove any preexisting generated code
  destroyTempData();

  var testSystem = tempSystem('test_code_generation')
    ..license = license
    ..pubSpec.doc = pubDoc
    ..pubSpec.author = author
    ..pubSpec.version = pubVersion
    ..pubSpec.homepage = pubHomepage
    ..pubSpec.addDependency(pubdep('quiver'))
    ..pubSpec.addDevDependency(pubdep('test'))
    ..libraries = [
      library_('basic_class')
        ..imports = [
          'io',
          'async',
          'package:path/path.dart',
        ]
        ..enums = [
          enum_('color')
            ..hasJsonSupport = true
            ..values = [id('red'), id('green'), id('blue')]
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
            ]
            ..customCodeBlock.snippets.add('''
Future<bool> fooExists() async => (await new File("foo").exists());
Stream<List<int>> get fooStream => new File(join('/', 'foo')).openRead();
'''),
          class_('class_with_init')
            ..members = [
              member('m_string')..init = 'foo',
              member('m_int')
                ..type = 'int'
                ..init = '0',
              member('m_double')
                ..type = 'double'
                ..init = '0.0',
              member('m_num')
                ..type = 'num'
                ..init = 3.14,
              member('m_bool')
                ..type = 'bool'
                ..init = 'false',
              member('m_list_int')
                ..type = 'List<int>'
                ..init = '[]',
              member('m_string_string')
                ..type = 'Map<String,String>'
                ..init = '{}'
            ],
          class_('class_with_inferred_type')
            ..members = [
              member('m_string')..init = 'foo',
              member('m_int')..init = 0,
              member('m_double')..init = 1.0,
              member('m_bool')..init = false,
              member('m_list')..init = [],
              member('m_map')..init = {},
            ],
          class_('class_read_only')
            ..defaultMemberAccess = RO
            ..members = [
              member('m_string')..init = 'foo',
              member('m_int')..init = 3,
              member('m_double')..init = 3.14,
              member('m_bool')..init = false,
              member('m_list')..init = [1, 2, 3],
              member('m_map')..init = {1: 2},
            ],
          class_('class_inaccessible')
            ..defaultMemberAccess = IA
            ..members = [
              member('m_string')..init = 'foo',
              member('m_int')..init = 3,
              member('m_double')..init = 3.14,
              member('m_bool')..init = false,
              member('m_list')..init = [1, 2, 3],
              member('m_map')..init = {1: 2},
            ],
          class_('simple_json')
            ..hasDefaultCtor = true
            ..hasJsonSupport = true
            ..members = [member('m_string')..init = 'whoop'],
          class_('courtesy_ctor')
            ..defaultCtorStyle = requiredParms
            ..members = [
              member('m_string')..init = 'whoop',
              member('m_secret')..init = 42,
            ],
          class_('class_json')
            ..defaultMemberAccess = RO
            ..hasDefaultCtor = true
            ..hasJsonSupport = true
            ..members = [
              member('m_string')..init = 'foo',
              member('m_int')..init = 3,
              member('m_double')..init = 3.14,
              member('m_bool')..init = false,
              member('m_list')..init = [1, 2, 3],
              member('m_map')..init = {1: 2},
              member('m_enum')
                ..type = 'Color'
                ..init = 'Color.GREEN',
              member('m_color_map')
                ..type = 'Map<Color,String>'
                ..init = '{ Color.GREEN: "olive" }',
              member('m_color_color_map')
                ..type = 'Map<Color,Color>'
                ..init = '{ Color.GREEN: Color.RED }',
              member('m_string_simple_map')
                ..type = 'Map<String,SimpleJson>'
                ..init = '{ "foo" : new SimpleJson() }',
            ],
          class_('class_json_outer')
            ..defaultMemberAccess = RO
            ..hasDefaultCtor = true
            ..hasJsonSupport = true
            ..members = [
              member('m_nested')
                ..type = 'ClassJson'
                ..init = 'new ClassJson()',
            ]
        ],
      library_('various_ctors')
        ..includesMain = true
        ..classes = [
          class_('various_ctors')
            ..members = [
              member('one')
                ..init = 1.00001
                ..ctors = [''],
              member('two')
                ..init = 'two'
                ..ctorsOpt = [''],
              member('three')
                ..init = 3
                ..ctors = ['fromThreeAndFour']
                ..ctorsOpt = [''],
              member('four')
                ..init = 4
                ..ctorInit = '90'
                ..ctorsNamed = ['fromThreeAndFour'],
              member('five')
                ..init = 2
                ..ctorInit = '5'
                ..ctorsOpt = ['fromFive'],
              member('six')..ctorsOpt = [''],
              member('seven')
                ..access = RO
                ..ctorsOpt = [''],
            ]
        ],
      library_('two_parts')
        ..variables = [
          variable('l_v1_public')..init = 4,
          variable('l_v1_private')
            ..isPublic = false
            ..init = 'foo'
        ]
        ..parts = [
          part('p1')
            ..variables = [
              variable('p1_v1')..init = 3,
              variable('p1_v2')..init = 4
            ]
            ..classes = [
              class_('p1_c1'),
              class_('p1_c2'),
            ],
          part('p2')
            ..variables = [
              variable('p2_v1')..init = 'goo',
            ]
            ..classes = [
              class_('p2_c1'),
              class_('p2_c2'),
            ],
        ]
    ];

  useDartFormatter = true;
  testSystem.generate();
}

// end <library test_code_generation>

void main([List<String> args]) {
  if (args?.isEmpty ?? false) {
    Logger.root.onRecord.listen(
        (LogRecord r) => print("${r.loggerName} [${r.level}]:\t${r.message}"));
    Logger.root.level = Level.OFF;
  }
// custom <main>

  // Logger.root.onRecord.listen((LogRecord r) =>
  //    print("${r.loggerName} [${r.level}]:\t${r.message}"));

  generateTestLibraries();

  var libPath = joinAll([tempPath, 'lib']);
  bool exists(String filePath) => new File(filePath).existsSync();

  group('test_code_generation', () {
    group('library contents', () {
      var contents =
          new File(join(libPath, 'basic_class.dart')).readAsStringSync();
      test("import recognizes 'io'",
          () => expect(contents.indexOf("import 'dart:io';") >= 0, true));
      test("import recognizes 'async'",
          () => expect(contents.indexOf("import 'dart:async';") >= 0, true));
      test(
          "import imports 'path'",
          () => expect(
              contents.indexOf("import 'package:path/path.dart';") >= 0, true));
      test("library defines ClassNoInit",
          () => expect(contents.indexOf("class ClassNoInit") >= 0, true));
      test("library defines ClassWithInit",
          () => expect(contents.indexOf("class ClassWithInit") >= 0, true));
    });

    group('license contents', () {
      var contents = new File(join(tempPath, 'LICENSE')).readAsStringSync();
      test('license contents', () => expect(contents, license));
    });

    group('pubspec contents', () {
      var contents =
          new File(join(tempPath, 'pubspec.yaml')).readAsStringSync();
      var yaml = loadYaml(contents);
      test('pubspec name', () => expect(yaml['name'], 'test_code_generation'));
      test('pubspec author', () => expect(yaml['author'], author));
      test('pubspec version', () => expect(yaml['version'], pubVersion));
      test('pubspec doc', () => expect(yaml['description'].trim(), pubDoc));
      test('pubspec homepage',
          () => expect(yaml['homepage'].trim(), pubHomepage));
      test('pubspec dep quiver',
          () => expect(yaml['dependencies']['quiver'] != null, true));
      test('pubspec user supplied dev dep test',
          () => expect(yaml['dev_dependencies']['test'] != null, true));
    });
    test('.gitignore exists',
        () => expect(exists(join(tempPath, '.gitignore')), true));
    test('test/runner.dart exists',
        () => expect(exists(joinAll([tempPath, 'test', 'runner.dart'])), true));
  });

  group('subprocesses', () {
    String packageRootPath =
        dirname(dirname(absolute(Platform.script.toFilePath())));
    String testPath = join(packageRootPath, 'test');

    //////////////////////////////////////////////////////////////////////
    // Invoke tests on generated code
    //////////////////////////////////////////////////////////////////////
    [
      'expect_basic_class.dart',
      'expect_various_ctors.dart',
      'expect_multi_parts.dart',
    ].forEach((dartFile) {
      dartFile = join(testPath, dartFile);

      test('$dartFile completed', () {
        return Process.run(Platform.executable, [dartFile])
            .then((ProcessResult processResult) {
          print("Results of running dart subprocess $dartFile");
          print(processResult.stdout);
          if (processResult.stderr.length > 0) {
            print('STDERR| ' +
                processResult.stderr.split('\n').join('\nSTDERR| '));
          }

          expect(processResult.exitCode, 0);
        });
      });
    });
  });

// end <main>
}
