part of ebisu_dart_meta;

/// Access for member variable - ia - inaccessible, ro - read/only, rw read/write
class Access {
  static const IA = const Access._(0);
  static const RO = const Access._(1);
  static const RW = const Access._(2);

  static get values => [
    IA,
    RO,
    RW
  ];

  final int value;

  const Access._(this.value);

  String toString() {
    switch(this) {
      case IA: return "Ia";
      case RO: return "Ro";
      case RW: return "Rw";
    }
  }

  static Access fromString(String s) {
    switch(s) {
      case "Ia": return IA;
      case "Ro": return RO;
      case "Rw": return RW;
    }
  }

  int toJson() => value;
  static Access fromJson(int v) => values[v];


}

/// Dependency type of a PubDependency 
class PubDepType {
  static const PATH = const PubDepType._(0);
  static const GIT = const PubDepType._(1);
  static const HOSTED = const PubDepType._(2);

  static get values => [
    PATH,
    GIT,
    HOSTED
  ];

  final int value;

  const PubDepType._(this.value);

  String toString() {
    switch(this) {
      case PATH: return "Path";
      case GIT: return "Git";
      case HOSTED: return "Hosted";
    }
  }

  static PubDepType fromString(String s) {
    switch(s) {
      case "Path": return PATH;
      case "Git": return GIT;
      case "Hosted": return HOSTED;
    }
  }

  int toJson() => value;
  static PubDepType fromJson(int v) => values[v];


}

class Variable {

  Variable(this._id);

  /// Id for this variable
  Id get id => _id;
  /// Documentation for this variable
  String doc;
  /// Reference to parent of this variable
  dynamic get parent => _parent;
  /// True if variable is public.
  /// Code generation support will prefix private variables appropriately
  bool isPublic = true;
  /// Type for the variable
  String type;
  /// Data used to initialize the variable
  /// If init is a String and type is not specified, [type] is a String
  ///
  /// member('foo')..init = 'goo' => String foo = "goo";
  ///
  /// If init is a String and type is specified, then:
  ///
  /// member('foo')..type = 'int'..init = 3
  ///   String foo = 3;
  /// member('foo')..type = 'DateTime'..init = 'new DateTime(1929, 10, 29)' => 
  ///   DateTime foo = new DateTime(1929, 10, 29);
  ///
  /// If init is not specified, it will be inferred from init if possible:
  ///
  /// member('foo')..init = 'goo'
  ///   String foo = "goo";
  /// member('foo')..init = 3
  ///   String foo = 3;
  /// member('foo')..init = [1,2,3]
  ///   Map foo = [1,2,3];
  dynamic init;
  /// True if the variable is final
  bool isFinal = false;
  /// True if the variable is const
  bool isConst = false;
  /// True if the variable is static
  bool isStatic = false;
  /// Name of the enum class generated sans access prefix
  String get name => _name;
  /// Name of variable - varies depending on public/private
  String get varName => _varName;

// custom <class Variable>

  void set parent(p) {
    _name = id.camel;
    _varName = isPublic? _name : "_${_name}";
    if(type == null) {
      if((init != null) && (init is! String)) {
        type = '${init.runtimeType}';
        if(type == 'LinkedHashMap') type = 'Map';
      } else {
        type = 'String';
      }
    }

    _parent = p;
  }

  String define() {
    return meta.variable(this);
  }

// end <class Variable>
  final Id _id;
  dynamic _parent;
  String _name;
  String _varName;
}

/// Defines an enum - to be generated idiomatically as a class
/// See (http://stackoverflow.com/questions/13899928/does-dart-support-enumerations)
/// At some point when true enums are provided this may be revisited.
///
class Enum {

  Enum(this._id);

