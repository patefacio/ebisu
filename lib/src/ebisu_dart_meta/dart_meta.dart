part of ebisu.ebisu_dart_meta;

/// Access for member variable - ia - inaccessible, ro - read/only, rw read/write
class Access implements Comparable<Access> {
  static const IA = const Access._(0);
  static const RO = const Access._(1);
  static const RW = const Access._(2);
  static const WO = const Access._(3);

  static get values => [
    IA,
    RO,
    RW,
    WO
  ];

  final int value;

  int get hashCode => value;

  const Access._(this.value);

  copy() => this;

  int compareTo(Access other) => value.compareTo(other.value);

  String toString() {
    switch(this) {
      case IA: return "Ia";
      case RO: return "Ro";
      case RW: return "Rw";
      case WO: return "Wo";
    }
  }

  static Access fromString(String s) {
    if(s == null) return null;
    switch(s) {
      case "Ia": return IA;
      case "Ro": return RO;
      case "Rw": return RW;
      case "Wo": return WO;
      default: return null;
    }
  }

  int toJson() => value;
  static Access fromJson(int v) {
    return v==null? null : values[v];
  }

}

/// Dependency type of a PubDependency
class PubDepType implements Comparable<PubDepType> {
  static const PATH = const PubDepType._(0);
  static const GIT = const PubDepType._(1);
  static const HOSTED = const PubDepType._(2);

  static get values => [
    PATH,
    GIT,
    HOSTED
  ];

  final int value;

  int get hashCode => value;

  const PubDepType._(this.value);

  copy() => this;

  int compareTo(PubDepType other) => value.compareTo(other.value);

  String toString() {
    switch(this) {
      case PATH: return "Path";
      case GIT: return "Git";
      case HOSTED: return "Hosted";
    }
  }

  static PubDepType fromString(String s) {
    if(s == null) return null;
    switch(s) {
      case "Path": return PATH;
      case "Git": return GIT;
      case "Hosted": return HOSTED;
      default: return null;
    }
  }

  int toJson() => value;
  static PubDepType fromJson(int v) {
    return v==null? null : values[v];
  }

}

/// Defines a dart system (collection of libraries and apps)
class System {

  /// Id for this system
  Id get id => _id;
  /// Documentation for this system
  String doc;
  /// Path to which code is generated
  String rootPath;
  /// Scripts in the system
  List<Script> scripts = [];
  /// App for this package
  App app;
  /// List of test libraries of this app
  List<Library> testLibraries = [];
  /// Libraries in the system
  List<Library> libraries = [];
  /// Regular and test libraries
  List<Library> allLibraries = [];
  /// Information for the pubspec
  PubSpec pubSpec;
  /// Map of all classes that have jsonSupport
  Map<String,Class> jsonableClasses = {};
  /// Set to true on finalize
  bool get finalized => _finalized;
  /// If true generate a pubspec.xml file
  bool generatePubSpec = true;
  /// A string indicating the license.
  /// A map of common licenses is looked up and if found a link
  /// to that license is used. The current keys of the map are:
  /// [ 'boost', 'mit', 'apache-2.0', 'bsd-2', 'bsd-3', 'mozilla-2.0' ]
  /// Otherwise the text is assumed to be the
  /// text to include in the license file.
  String license;
  /// If true standard outline for readme provided
  bool includeReadme = false;
  /// A brief introduction for this system, included in README.md
  String introduction;
  /// Purpose for this system, included in README.md
  String purpose;
  /// List of todos included in the readme - If any present includeReadme assumed true
  List<String> todos = [];
  /// If true generates tool folder with hop_runner
  bool includeHop = false;

// custom <class System>

  /// Create system from the id
  System(Id id) : _id = id, pubSpec = new PubSpec(id) {}

  /// Finalize must be called before generate
  void finalize() {
    if(!_finalized) {

      testLibraries.forEach((library) {
        library.isTest = true;
      });

      allLibraries = new List.from(libraries)..addAll(testLibraries);
      allLibraries.forEach((l) => l.parent = this);
      scripts.forEach((s) => s.parent = this);
      if(app != null) {
        app.parent = this;
      }
      pubSpec.parent = this;

      // Track all classes and enums with json support so the template side can
      // do proper inserts of code. There are classes and enums in the library
      // as well as classes and enums in each part to consider.
      allLibraries.forEach((library) {
        library.classes.forEach((dclass) {
          if(dclass.jsonSupport) {
            jsonableClasses[dclass.name] = dclass;
          }
        });
        library.enums.forEach((e) {
          jsonableClasses[e.name] = e;
        });
        library.parts.forEach((part) {
          part.classes.forEach((dclass) {
            if(dclass.jsonSupport) {
              jsonableClasses[dclass.name] = dclass;
            }
          });
          part.enums.forEach((e) {
            jsonableClasses[e.name] = e;
          });
        });
      });
      _finalized = true;
    }
  }

  void overridePubs() {
    var overrideFile = new File(ebisuPubVersions);
    if(overrideFile.existsSync()) {
      var overrideJson = convert.JSON.decode(overrideFile.readAsStringSync());
      var overrides = overrideJson['versions'];
      _logger.info("Found version overides: ${overrideJson}");
      var deps = new List.from(pubSpec.dependencies)..addAll(pubSpec.devDependencies);
      deps.forEach((dep) {
        var override = overrides[dep.name];
        if(override != null) {
          _logger.info("Overriding: (((\n${dep.yamlEntry}\n))) with ${override}");
          var version = override['version'];
          if(version != null) {
            dep.version = version;
            dep.path = null;
            dep._type = PubDepType.HOSTED;
          } else {
            var path = override['path'];
            if(path != null) {
              dep.path = path;
              dep.version = null;
              dep.gitRef = null;
              dep._type = PubDepType.PATH;
              _logger.info("Yaml: ${dep.yamlEntry}");
            } else {
              throw
                new FormatException('''
Entry ($override) in ${ebisuPubVersions} invalid.
Only "version" and "path" overrides are supported.
''');
            }
          }
        }
      });
    } else {
      _logger.info("NOT Found version overrides: ${ebisuPubVersions}");
    }
  }

  /// Generate the code
  void generate( { generateHop : true, generateRunner : true } ) {

    if(rootPath == null) rootPath = '.';

    if(app != null) {
      if(pubSpec == null) {
        pubSpec = new PubSpec(app.id)
          ..addDependency(new PubDependency('browser'))
          ..addDependency(new PubDependency('path'))
          ..addDependency(new PubDependency('polymer'))
          ;
      }
    }
    finalize();
    scripts.forEach((script) => script.generate());
    if(app != null) {
      app.generate();
    }

    if(includeHop) {
      if(pubSpec.depNotFound('hop')) {
        pubSpec.addDevDependency(new PubDependency('hop'));
      }
    }

    allLibraries.forEach((lib) {
      lib.generate();
      if(lib.includeLogger) {
        if(pubSpec.depNotFound('logging')) {
          pubSpec.addDependency(new PubDependency('logging'));
        }
      }
    });

    if(pubSpec != null && generatePubSpec) {
      overridePubs();
      String pubSpecPath = "${rootPath}/pubspec.yaml";
      scriptMergeWithFile('${pubSpec._content}\n', pubSpecPath);
    }

    if(license != null) {
      var text = licenseMap[license];
      if(text == null) text = license;
      String licensePath = "${rootPath}/LICENSE";
      mergeWithFile(text, licensePath);
    }

    {
      String gitIgnorePath = "${rootPath}/.gitignore";
      scriptMergeWithFile('''
*.~*~
packages
build
${scriptCustomBlock('additional')}
''',
          gitIgnorePath);
    }

    if(includeReadme || todos.length > 0 ||
       introduction != null || purpose != null) {
      String readmePath = "${rootPath}/README.md";
      panDocMergeWithFile('''
# ${id.title}


${(introduction != null)? introduction : ''}
${panDocCustomBlock('introduction')}

# Purpose
${(purpose != null)? purpose : ''}
${panDocCustomBlock('purpose')}

${panDocCustomBlock('body')}

# Examples

${panDocCustomBlock('examples')}

${(todos.length > 0)? "# Todos\n\n- ${todos.join('\n-')}\n${panDocCustomBlock('todos')}" : ""}

''',
          readmePath);
    }

    if(generateHop && includeHop) {
      String hopRunnerPath = "${rootPath}/tool/hop_runner.dart";
      String i = '        ';
      String analyzeTests = testLibraries.length == 0? '' : '''
  addTask('analyze_test',
      createAnalyzerTask([
${testLibraries
  .where((tl) => tl.id.snake.startsWith('test_'))
  .map((tl) => '$i"test/${tl.name}.dart"')
  .toList()
  .join(',\n')}
      ]));
''';

      mergeWithFile('''
library hop_runner;

import 'dart:async';
import 'dart:io';
import 'package:hop/hop.dart';
import 'package:hop/hop_tasks.dart';
import '../test/runner.dart' as runner;

void main(List<String> args) {

  Directory.current = runner.rootPath;

  addTask('analyze_lib', createAnalyzerTask(_getLibs));
  addTask('docs', createDartDocTask(_getLibs));
${analyzeTests}
  addTask('test', createUnitTestTask(runner.testCore));

  runHop(args);
}

Future<List<String>> _getLibs() {
  return new Directory('lib').list()
      .where((FileSystemEntity fse) => fse is File)
      .map((File file) => file.path)
      .toList();
}
''',
          hopRunnerPath);

      String testRunnerPath = "${rootPath}/test/runner.dart";
      mergeWithFile('''
import 'utils.dart';
import 'package:unittest/unittest.dart';
${testLibraries
  .where((t) => t.id.snake.startsWith('test_'))
  .map((t) => "import '${t.id.snake}.dart' as ${t.id.snake};")
  .join('\n')}

get rootPath => packageRootPath;

void testCore(Configuration config) {
  unittestConfiguration = config;
  main();
}

main() {
${testLibraries
  .where((t) => t.id.snake.startsWith('test_'))
  .map((t) => "  ${t.id.snake}.main();")
  .join('\n')}
}

''',
          testRunnerPath);
    }

    if((generateHop && includeHop) || testLibraries.length > 0) {

      String testUtilsPath = "${rootPath}/test/utils.dart";
      mergeWithFile('''
import 'dart:io';
import 'package:path/path.dart' as path;

String get packageRootPath {
  var parts = path.split(path.absolute(Platform.script.path));
  int found = parts.lastIndexOf('${id.snake}');
  if(found >= 0) {
    return path.joinAll(parts.getRange(0, found+1));
  }
  throw new
    StateError("Current directory must be within package '${id.snake}'");
}

main() => print(packageRootPath);

''',
          testUtilsPath);
    }
  }

// end <class System>
  Id _id;
  bool _finalized = false;
}