  /// Id for this enum
  Id get id => _id;
  /// Documentation for this enum
  String doc;
  /// True if enum is public.
  /// Code generation support will prefix private variables appropriately
  bool isPublic = true;
  /// Reference to parent of this enum
  dynamic get parent => _parent;
  /// List of id's naming the values
  List<Id> values = [];
  /// If true, generate toJson/fromJson on wrapper class
  bool jsonSupport = false;
  /// If true, generate randJson
  bool hasRandJson = false;
  /// Name of the enum class generated sans access prefix
  String get name => _name;
  /// Name of the enum class generated with access prefix
  String get enumName => _enumName;
  /// If true includes custom block for additional user supplied ctor code
  bool hasCustom = false;
  /// If true string value for each entry is snake case (default is shout)
  bool isSnakeString = false;

// custom <class Enum>

  set parent(p) {
    _name = _id.capCamel;
    _enumName = isPublic? _name : "_$_name";
    _parent = p;
  }

  String define() {
    return meta.enum_(this);
  }

  String valueAsString(Id value) => isSnakeString?
    value.snake : value.capCamel;

// end <class Enum>
  final Id _id;
  dynamic _parent;
  String _name;
  String _enumName;
}

/// A dependency of the system
class PubDependency {

  PubDependency(this.name);

  /// Name of dependency
  String name;
  /// Required version for this dependency
  String version = 'any';
  /// Path to package, infers package type for git (git:...), hosted (http:...), path
  String path;
  /// Git reference
  String gitRef;

// custom <class PubDependency>

  PubDepType get type {
    if(_type == null) {
      if(path != null) {
        var match = _pubTypeRe.firstMatch(path);

        switch(match.group(1)) {
          case 'git:': {
            _type = PubDepType.GIT;
          }
            break;
          case 'http:': {
            _type = PubDepType.HOSTED;
          }
            break;
          default: {
            _type = PubDepType.PATH;
          }
        }
      } else {
        _type = PubDepType.HOSTED;
      }
    }
      
    return _type;
  }

  bool get isHosted => (type == PubDepType.HOSTED);
  bool get isGit => (type == PubDepType.GIT);
  bool get isPath => (type == PubDepType.PATH);

  String get yamlEntry {
    String result;

    if(isHosted) {
      result = '''
  ${name}: ${version!=null? '"${version}"' : ''}
''';
    } else if(isPath || isGit) {
      result = '''
  $name:
''';
    } else {
      result = '''
  $name: '$version'
''';
    }

    if(path != null) {
      if(isHosted) {
        result += '''
      hosted: 
        name: $name
        url: $path
      version: '$version' 
''';
      } else if(isGit) {
        if(gitRef != null) {
          result += '''
      git: 
        url: ${path}
        ref: ${gitRef}
''';
        } else {
          result += '''
      git: $path
''';
        }
      } else {
        result += '''
      path: $path
''';
      }
    }
    return result;
  }

// end <class PubDependency>
  /// Type for the pub dependency
  PubDepType _type;
}

/// Information for the pubspec of the system
class PubSpec {

  PubSpec(this._id);

  /// Id for this pub spec
  Id get id => _id;
  /// Documentation for this pub spec
  String doc;
  /// Reference to parent of this pub spec
  dynamic get parent => _parent;
  /// Version for this package
  String version = '0.0.1';
  /// Name of the project described in spec.
  /// If not set, id of system is used.
  String name;
  /// Author of the pub package
  String author;
  /// Homepage of the pub package
  String homepage;
  List<PubDependency> dependencies = [];
  List<PubDependency> devDependencies = [];

// custom <class PubSpec>

  set parent(p) {
    if(author == null && Platform.environment['EBISU_AUTHOR'] != null) {
      author = Platform.environment['EBISU_AUTHOR'];
    }

    if(homepage == null && Platform.environment['EBISU_HOMEPAGE'] != null) {
      homepage = Platform.environment['EBISU_HOMEPAGE'];
    }

    if(name == null)
      name = _id.snake;
    _parent = p;
  }

  void addDependency(PubDependency dep) {
    if(depNotFound(dep.name)) {
      dependencies.add(dep);
    } else {
      throw new ArgumentError("${dep.name} is already a dependency of ${_id}");
    }
  }