/// A test generated in a standard format
class Test {


  // custom <class Test>
  // end <class Test>
}

/// An agrument to a script
class ScriptArg {

  ScriptArg(this._id);

  /// Id for this script argument
  Id get id => _id;
  /// Documentation for this script argument
  String doc;
  /// Reference to parent of this script argument
  dynamic get parent => _parent;
  /// Name of the the arg (emacs naming convention)
  String get name => _name;
  /// If true the argument is required
  bool isRequired = false;
  /// If true this argument is a boolean flag (i.e. no option is required)
  bool isFlag = false;
  /// If true the argument may be specified mutiple times
  bool isMultiple = false;
  /// Used to initialize the value in case not set
  dynamic defaultsTo;
  /// A list of allowed values to choose from
  List<String> allowed = [];
  /// If not null - holds the position of a positional (i.e. unnamed) argument
  int position;
  /// An abbreviation (single character)
  String abbr;

// custom <class ScriptArg>

  set parent(p) {
    _parent = p;
    _name = _id.emacs;
  }

// end <class ScriptArg>
  final Id _id;
  dynamic _parent;
  String _name;
}

/// A typical script - (i.e. like a bash/python/ruby script but in dart)
class Script {

  Script(this._id);

  /// Id for this script
  Id get id => _id;
  /// Documentation for this script
  String doc;
  /// Reference to parent of this script
  dynamic get parent => _parent;
  /// If true a custom section will be included for script
  bool includeCustom = true;
  /// List of imports to be included by this script
  List<String> imports = [];
  /// Arguments for this script
  List<ScriptArg> args = [];

// custom <class Script>

  set parent(p) {
    _parent = p;
    args.forEach((sa) => sa.parent = this);
    imports.add('dart:io');
    imports.add('package:args/args.dart');
    imports.add('package:logging/logging.dart');
    imports = cleanImports(
      imports.map((i) => importStatement(i)).toList());
  }

  void generate() {
    String scriptName = _id.snake;
    String scriptPath = "${_parent.rootPath}/bin/${scriptName}.dart";
    mergeWithFile('${_content}\n', scriptPath);
  }

  Iterable get requiredArgs =>
    args.where((arg) => arg.isRequired);

  get _content =>
    [
      _scriptTag,
      _docComment,
      _imports,
      _argParser,
      _usage,
      reduceVerticalWhitespace(_parseArgs),
      _loggerInit,
      _main,
    ]
    .where((line) => line != '')
    .join('\n');

  get _scriptTag => '#!/usr/bin/env dart';
  get _docComment => doc != null? '${docComment(doc)}\n' : '';
  get _imports => '${imports.join('\n')}\n';
  get _argParser => '''
//! The parser for this script
ArgParser _parser;
''';
  get _usage => '''
//! The comment and usage associated with this script
void _usage() {
  print(\'\'\'
$doc
\'\'\');
  print(_parser.getUsage());
}
''';
  get _parseArgs => '''
//! Method to parse command line options.
//! The result is a map containing all options, including positional options
Map _parseArgs() {
  ArgResults argResults;
  Map result = { };
  List remaining = [];

  _parser = new ArgParser();
  try {
    /// Fill in expectations of the parser
$_addFlags
$_addOptions
    /// Parse the command line options (excluding the script)
    var arguments = new Options().arguments;
    argResults = _parser.parse(arguments);
    argResults.options.forEach((opt) {
      result[opt] = argResults[opt];
    });
$_pullPositionals
$_positionals

    return { 'options': result, 'rest': remaining };

  } catch(e) {
    _usage();
    throw e;
  }
}
''';

  get _addFlags => args
    .where((arg) => arg.isFlag)
    .map((arg) => '''
    _parser.addFlag('${arg.name}',
      help: \'\'\'
${arg.doc}
\'\'\',
      defaultsTo: ${arg.defaultsTo}
    );''').join('\n') + '\n';

  get _addOptions => args
    .where((arg) => !arg.isFlag && arg.position == null)
    .map((arg) => '''
    _parser.addOption('${arg.name}',
      help: ${arg.doc == null? "''" : "\'\'\'\n${arg.doc}\n\'\'\'"},
      defaultsTo: ${arg.defaultsTo == null? null : '${arg.defaultsTo}'},
      allowMultiple: ${arg.isMultiple},
      abbr: ${arg.abbr == null? null : "'${arg.abbr}'"},
      allowed: ${arg.allowed.length>0? arg.allowed.map((a) => "'$a'").toList() : null}
    );''').join('\n') + '\n';

  get _pullPositionals => args
    .where((sa) => sa.position != null).length > 0 ? '''
    // Pull out positional args as they were named
    remaining = new List.from(argResults.rest);''' : '';

  get _positionals => args
    .where((sa) => sa.position != null)
    .map((sa) => '''
    if(${sa.position} >= remaining.length) {
      throw new
        ArgumentError('Positional argument ${sa.name} (position ${sa.position}) not available - not enough args');
    }
    result['${sa.name}'] = remaining.removeAt(${sa.position});
''').join('\n');

  get _loggerInit => "final _logger = new Logger('$id');\n";
  get _main => '''
main() {
  Logger.root.onRecord.listen((LogRecord r) =>
      print("\${r.loggerName} [\${r.level}]:\\t\${r.message}"));
  Logger.root.level = Level.INFO;
  Map argResults = _parseArgs();
  Map options = argResults['options'];
  List positionals = argResults['rest'];
${_requiredArgs}
${indentBlock(customBlock("$id main"))}
}

${customBlock("$id global")}''';

  get _requiredArgs => requiredArgs.length>0?
    '''
try {
$_processArgs
} on ArgumentError catch(e) {
  print(e);
  _usage();
}
''':'';

  get _processArgs => requiredArgs.map((arg) => '''
    if(options["${arg.name}"] == null)
      throw new ArgumentError("option: ${arg.name} is required");
''');

// end <class Script>
  final Id _id;
  dynamic _parent;
}

/// Defines a dart *web* application. For non-web console app, use Script
class App {

  App(this._id);

  /// Id for this app
  Id get id => _id;
  /// Documentation for this app
  String doc;
  /// Reference to parent of this app
  dynamic get parent => _parent;
  /// If true a custom section will be included for app
  bool includeCustom = true;
  /// Classes defined in this app
  List<Class> classes = [];
  /// List of libraries of this app
  List<Library> libraries = [];
  /// List of global variables for this library
  List<Variable> variables = [];
  /// If true this is a web ui app
  bool isWebUi = false;

// custom <class App>