  void addDevDependency(PubDependency dep) {
    if(depNotFound(dep.name)) {
      devDependencies.add(dep);
    } else {
      throw new ArgumentError("${dep.name} is already a dev dependency of ${_id}");
    }
  }

  void addDependencies(List<PubDependency> deps) =>
    deps.forEach((dep) => addDependency(dep));

  bool depNotFound(String name) =>
    !devDependencies.any((d) => d.name == name) &&
    !dependencies.any((d) => d.name == name);
    

// end <class PubSpec>
  Id _id;
  dynamic _parent;
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
        if(library.id.snake.startsWith('test_')) {
          library.includeMain = true;
          library.imports.add('package:unittest/unittest.dart');
        }
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
  void generate() {

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
      scriptMergeWithFile(meta.pubspec(pubSpec), pubSpecPath);
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

    if(includeHop) {
      String hopRunnerPath = "${rootPath}/tool/hop_runner.dart";
      String i = '        ';
      String analyzeTests = testLibraries.length == 0? '' : '''
  addTask('analyze_test', 
      createAnalyzerTask([
${testLibraries
  .where((tl) => tl.id.snake.startsWith('test_'))
  .map((tl) => '$i"test/${tl.name}.dart"')
  .toList()
  .join('\n')}
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
    }

    if(includeHop || testLibraries.length > 0) {

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
    mergeWithFile(meta.script(this), scriptPath);
  }

  Iterable get requiredArgs =>
    args.where((arg) => arg.isRequired);

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
    mergeWithFile(meta.app(this), appPath);
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

// end <class App>
  final Id _id;
  dynamic _parent;
}

/// Defines a dart library - a collection of parts
class Library {

  Library(this._id);

  /// Id for this library
  Id get id => _id;
  /// Documentation for this library
  String doc;
  /// Reference to parent of this library
  dynamic get parent => _parent;
  /// If true a custom section will be included for library
  bool includeCustom = true;
  /// List of imports to be included by this library
  List<String> imports = [];
  /// List of parts in this library
  List<Part> parts = [];
  /// List of global variables for this library
  List<Variable> variables = [];
  /// Classes defined in this library
  List<Class> classes = [];
  /// Enums defined in this library
  List<Enum> enums = [];
  /// Name of the library - for use in naming the library file, the 'library' and 'part of' statements
  String get name => _name;
  /// If true includes logging support and a _logger
  bool includeLogger = false;
  /// If true this library is a test library to appear in test folder
  bool isTest = false;
  /// If true a main is included in the library file
  bool includeMain = false;
  /// Set desired if generating just a lib and not a package
  String path;
  /// If set the main function
  String libMain;

// custom <class Library>

  List<Class> get allClasses {
    List<Class> result = new List.from(classes);
    parts.forEach((part) => result.addAll(part.classes));
    return result;
  }

  set parent(p) {
    _name = _id.snake;
    parts.forEach((part) => part.parent = this);
    variables.forEach((v) => v.parent = this);
    enums.forEach((e) => e.parent = this);
    classes.forEach((c) => c.parent = this);
    if(allClasses.any((c) => c.jsonSupport)) {
      imports.add('"package:ebisu/ebisu_utils.dart" as ebisu_utils');
      imports.add('"dart:convert" as convert');
    }
    if(includeLogger) {
      imports.add("package:logging/logging.dart");
    }
    imports = cleanImports(
      imports.map((i) => importStatement(i)).toList());
    _parent = p;
  }

  void generate() {

    if(_parent == null) {
      parent = system('ignored');
    }

    String libStubPath = 
      (path != null)? "${path}/${id.snake}.dart" :
      (isTest? 
          "${_parent.rootPath}/test/${id.snake}.dart" :
          "${_parent.rootPath}/lib/${id.snake}.dart");

    mergeWithFile(meta.library(this), libStubPath);
    parts.forEach((part) => part.generate());
  }

  static final _standardImports = new Set.from([
    'async', 'chrome', 'collection', 'core', 'crypto',
    'html', 'indexed_db', 'io', 'isolate', 'json', 'math',
    'mirrors', 'scalarlist', 'svg', 'uri', 'utf', 'web_audio',
    'web_sql', 'convert'
  ]);

  static final _standardPackageImports = new Set.from([
    'args', 'fixnum', 'intl', 'logging', 'matcher', 'meta',
    'mock', 'scheduled_test', 'serialization',
    'unittest'
  ]);

  static final RegExp _hasQuotes = new RegExp(r'''[\'"]''');

  static String importUri(String uri) {
    if(null == _hasQuotes.firstMatch(uri)) {
       return '"${uri}"';
    } else {
       return '${uri}';
    }
  }

  static String importStatement(String i) {
    if(_standardImports.contains(i)) {
      return 'import "dart:$i";';
    } else if(_standardPackageImports.contains(i)) {
      return 'import "package:$i";';
    } else {
      return 'import ${importUri(i)};';
    }
  }

  String get rootPath => _parent.rootPath;

// end <class Library>
  final Id _id;
  dynamic _parent;
  String _name;
}

/// Defines a dart part - as in 'part of' source file
class Part {

  Part(this._id);

  /// Id for this part
  Id get id => _id;
  /// Documentation for this part
  String doc;
  /// Reference to parent of this part
  dynamic get parent => _parent;
  /// If true a custom section will be included for app
  bool includeCustom = true;
  /// Classes defined in this part of the library
  List<Class> classes = [];
  /// Enums defined in this part of the library
  List<Enum> enums = [];
  /// Name of the part - for use in naming the part file
  String get name => _name;
  /// Path to the generated part dart file
  String get filePath => _filePath;
  /// List of global variables in this part
  List<Variable> variables = [];

// custom <class Part>

  set parent(p) {
    _name = _id.snake;
    variables.forEach((v) => v.parent = this);
    classes.forEach((dc) => dc.parent = this);
    enums.forEach((e) => e.parent = this);
    _parent = p;
  }

  void generate() {
    _filePath = 
      _parent.isTest?
      "${_parent.rootPath}/test/src/${_parent.name}/${_name}.dart" :
      "${_parent.rootPath}/lib/src/${_parent.name}/${_name}.dart";
    mergeWithFile(meta.part(this), _filePath);
  }


// end <class Part>
  final Id _id;
  dynamic _parent;
  String _name;
  String _filePath;
}

/// Metadata associated with a Dart class
class Class {

  Class(this._id);

  /// Id for this Dart class
  Id get id => _id;
  /// Documentation for this Dart class
  String doc;
  /// Reference to parent of this Dart class
  dynamic get parent => _parent;
  /// True if Dart class is public.
  /// Code generation support will prefix private variables appropriately
  bool isPublic = true;
  /// List of mixins
  List<String> mixins = [];
  /// Any extends (NOTE extend not extends) declaration for the class - conflicts with mixin
  String extend;
  /// Any implements (NOTE implement not implements)
  List<String> implement = [];
  /// If true a custom section will be included for Dart class
  bool includeCustom = true;
  /// Default access for members
  Access defaultMemberAccess = Access.RW;
  /// List of members of this class
  List<Member> members = [];
  /// List of ctors requiring custom block
  List<String> ctorCustoms = [];
  /// List of ctors that should be const
  List<String> ctorConst = [];
  /// List of ctors of this class
  Map<String,Ctor> get ctors => _ctors;
  /// If true, class is abstract
  bool isAbstract = false;
  /// If true, generate toJson/fromJson on all members that are not jsonTransient
  bool jsonSupport = false;
  /// If true, generate randJson function
  bool hasRandJson = false;
  /// If true creates library functions to construct forwarding to ctors
  bool ctorSansNew = false;
  /// Name of the class - sans any access prefix (i.e. no '_')
  String get name => _name;
  /// Name of the class, including access prefix
  String get className => _className;

// custom <class Class>

  List<Member> get publicMembers {
    return members.where((member) => member.isPublic).toList();
  }

  List<Member> get privateMembers {
    return members.where((member) => !member.isPublic).toList();
  }

  String get jsonCtor {
    if(_ctors.containsKey('_json')) {
      return "${_className}._json";
    } else {
      return _className;
    }
  }

  set parent(p) {
    _name = id.capCamel;
    _className = isPublic? _name : "_$_name";

    // Iterate on all members and create the appropriate ctors
    members.forEach((m) {

      if(m.access == null && defaultMemberAccess != null) {
        m.access = defaultMemberAccess;
      }

      m.parent = this;

      m.ctors.forEach((ctorName) {
        Ctor ctor = _ctors.putIfAbsent(ctorName, () => new Ctor())
          ..name = ctorName
          ..hasCustom = ctorCustoms.contains(ctorName)
          ..isConst = ctorConst.contains(ctorName)
          ..className = _className
          ..members.add(m);
      });
      m.ctorsOpt.forEach((ctorName) {
        Ctor ctor = _ctors.putIfAbsent(ctorName, () => new Ctor())
          ..name = ctorName
          ..hasCustom = ctorCustoms.contains(ctorName)
          ..isConst = ctorConst.contains(ctorName)
          ..className = _className
          ..optMembers.add(m);
      });
      m.ctorsNamed.forEach((ctorName) {
        Ctor ctor = _ctors.putIfAbsent(ctorName, () => new Ctor())
          ..name = ctorName
          ..hasCustom = ctorCustoms.contains(ctorName)
          ..isConst = ctorConst.contains(ctorName)
          ..className = _className
          ..namedMembers.add(m);
      });
    });

    // To deserialize a default ctor is needed
    if(jsonSupport && _ctors.length > 0) {
      _ctors.putIfAbsent('_json', () => new Ctor())
        ..name = '_json'
        ..className = _name;
    }

    _parent = p;
  }

  List get orderedCtors {
    var keys = _ctors.keys.toList();
    bool hasDefault = keys.remove('');
    var privates = keys.where((k) => k[0]=='_').toList();
    var publics = keys.where((k) => k[0]!='_').toList();
    privates.sort();
    publics.sort();
    var result = new List.from(publics)..addAll(privates);
    if(hasDefault) {
      result.insert(0, '');
    }
    return result;
  }

  String get implementsClause {
    if(implement.length>0) {
      return ' implements ${implement.join(',\n    ')} ';
    } else {
      return ' ';
    }
  }

  static String _mapCheck(String type, String value) => '''
($value is Map)?
  ${type}.fromJsonMap($value) :
  ${type}.fromJson($value)''';

  static String _fromJsonData(String type, String source) {
    if(isClassJsonable(type)) {
      return _mapCheck(type, source);
    } else if(type == 'DateTime') {
      return 'DateTime.parse($source)';
    }
    return source;
  }

  static String _stringCheck(String type, String source) => '''
($source is String)?
  $source :
  $type.fromString($source)''';

  String _fromJsonMapMember(Member member, [ String source = 'jsonMap' ]) {
    List results = [];
    var lhs = '${member.varName}';
    var key = '"${member.name}"';
    var value = '$source[$key]';
    String rhs;
    if(isClassJsonable(member.type)) {
      results.add('$lhs = ${_mapCheck(member.type, value)};');
    } else {
      if(isMapType(member.type)) {
        results.add('''

// ${member.name} is ${member.type}
$lhs = {};
$value.forEach((k,v) {
  $lhs[
  ${indentBlock(_stringCheck(generalMapKeyType(member.type), 'k'))}
  ] = ${_fromJsonData(jsonMapValueType(member.type), 'v')};
});''');
      } else if(isListType(member.type)) {
        results.add('''

// ${member.name} is ${member.type}
$lhs = [];
$value.forEach((v) {
  $lhs.add(${_fromJsonData(jsonListValueType(member.type), 'v')});
});''');
      } else {
        results.add('$lhs = $value;');
      }
    }
    return results.join('\n');
  }

  String fromJsonMapImpl() {
    List result = [ 'void _fromJsonMapImpl(Map jsonMap) {' ];

    result
      .add(
        indentBlock(
          members
          .where((m) => !m.jsonTransient)
          .map((m) => _fromJsonMapMember(m))
          .join('\n'))
           );
    result.add('}');
    return result.join('\n');
  }

  String define() {
    if(parent == null) parent = library('stub');
    return meta.class_(this);
  }

  dynamic noSuchMethod(Invocation msg) {
    throw new ArgumentError("Class does not support ${msg.memberName}");
  }

// end <class Class>
  final Id _id;
  dynamic _parent;
  Map<String,Ctor> _ctors = {};
  String _name;
  String _className;
}

/// Metadata associated with a constructor
class Ctor {
  /// Name of the class of this ctor.
  String className;
  /// Name of the ctor. If 'default' generated as name of class, otherwise as CLASS.NAME()
  String name;
  /// List of members initialized in this ctor
  List<Member> members = [];
  /// List of optional members initialized in this ctor (i.e. those in [])
  List<Member> optMembers = [];
  /// List of optional members initialized in this ctor (i.e. those in {})
  List<Member> namedMembers = [];
  /// If true includes custom block for additional user supplied ctor code
  bool hasCustom = false;
  /// True if the variable is const
  bool isConst = false;

// custom <class Ctor>

  Ctor(){}

  String get qualifiedName => (name == 'default' || name == '')? 
    className : '${className}.${name}';

  String get ctorSansNew {
    var classId = idFromString(className);
    var id = (name == 'default' || name == '')? classId : 
    new Id('${classId.snake}_${idFromString(name)}');

    List<String> parms = [];
    List<String> args = [];
    if(members.length > 0) {
      List<String> required = [];
      members.forEach((m) => required.add('${m.type} ${m.varName}'));
      parms.add("${required.join(',\n')}");
      args.add(members.map((m) => '  ${m.varName}').join(',\n'));
    }
    if(optMembers.length > 0) {
      List<String> optional = [];
      optMembers.forEach((m) => optional.add('    ${m.type} ${m.varName}'));
      parms.add("  [\n${optional.join(',\n')}\n  ]");
      args.add(optMembers.map((m) => '  ${m.varName}').join(',\n'));
    }
    if(namedMembers.length > 0) {
      List<String> named = [];
      namedMembers.forEach((m) => named.add('    ${m.type} ${m.varName}'));
      parms.add("  {\n${named.join(',\n')}\n  }");
      args.add(namedMembers.map((m) => '  ${m.varName}:${m.varName}').join(',\n'));
    }
    String parmText = parms.join(',\n');
    String argText = args.join(',\n');

    return '''

/// Create a ${className} sans new, for more declarative construction
${className} ${id.camel}(${leftTrim(chomp(indentBlock(parmText, '  ')))}) {
  return new ${qualifiedName}(${leftTrim(chomp(indentBlock(argText, '    ')))});
}
''';
  }

  String get ctorText {
    List<String> result = [];
    if(members.length > 0) {
      List<String> required = [];
      members.forEach((m) => required.add('this.${m.varName}'));
      result.addAll(prepJoin(required));
    }
    if(optMembers.length > 0) {
      if(result.length > 0) result[result.length-1] += ',';
      result.add('[');
      List<String> optional = [];
      optMembers.forEach((m) => 
          optional.add('this.${m.varName}' +
              ((m.ctorInit == null)? '' : ' = ${m.ctorInit}')));
      result.addAll(prepJoin(optional));
      result.add(']');
    }
    if(namedMembers.length > 0) {
      if(result.length > 0) result[result.length-1] += ',';
      result.add('{');
      List<String> named = [];
      namedMembers.forEach((m) => 
        named.add('this.${m.varName}' +
            ((m.ctorInit == null)? '':' : ${m.ctorInit}')));
      result.addAll(prepJoin(named));
      result.add('}');      
    }

    String cb = hasCustom? 
    indentBlock(rightTrim(customBlock('${qualifiedName}'))): '';
    String constTag = isConst? 'const ' : '';
    String body = (isConst || !hasCustom)? ';' : ''' {
${chomp(cb, true)}
}''';

    List decl = [];
    var method = '${constTag}${qualifiedName}(';
    if(result.length > 0) {
      decl
        ..add('$method${result.removeAt(0)}')
        ..addAll(result);
    } else {
      decl.add(method);
    }

    return '''
${formatFill(decl)})${body}
''';
  }

// end <class Ctor>
}

/// Metadata associated with a member of a Dart class
class Member {

  Member(this._id);

  /// Id for this class member
  Id get id => _id;
  /// Documentation for this class member
  String doc;
  /// Reference to parent of this class member
  dynamic get parent => _parent;
  /// Type of the member
  String type = 'String';
  /// Access level supported for this member
  Access access;
  /// If provided the member will be initialized with value.
  /// The type of the member can be inferred from the type
  /// of this value.  Member type is defaulted to String. If
  /// the type of classInit is a String and type of the
  /// member is String, the text will be quoted if it is not
  /// already. If the type of classInit is other than string
  /// and the type of member is String (which is default)
  /// the type of member will be set to
  /// classInit.runtimeType.
  dynamic classInit;
  /// If provided the member will be initialized to this
  /// text in generated ctor initializers
  String ctorInit;
  /// List of ctor names to include this member in
  List<String> ctors = [];
  /// List of ctor names to include this member in as optional parameter
  List<String> ctorsOpt = [];
  /// List of ctor names to include this member in as named optional parameter
  List<String> ctorsNamed = [];
  /// True if the member is final
  bool isFinal = false;
  /// True if the member is const
  bool isConst = false;
  /// True if the member is static
  bool isStatic = false;
  /// True if the member should not be serialized if the parent class has jsonSupport
  bool jsonTransient = false;
  /// Name of variable for the member, excluding access prefix (i.e. no '_')
  String get name => _name;
  /// Name of variable for the member - varies depending on public/private
  String get varName => _varName;

// custom <class Member>

  bool get isPublic => access == Access.RW;

  set parent(p) {
    _name = id.camel;
    if(type == 'String' && 
        (classInit != null) &&
        (classInit is! String)) {
      type = '${classInit.runtimeType}';
      if(type.contains('LinkedHashMap')) type = 'Map';
    }
    if(access == null) access = Access.RW;
    _varName = isPublic? _name : "_$_name";
    _parent = p;
  }

  bool get hasGetter => !isPublic && access == RO;
  bool get hasSetter => !isPublic && access == RW;

  bool get hasPublicCode => isPublic || hasGetter || hasSetter;
  bool get hasPrivateCode => !isPublic;

  String get finalDecl => isFinal? 'final ' : '';

  String get decl =>
    (classInit == null)? 
    "${finalDecl}${type} ${varName};" :
    ((type == 'String')?
        "${finalDecl}${type} ${varName} = ${smartQuote(classInit)};" :
        "${finalDecl}${type} ${varName} = ${classInit};");

  String get publicCode {
    var result = [];
    if(doc != null) result.add('${docComment(rightTrim(doc))}');
    if(hasGetter) {
      result.add('$type get $name => $varName;');
    }
    if(isPublic) result.add(decl);
    return result.join('\n');
  }

  String get privateCode {
    var result = [];
    if(doc != null && !hasPublicCode) result.add('${docComment(rightTrim(doc))}');
    if(!isPublic) result.add(decl);
    return result.join('\n');
  }

// end <class Member>
  final Id _id;
  dynamic _parent;
  String _name;
  String _varName;
}
// custom <part dart_meta>

get IA => Access.IA;
get RO => Access.RO;
get RW => Access.RW;

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

String importUri(String s) => Library.importUri(s);
String importStatement(String s) => Library.importStatement(s);

// end <part dart_meta>

RegExp _pubTypeRe = new RegExp(r"(git:|http:|[./.])");