  set parent(p) {
    libraries.forEach((l) => l.parent = this);
    variables.forEach((v) => v.parent = this);
    _parent = p;
  }

  void generate() {
    classes.forEach((c) => c.generate());
    libraries.forEach((lib) => lib.generate());
    String appPath = "${_parent.rootPath}/web/${_id.snake}.dart";
    String appHtmlPath = "${_parent.rootPath}/web/${_id.snake}.html";
    String appCssPath = "${_parent.rootPath}/web/${_id.snake}.css";
    String appBuildPath = "${_parent.rootPath}/build.dart";
    mergeWithFile(_content, appPath);
    htmlMergeWithFile('''<!DOCTYPE html>

<html>
  <head>
    <meta charset="utf-8">
    <title>${_id.title}</title>
    <link rel="stylesheet" href="${_id.snake}.css">
${htmlCustomBlock(id.toString() + ' head')}
  </head>
  <body>
${htmlCustomBlock(id.toString() + ' body')}
    <script type="application/dart" src="${_id.snake}.dart"></script>
    <script src="packages/browser/dart.js"></script>
  </body>
</html>
''', appHtmlPath);

    cssMergeWithFile('''
body {
  background-color: #F8F8F8;
  font-family: 'Open Sans', sans-serif;
  font-size: 14px;
  font-weight: normal;
  line-height: 1.2em;
  margin: 15px;
}

h1, p {
  color: #333;
}

${cssCustomBlock(id.toString())}
''', appCssPath);

    mergeWithFile('''
import 'dart:io';
import 'package:polymer/component_build.dart';

main() {
  build(Platform.arguments, ['web/${_id.snake}.html']);
}
''', appBuildPath);

  }

  get _content => '''
import 'package:mdv/mdv.dart' as mdv;

void main() {
  mdv.initialize();
}
''';

// end <class App>
  final Id _id;
  dynamic _parent;
}
// custom <part dart_meta>

get IA => Access.IA;
get RO => Access.RO;
get RW => Access.RW;
get WO => Access.WO;

Id id(String _id) => new Id(_id);
Enum enum_(String _id) => new Enum(id(_id));
System system(String _id) => new System(id(_id));
App app(String _id) => new App(id(_id));
Library library(String _id) => new Library(id(_id));
Variable variable(String _id) => new Variable(id(_id));
Part part(String _id) => new Part(id(_id));
Class class_(String _id) => new Class(id(_id));

/// Create new member from snake case id
Member member(String _id) => new Member(id(_id));
PubSpec pubspec(String _id) => new PubSpec(id(_id));
PubDependency pubdep(String name)=> new PubDependency(name);
Script script(String _id) => new Script(id(_id));
ScriptArg scriptArg(String _id) => new ScriptArg(id(_id));

final RegExp _jsonableTypeRe = new RegExp(r"\b(?:int|double|num|String|bool|DateTime)\b");
final RegExp _mapTypeRe = new RegExp(r"Map\b");
final RegExp _listTypeRe = new RegExp(r"List\b");
final RegExp _jsonMapTypeRe = new RegExp(r"Map<\s*.*\s*,\s*(.*?)\s*>");
final RegExp _jsonListTypeRe = new RegExp(r"List<\s*(.*?)\s*>");
final RegExp _generalMapKeyTypeRe = new RegExp(r"Map<\s*([^,]+),.+\s*>");

bool isJsonableType(String t) =>_jsonableTypeRe.firstMatch(t) != null;
bool isMapType(String t) => _mapTypeRe.firstMatch(t) != null;
bool isListType(String t) => _listTypeRe.firstMatch(t) != null;

String jsonMapValueType(String t) {
  Match m = _jsonMapTypeRe.firstMatch(t);
  if(m != null) {
    return m.group(1);
  }
  return 'dynamic';
}
String generalMapKeyType(String t) {
  Match m = _generalMapKeyTypeRe.firstMatch(t);
  if(m != null) {
    return m.group(1);
  }
  return 'String';
}
String jsonListValueType(String t) {
  Match m = _jsonListTypeRe.firstMatch(t);
  if(m != null) {
    return m.group(1);
  }
  return 'dynamic';
}

Library testLibrary(String s) => library(s)..isTest = true;
String importUri(String s) => Library.importUri(s);
String importStatement(String s) => Library.importStatement(s);

// end <part dart_meta>

RegExp _pubTypeRe = new RegExp(r"(git:|http:|[./.])");
