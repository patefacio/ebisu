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
      case IA: return "IA";
      case RO: return "RO";
      case RW: return "RW";
    }
  }

  static Access fromString(String s) {
    switch(s) {
      case "IA": return IA;
      case "RO": return RO;
      case "RW": return RW;
    }
  }


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
      case PATH: return "PATH";
      case GIT: return "GIT";
      case HOSTED: return "HOSTED";
    }
  }

  static PubDepType fromString(String s) {
    switch(s) {
      case "PATH": return PATH;
      case "GIT": return GIT;
      case "HOSTED": return HOSTED;
    }
  }


}

class Variable {

  Variable(this._id);

  final Id _id;
  /// Id for this variable
  Id get id => _id;
  /// Documentation for this variable
  String doc;
  dynamic _parent;
  /// Reference to parent of this variable
  dynamic get parent => _parent;
  /// True if variable is public.
  /// Code generation support will prefix private variables appropriately
  bool isPublic = true;
  /// Type for the variable
  String type = "dynamic";
  /// Text used to initialize the variable
  /// (e.g. 'DateTime(1929, 10, 29)' for <DateTime crashDate = DateTime(1929, 10, 29)>
  String init;
  /// True if the variable is final
  bool isFinal = false;
  /// True if the variable is const
  bool isConst = false;
  /// True if the variable is static
  bool isStatic = false;
  String _name;
  /// Name of the enum class generated sans access prefix
  String get name => _name;
  String _varName;
  /// Name of variable - varies depending on public/private
  String get varName => _varName;

// custom <class Variable>

  void set parent(p) {
    _name = id.camel;
    _varName = isPublic? _name : "_${_name}";
    _parent = p;
  }

  String define() {
    return META.variable(this);
  }

// end <class Variable>

  Map toJson() {
    return {
    "id": EBISU_UTILS.toJson(_id),
    "doc": EBISU_UTILS.toJson(doc),
    "isPublic": EBISU_UTILS.toJson(isPublic),
    "type": EBISU_UTILS.toJson(type),
    "init": EBISU_UTILS.toJson(init),
    "isFinal": EBISU_UTILS.toJson(isFinal),
    "isConst": EBISU_UTILS.toJson(isConst),
    "isStatic": EBISU_UTILS.toJson(isStatic),
    "name": EBISU_UTILS.toJson(_name),
    "varName": EBISU_UTILS.toJson(_varName),
    };
  }

  static Map randJson() {
    return {
    "id": EBISU_UTILS.randJson(_randomJsonGenerator, Id.randJson),
    "doc": EBISU_UTILS.randJson(_randomJsonGenerator, String),
    "isPublic": EBISU_UTILS.randJson(_randomJsonGenerator, bool),
    "type": EBISU_UTILS.randJson(_randomJsonGenerator, String),
    "init": EBISU_UTILS.randJson(_randomJsonGenerator, String),
    "isFinal": EBISU_UTILS.randJson(_randomJsonGenerator, bool),
    "isConst": EBISU_UTILS.randJson(_randomJsonGenerator, bool),
    "isStatic": EBISU_UTILS.randJson(_randomJsonGenerator, bool),
    "name": EBISU_UTILS.randJson(_randomJsonGenerator, String),
    "varName": EBISU_UTILS.randJson(_randomJsonGenerator, String),
    };
  }

}

/// Defines an enum - to be generated idiomatically as a class
/// See (http://stackoverflow.com/questions/13899928/does-dart-support-enumerations)
/// At some point when true enums are provided this may be revisited.
///
class Enum {

  Enum(this._id);

  final Id _id;
  /// Id for this enum
  Id get id => _id;
  /// Documentation for this enum
  String doc;
  /// True if enum is public.
  /// Code generation support will prefix private variables appropriately
  bool isPublic = true;
  dynamic _parent;
  /// Reference to parent of this enum
  dynamic get parent => _parent;
  /// List of id's naming the values
  List<Id> values = [];
  /// If true, generate toJson/fromJson on wrapper class
  bool jsonSupport = false;
  String _name;
  /// Name of the enum class generated sans access prefix
  String get name => _name;
  String _enumName;
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
    return META.enum_(this);
  }

  String valueAsString(Id value) => isSnakeString?
    value.snake : value.shout;

// end <class Enum>

  Map toJson() {
    return {
    "id": EBISU_UTILS.toJson(_id),
    "doc": EBISU_UTILS.toJson(doc),
    "isPublic": EBISU_UTILS.toJson(isPublic),
    "values": EBISU_UTILS.toJson(values),
    "jsonSupport": EBISU_UTILS.toJson(jsonSupport),
    "name": EBISU_UTILS.toJson(_name),
    "enumName": EBISU_UTILS.toJson(_enumName),
    "hasCustom": EBISU_UTILS.toJson(hasCustom),
    "isSnakeString": EBISU_UTILS.toJson(isSnakeString),
    };
  }

  static Map randJson() {
    return {
    "id": EBISU_UTILS.randJson(_randomJsonGenerator, Id.randJson),
    "doc": EBISU_UTILS.randJson(_randomJsonGenerator, String),
    "isPublic": EBISU_UTILS.randJson(_randomJsonGenerator, bool),
    "values":
       EBISU_UTILS.randJson(_randomJsonGenerator, [],
        () => Id.randJson()),
    "jsonSupport": EBISU_UTILS.randJson(_randomJsonGenerator, bool),
    "name": EBISU_UTILS.randJson(_randomJsonGenerator, String),
    "enumName": EBISU_UTILS.randJson(_randomJsonGenerator, String),
    "hasCustom": EBISU_UTILS.randJson(_randomJsonGenerator, bool),
    "isSnakeString": EBISU_UTILS.randJson(_randomJsonGenerator, bool),
    };
  }

}

/// A dependency of the system
class PubDependency {
  /// Name of dependency
  String name;
  /// Required version for this dependency
  String version = "any";
  /// Path to package, infers package type for git (git:...), hosted (http:...), path
  String path;
  /// Git reference
  String gitRef;
  /// Type for the pub dependency
  PubDepType _type;
  final RegExp pubTypeRe = new RegExp(r"(git:|http:|[./.])");

// custom <class PubDependency>

  PubDepType get type {
    if(_type == null) {
      if(path != null) {
        var match = pubTypeRe.firstMatch(path);

        switch(match.group(1)) {
          case 'git:': {
            _type = PubDepType.GIT;
            break;
          }
          case 'http:': {
            _type = PubDepType.HOSTED;
            break;
          }
          default: {
            _type = PubDepType.PATH;
            break;
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
      git: $path
''';
      }
    }
    return result;
  }

  PubDependency(String _name) : name = _name { }

// end <class PubDependency>

  Map toJson() {
    return {
    "name": EBISU_UTILS.toJson(name),
    "version": EBISU_UTILS.toJson(version),
    "path": EBISU_UTILS.toJson(path),
    "gitRef": EBISU_UTILS.toJson(gitRef),
    "type": EBISU_UTILS.toJson(_type),
    "pubTypeRe": EBISU_UTILS.toJson(pubTypeRe),
    };
  }

  static Map randJson() {
    return {
    "name": EBISU_UTILS.randJson(_randomJsonGenerator, String),
    "version": EBISU_UTILS.randJson(_randomJsonGenerator, String),
    "path": EBISU_UTILS.randJson(_randomJsonGenerator, String),
    "gitRef": EBISU_UTILS.randJson(_randomJsonGenerator, String),
    "type": EBISU_UTILS.randJson(_randomJsonGenerator, PubDepType.randJson),
    "pubTypeRe": EBISU_UTILS.randJson(_randomJsonGenerator, RegExp.randJson),
    };
  }

}

/// Information for the pubspec of the system
class PubSpec {

  PubSpec(this._id);

  final Id _id;
  /// Id for this pub spec
  Id get id => _id;
  /// Documentation for this pub spec
  String doc;
  dynamic _parent;
  /// Reference to parent of this pub spec
  dynamic get parent => _parent;
  /// Version for this package
  String version = "0.0.1";
  /// Name of the project described in spec - if not set, id of system is used to generate
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

  Map toJson() {
    return {
    "id": EBISU_UTILS.toJson(_id),
    "doc": EBISU_UTILS.toJson(doc),
    "version": EBISU_UTILS.toJson(version),
    "name": EBISU_UTILS.toJson(name),
    "author": EBISU_UTILS.toJson(author),
    "homepage": EBISU_UTILS.toJson(homepage),
    "dependencies": EBISU_UTILS.toJson(dependencies),
    "devDependencies": EBISU_UTILS.toJson(devDependencies),
    };
  }

  static Map randJson() {
    return {
    "id": EBISU_UTILS.randJson(_randomJsonGenerator, Id.randJson),
    "doc": EBISU_UTILS.randJson(_randomJsonGenerator, String),
    "version": EBISU_UTILS.randJson(_randomJsonGenerator, String),
    "name": EBISU_UTILS.randJson(_randomJsonGenerator, String),
    "author": EBISU_UTILS.randJson(_randomJsonGenerator, String),
    "homepage": EBISU_UTILS.randJson(_randomJsonGenerator, String),
    "dependencies":
       EBISU_UTILS.randJson(_randomJsonGenerator, [],
        () => PubDependency.randJson()),
    "devDependencies":
       EBISU_UTILS.randJson(_randomJsonGenerator, [],
        () => PubDependency.randJson()),
    };
  }

}

/// Defines a dart system (collection of libraries and apps)
class System {
  Id _id;
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
  bool _finalized = false;
  /// Set to true on finalize
  bool get finalized => _finalized;
  /// If true generate a pubspec.xml file
  bool generatePubSpec = true;
  /// If found in licenseMap, value is used, else license is used
  String license;
  /// If true standard outline for readme provided
  bool includeReadme = false;
  /// If true generates tool folder with hop_runner
  bool includeHop = false;

// custom <class System>

  /// Create system from the id
  System(Id id) : _id = id, pubSpec = new PubSpec(id) {}

  /// Finalize must be called before generate
  void finalize() {
    if(!_finalized) {

      testLibraries.forEach((library) {
        if(!library.id.snake.startsWith('test_'))
          _logger.warning(
            r"Test library ${library.id.snake} should be named /test_\w+/");
        library.isTest = true;
        library.includeMain = true;
        library.imports.add('package:unittest/unittest.dart');
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

  bool isClassJsonable(String className) =>
      !_nonJsonableTypes.contains(className) &&
      !className.startsWith('Map<') && 
      !className.startsWith('List<');

  /// Generate the code
  void generate() {
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
        pubSpec.addDevDependency(
          new PubDependency('hop')..version = '0.24.2');
      }
    }

    allLibraries.forEach((lib) {
      lib.generate();
      if(lib.includeLogger) {
        if(pubSpec.depNotFound('logging')) {
          pubSpec.addDependency(
            new PubDependency('logging')
            ..version = ">=0.6.21+3 <0.6.22");
        }
      }
    });

    if(pubSpec != null && generatePubSpec) {
      String pubSpecPath = "${rootPath}/pubspec.yaml";
      scriptMergeWithFile(META.pubspec(pubSpec), pubSpecPath);
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

    if(includeReadme) {
      String readmePath = "${rootPath}/README.md";  
      panDocMergeWithFile('''
# ${id.title}

${panDocCustomBlock('introduction')}

# Purpose

${panDocCustomBlock('purpose')}

${panDocCustomBlock('body')}

# Examples

${panDocCustomBlock('examples')}

# TODO

${panDocCustomBlock('todos')}

''', 
          readmePath);      
    }

    if(includeHop) {
      String hopRunnerPath = "${rootPath}/tool/hop_runner.dart";
      String i = '        ';
      String analyzeTests = testLibraries.length == 0? '' : '''
  addTask('analyze_test', 
      createAnalyzerTask([
${testLibraries.map((tl) => '$i"test/${tl.name}.dart"').toList().join('\n')}
      ]));
''';

      mergeWithFile('''
library hop_runner;

import 'dart:async';
import 'dart:io';
import 'package:hop/hop.dart';
import "package:path/path.dart" as PATH;
import 'package:hop/hop_tasks.dart';
import '../test/utils.dart';
import '../test/runner.dart' as runner;

void main() {

  Directory.current = packageRootPath;

  addTask('analyze_lib', createAnalyzerTask(_getLibs));
  addTask('docs', createDartDocTask(_getLibs));
${analyzeTests}
  addTask('test', createUnitTestTask(runner.testCore));

  runHop();
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
  var parts = path.split(path.absolute(new Options().script));
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
import 'package:unittest/unittest.dart';
import 'package:unittest/vm_config.dart';
${testLibraries.map((t) => "import '${t.id.snake}.dart' as ${t.id.snake};").join('\n')}

void testCore(Configuration config) {
  unittestConfiguration = config;
  main();
}

main() {
${testLibraries.map((t) => "  ${t.id.snake}.main();").join('\n')}
}

''',
          testRunnerPath);

    }
  }

// end <class System>

  Map toJson() {
    return {
    "id": EBISU_UTILS.toJson(_id),
    "doc": EBISU_UTILS.toJson(doc),
    "rootPath": EBISU_UTILS.toJson(rootPath),
    "scripts": EBISU_UTILS.toJson(scripts),
    "app": EBISU_UTILS.toJson(app),
    "testLibraries": EBISU_UTILS.toJson(testLibraries),
    "libraries": EBISU_UTILS.toJson(libraries),
    "allLibraries": EBISU_UTILS.toJson(allLibraries),
    "pubSpec": EBISU_UTILS.toJson(pubSpec),
    "jsonableClasses": EBISU_UTILS.toJson(jsonableClasses),
    "finalized": EBISU_UTILS.toJson(_finalized),
    "generatePubSpec": EBISU_UTILS.toJson(generatePubSpec),
    "license": EBISU_UTILS.toJson(license),
    "includeReadme": EBISU_UTILS.toJson(includeReadme),
    "includeHop": EBISU_UTILS.toJson(includeHop),
    };
  }

  static Map randJson() {
    return {
    "id": EBISU_UTILS.randJson(_randomJsonGenerator, Id.randJson),
    "doc": EBISU_UTILS.randJson(_randomJsonGenerator, String),
    "rootPath": EBISU_UTILS.randJson(_randomJsonGenerator, String),
    "scripts":
       EBISU_UTILS.randJson(_randomJsonGenerator, [],
        () => Script.randJson()),
    "app": EBISU_UTILS.randJson(_randomJsonGenerator, App.randJson),
    "testLibraries":
       EBISU_UTILS.randJson(_randomJsonGenerator, [],
        () => Library.randJson()),
    "libraries":
       EBISU_UTILS.randJson(_randomJsonGenerator, [],
        () => Library.randJson()),
    "allLibraries":
       EBISU_UTILS.randJson(_randomJsonGenerator, [],
        () => Library.randJson()),
    "pubSpec": EBISU_UTILS.randJson(_randomJsonGenerator, PubSpec.randJson),
    "jsonableClasses":
       EBISU_UTILS.randJsonMap(_randomJsonGenerator,
        () => Class.randJson(),
        "jsonableClasses"),
    "finalized": EBISU_UTILS.randJson(_randomJsonGenerator, bool),
    "generatePubSpec": EBISU_UTILS.randJson(_randomJsonGenerator, bool),
    "license": EBISU_UTILS.randJson(_randomJsonGenerator, String),
    "includeReadme": EBISU_UTILS.randJson(_randomJsonGenerator, bool),
    "includeHop": EBISU_UTILS.randJson(_randomJsonGenerator, bool),
    };
  }

}

/// A test generated in a standard format
class Test {

  // custom <class Test>
  // end <class Test>

  Map toJson() {
    return {
    };
  }

  static Map randJson() {
    return {
    };
  }

}

/// An agrument to a script
class ScriptArg {

  ScriptArg(this._id);

  final Id _id;
  /// Id for this script argument
  Id get id => _id;
  /// Documentation for this script argument
  String doc;
  dynamic _parent;
  /// Reference to parent of this script argument
  dynamic get parent => _parent;
  String _name;
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

  Map toJson() {
    return {
    "id": EBISU_UTILS.toJson(_id),
    "doc": EBISU_UTILS.toJson(doc),
    "name": EBISU_UTILS.toJson(_name),
    "isRequired": EBISU_UTILS.toJson(isRequired),
    "isFlag": EBISU_UTILS.toJson(isFlag),
    "isMultiple": EBISU_UTILS.toJson(isMultiple),
    "defaultsTo": EBISU_UTILS.toJson(defaultsTo),
    "allowed": EBISU_UTILS.toJson(allowed),
    "position": EBISU_UTILS.toJson(position),
    "abbr": EBISU_UTILS.toJson(abbr),
    };
  }

  static Map randJson() {
    return {
    "id": EBISU_UTILS.randJson(_randomJsonGenerator, Id.randJson),
    "doc": EBISU_UTILS.randJson(_randomJsonGenerator, String),
    "name": EBISU_UTILS.randJson(_randomJsonGenerator, String),
    "isRequired": EBISU_UTILS.randJson(_randomJsonGenerator, bool),
    "isFlag": EBISU_UTILS.randJson(_randomJsonGenerator, bool),
    "isMultiple": EBISU_UTILS.randJson(_randomJsonGenerator, bool),
    "defaultsTo": EBISU_UTILS.randJson(_randomJsonGenerator, dynamic.randJson),
    "allowed":
       EBISU_UTILS.randJson(_randomJsonGenerator, [],
        () => EBISU_UTILS.randJson(_randomJsonGenerator, String)),
    "position": EBISU_UTILS.randJson(_randomJsonGenerator, int),
    "abbr": EBISU_UTILS.randJson(_randomJsonGenerator, String),
    };
  }

}

/// A typical script - (i.e. like a bash/python/ruby script but in dart)
class Script {

  Script(this._id);

  final Id _id;
  /// Id for this script
  Id get id => _id;
  /// Documentation for this script
  String doc;
  dynamic _parent;
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
    mergeWithFile(META.script(this), scriptPath);
  }

  Iterable get requiredArgs =>
    args.where((arg) => arg.isRequired);

// end <class Script>

  Map toJson() {
    return {
    "id": EBISU_UTILS.toJson(_id),
    "doc": EBISU_UTILS.toJson(doc),
    "includeCustom": EBISU_UTILS.toJson(includeCustom),
    "imports": EBISU_UTILS.toJson(imports),
    "args": EBISU_UTILS.toJson(args),
    };
  }

  static Map randJson() {
    return {
    "id": EBISU_UTILS.randJson(_randomJsonGenerator, Id.randJson),
    "doc": EBISU_UTILS.randJson(_randomJsonGenerator, String),
    "includeCustom": EBISU_UTILS.randJson(_randomJsonGenerator, bool),
    "imports":
       EBISU_UTILS.randJson(_randomJsonGenerator, [],
        () => EBISU_UTILS.randJson(_randomJsonGenerator, String)),
    "args":
       EBISU_UTILS.randJson(_randomJsonGenerator, [],
        () => ScriptArg.randJson()),
    };
  }

}

/// Defines a dart *web* application. For non-web console app, use Script
class App {

  App(this._id);

  final Id _id;
  /// Id for this app
  Id get id => _id;
  /// Documentation for this app
  String doc;
  dynamic _parent;
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
    mergeWithFile(META.app(this), appPath);
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
  build(new Options().arguments, ['web/${_id.snake}.html']);
}
''', appBuildPath);

  }

// end <class App>

  Map toJson() {
    return {
    "id": EBISU_UTILS.toJson(_id),
    "doc": EBISU_UTILS.toJson(doc),
    "includeCustom": EBISU_UTILS.toJson(includeCustom),
    "classes": EBISU_UTILS.toJson(classes),
    "libraries": EBISU_UTILS.toJson(libraries),
    "variables": EBISU_UTILS.toJson(variables),
    "isWebUi": EBISU_UTILS.toJson(isWebUi),
    };
  }

  static Map randJson() {
    return {
    "id": EBISU_UTILS.randJson(_randomJsonGenerator, Id.randJson),
    "doc": EBISU_UTILS.randJson(_randomJsonGenerator, String),
    "includeCustom": EBISU_UTILS.randJson(_randomJsonGenerator, bool),
    "classes":
       EBISU_UTILS.randJson(_randomJsonGenerator, [],
        () => Class.randJson()),
    "libraries":
       EBISU_UTILS.randJson(_randomJsonGenerator, [],
        () => Library.randJson()),
    "variables":
       EBISU_UTILS.randJson(_randomJsonGenerator, [],
        () => Variable.randJson()),
    "isWebUi": EBISU_UTILS.randJson(_randomJsonGenerator, bool),
    };
  }

}

/// Defines a dart library - a collection of parts
class Library {

  Library(this._id);

  final Id _id;
  /// Id for this library
  Id get id => _id;
  /// Documentation for this library
  String doc;
  dynamic _parent;
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
  String _name;
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

  set parent(p) {
    _name = _id.snake;
    parts.forEach((part) => part.parent = this);
    variables.forEach((v) => v.parent = this);
    enums.forEach((e) => e.parent = this);
    classes.forEach((c) => c.parent = this);
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

    mergeWithFile(META.library(this), libStubPath);
    parts.forEach((part) => part.generate());
  }

  bool isClassJsonable(String className) => _parent.isClassJsonable(className);

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

  Map toJson() {
    return {
    "id": EBISU_UTILS.toJson(_id),
    "doc": EBISU_UTILS.toJson(doc),
    "includeCustom": EBISU_UTILS.toJson(includeCustom),
    "imports": EBISU_UTILS.toJson(imports),
    "parts": EBISU_UTILS.toJson(parts),
    "variables": EBISU_UTILS.toJson(variables),
    "classes": EBISU_UTILS.toJson(classes),
    "enums": EBISU_UTILS.toJson(enums),
    "name": EBISU_UTILS.toJson(_name),
    "includeLogger": EBISU_UTILS.toJson(includeLogger),
    "isTest": EBISU_UTILS.toJson(isTest),
    "includeMain": EBISU_UTILS.toJson(includeMain),
    "path": EBISU_UTILS.toJson(path),
    "libMain": EBISU_UTILS.toJson(libMain),
    };
  }

  static Map randJson() {
    return {
    "id": EBISU_UTILS.randJson(_randomJsonGenerator, Id.randJson),
    "doc": EBISU_UTILS.randJson(_randomJsonGenerator, String),
    "includeCustom": EBISU_UTILS.randJson(_randomJsonGenerator, bool),
    "imports":
       EBISU_UTILS.randJson(_randomJsonGenerator, [],
        () => EBISU_UTILS.randJson(_randomJsonGenerator, String)),
    "parts":
       EBISU_UTILS.randJson(_randomJsonGenerator, [],
        () => Part.randJson()),
    "variables":
       EBISU_UTILS.randJson(_randomJsonGenerator, [],
        () => Variable.randJson()),
    "classes":
       EBISU_UTILS.randJson(_randomJsonGenerator, [],
        () => Class.randJson()),
    "enums":
       EBISU_UTILS.randJson(_randomJsonGenerator, [],
        () => Enum.randJson()),
    "name": EBISU_UTILS.randJson(_randomJsonGenerator, String),
    "includeLogger": EBISU_UTILS.randJson(_randomJsonGenerator, bool),
    "isTest": EBISU_UTILS.randJson(_randomJsonGenerator, bool),
    "includeMain": EBISU_UTILS.randJson(_randomJsonGenerator, bool),
    "path": EBISU_UTILS.randJson(_randomJsonGenerator, String),
    "libMain": EBISU_UTILS.randJson(_randomJsonGenerator, String),
    };
  }

}

/// Defines a dart part - as in 'part of' source file
class Part {

  Part(this._id);

  final Id _id;
  /// Id for this part
  Id get id => _id;
  /// Documentation for this part
  String doc;
  dynamic _parent;
  /// Reference to parent of this part
  dynamic get parent => _parent;
  /// If true a custom section will be included for app
  bool includeCustom = true;
  /// Classes defined in this part of the library
  List<Class> classes = [];
  /// Enums defined in this part of the library
  List<Enum> enums = [];
  String _name;
  /// Name of the part - for use in naming the part file
  String get name => _name;
  String _filePath;
  /// Path to the generated part dart file
  String get filePath => _filePath;

// custom <class Part>

  set parent(p) {
    _name = _id.snake;
    classes.forEach((dc) => dc.parent = this);
    enums.forEach((e) => e.parent = this);
    _parent = p;
  }

  void generate() {
    _filePath = 
      _parent.isTest?
      "${_parent.rootPath}/test/src/${_parent.name}/${_name}.dart" :
      "${_parent.rootPath}/lib/src/${_parent.name}/${_name}.dart";
    mergeWithFile(META.part(this), _filePath);
  }

  bool isClassJsonable(String className) => _parent.isClassJsonable(className);

// end <class Part>

  Map toJson() {
    return {
    "id": EBISU_UTILS.toJson(_id),
    "doc": EBISU_UTILS.toJson(doc),
    "includeCustom": EBISU_UTILS.toJson(includeCustom),
    "classes": EBISU_UTILS.toJson(classes),
    "enums": EBISU_UTILS.toJson(enums),
    "name": EBISU_UTILS.toJson(_name),
    "filePath": EBISU_UTILS.toJson(_filePath),
    };
  }

  static Map randJson() {
    return {
    "id": EBISU_UTILS.randJson(_randomJsonGenerator, Id.randJson),
    "doc": EBISU_UTILS.randJson(_randomJsonGenerator, String),
    "includeCustom": EBISU_UTILS.randJson(_randomJsonGenerator, bool),
    "classes":
       EBISU_UTILS.randJson(_randomJsonGenerator, [],
        () => Class.randJson()),
    "enums":
       EBISU_UTILS.randJson(_randomJsonGenerator, [],
        () => Enum.randJson()),
    "name": EBISU_UTILS.randJson(_randomJsonGenerator, String),
    "filePath": EBISU_UTILS.randJson(_randomJsonGenerator, String),
    };
  }

}

/// Metadata associated with a Dart class
class Class {

  Class(this._id);

  final Id _id;
  /// Id for this Dart class
  Id get id => _id;
  /// Documentation for this Dart class
  String doc;
  dynamic _parent;
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
  Map<String,Ctor> _ctors = {};
  /// List of ctors of this class
  Map<String,Ctor> get ctors => _ctors;
  /// If true, class is abstract
  bool isAbstract = false;
  /// If true, generate toJson
  bool toJsonSupport = false;
  /// If true creates library functions to construct forwarding to ctors
  bool ctorSansNew = false;
  /// If true, generate toJson/fromJson on all members that are not jsonTransient
  bool jsonSupport = false;
  String _name;
  /// Name of the class - sans any access prefix (i.e. no '_')
  String get name => _name;
  String _className;
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

    if(jsonSupport) 
      toJsonSupport = true;

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

  String define() {
    return META.class_(this);
  }

  dynamic noSuchMethod(Invocation msg) {
    throw new ArgumentError("Class does not support ${msg.memberName}");
  }

  bool isClassJsonable(String className) => _parent.isClassJsonable(className);

// end <class Class>

  Map toJson() {
    return {
    "id": EBISU_UTILS.toJson(_id),
    "doc": EBISU_UTILS.toJson(doc),
    "isPublic": EBISU_UTILS.toJson(isPublic),
    "mixins": EBISU_UTILS.toJson(mixins),
    "extend": EBISU_UTILS.toJson(extend),
    "implement": EBISU_UTILS.toJson(implement),
    "includeCustom": EBISU_UTILS.toJson(includeCustom),
    "defaultMemberAccess": EBISU_UTILS.toJson(defaultMemberAccess),
    "members": EBISU_UTILS.toJson(members),
    "ctorCustoms": EBISU_UTILS.toJson(ctorCustoms),
    "ctorConst": EBISU_UTILS.toJson(ctorConst),
    "ctors": EBISU_UTILS.toJson(_ctors),
    "isAbstract": EBISU_UTILS.toJson(isAbstract),
    "toJsonSupport": EBISU_UTILS.toJson(toJsonSupport),
    "ctorSansNew": EBISU_UTILS.toJson(ctorSansNew),
    "jsonSupport": EBISU_UTILS.toJson(jsonSupport),
    "name": EBISU_UTILS.toJson(_name),
    "className": EBISU_UTILS.toJson(_className),
    };
  }

  static Map randJson() {
    return {
    "id": EBISU_UTILS.randJson(_randomJsonGenerator, Id.randJson),
    "doc": EBISU_UTILS.randJson(_randomJsonGenerator, String),
    "isPublic": EBISU_UTILS.randJson(_randomJsonGenerator, bool),
    "mixins":
       EBISU_UTILS.randJson(_randomJsonGenerator, [],
        () => EBISU_UTILS.randJson(_randomJsonGenerator, String)),
    "extend": EBISU_UTILS.randJson(_randomJsonGenerator, String),
    "implement":
       EBISU_UTILS.randJson(_randomJsonGenerator, [],
        () => EBISU_UTILS.randJson(_randomJsonGenerator, String)),
    "includeCustom": EBISU_UTILS.randJson(_randomJsonGenerator, bool),
    "defaultMemberAccess": EBISU_UTILS.randJson(_randomJsonGenerator, Access.randJson),
    "members":
       EBISU_UTILS.randJson(_randomJsonGenerator, [],
        () => Member.randJson()),
    "ctorCustoms":
       EBISU_UTILS.randJson(_randomJsonGenerator, [],
        () => EBISU_UTILS.randJson(_randomJsonGenerator, String)),
    "ctorConst":
       EBISU_UTILS.randJson(_randomJsonGenerator, [],
        () => EBISU_UTILS.randJson(_randomJsonGenerator, String)),
    "ctors":
       EBISU_UTILS.randJsonMap(_randomJsonGenerator,
        () => Ctor.randJson(),
        "ctors"),
    "isAbstract": EBISU_UTILS.randJson(_randomJsonGenerator, bool),
    "toJsonSupport": EBISU_UTILS.randJson(_randomJsonGenerator, bool),
    "ctorSansNew": EBISU_UTILS.randJson(_randomJsonGenerator, bool),
    "jsonSupport": EBISU_UTILS.randJson(_randomJsonGenerator, bool),
    "name": EBISU_UTILS.randJson(_randomJsonGenerator, String),
    "className": EBISU_UTILS.randJson(_randomJsonGenerator, String),
    };
  }

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
    new Id('${classId.snake}_${IdFromEither(name)}');

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
    }

    return '''
${formatFill(decl)})${body}
''';
  }

// end <class Ctor>

  Map toJson() {
    return {
    "className": EBISU_UTILS.toJson(className),
    "name": EBISU_UTILS.toJson(name),
    "members": EBISU_UTILS.toJson(members),
    "optMembers": EBISU_UTILS.toJson(optMembers),
    "namedMembers": EBISU_UTILS.toJson(namedMembers),
    "hasCustom": EBISU_UTILS.toJson(hasCustom),
    "isConst": EBISU_UTILS.toJson(isConst),
    };
  }

  static Map randJson() {
    return {
    "className": EBISU_UTILS.randJson(_randomJsonGenerator, String),
    "name": EBISU_UTILS.randJson(_randomJsonGenerator, String),
    "members":
       EBISU_UTILS.randJson(_randomJsonGenerator, [],
        () => Member.randJson()),
    "optMembers":
       EBISU_UTILS.randJson(_randomJsonGenerator, [],
        () => Member.randJson()),
    "namedMembers":
       EBISU_UTILS.randJson(_randomJsonGenerator, [],
        () => Member.randJson()),
    "hasCustom": EBISU_UTILS.randJson(_randomJsonGenerator, bool),
    "isConst": EBISU_UTILS.randJson(_randomJsonGenerator, bool),
    };
  }

}

/// Metadata associated with a member of a Dart class
class Member {

  Member(this._id);

  final Id _id;
  /// Id for this class member
  Id get id => _id;
  /// Documentation for this class member
  String doc;
  dynamic _parent;
  /// Reference to parent of this class member
  dynamic get parent => _parent;
  /// Type of the member
  String type = "String";
  /// Access level supported for this member
  Access access;
  /// If provided the member will be initialized to this text in place of declaration of class
  String classInit;
  /// If provided the member will be initialized to this text in generated ctor initializers
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
  String _name;
  /// Name of variable for the member, excluding access prefix (i.e. no '_')
  String get name => _name;
  String _varName;
  /// Name of variable for the member - varies depending on public/private
  String get varName => _varName;

// custom <class Member>

  bool get isPublic => access == Access.RW;

  set parent(p) {
    _name = id.camel;
    if(access == null) access = Access.RW;
    _varName = isPublic? _name : "_$_name";
    _parent = p;
  }

  String define() {
    return META.member(this);
  }

// end <class Member>

  Map toJson() {
    return {
    "id": EBISU_UTILS.toJson(_id),
    "doc": EBISU_UTILS.toJson(doc),
    "type": EBISU_UTILS.toJson(type),
    "access": EBISU_UTILS.toJson(access),
    "classInit": EBISU_UTILS.toJson(classInit),
    "ctorInit": EBISU_UTILS.toJson(ctorInit),
    "ctors": EBISU_UTILS.toJson(ctors),
    "ctorsOpt": EBISU_UTILS.toJson(ctorsOpt),
    "ctorsNamed": EBISU_UTILS.toJson(ctorsNamed),
    "isFinal": EBISU_UTILS.toJson(isFinal),
    "isConst": EBISU_UTILS.toJson(isConst),
    "isStatic": EBISU_UTILS.toJson(isStatic),
    "jsonTransient": EBISU_UTILS.toJson(jsonTransient),
    "name": EBISU_UTILS.toJson(_name),
    "varName": EBISU_UTILS.toJson(_varName),
    };
  }

  static Map randJson() {
    return {
    "id": EBISU_UTILS.randJson(_randomJsonGenerator, Id.randJson),
    "doc": EBISU_UTILS.randJson(_randomJsonGenerator, String),
    "type": EBISU_UTILS.randJson(_randomJsonGenerator, String),
    "access": EBISU_UTILS.randJson(_randomJsonGenerator, Access.randJson),
    "classInit": EBISU_UTILS.randJson(_randomJsonGenerator, String),
    "ctorInit": EBISU_UTILS.randJson(_randomJsonGenerator, String),
    "ctors":
       EBISU_UTILS.randJson(_randomJsonGenerator, [],
        () => EBISU_UTILS.randJson(_randomJsonGenerator, String)),
    "ctorsOpt":
       EBISU_UTILS.randJson(_randomJsonGenerator, [],
        () => EBISU_UTILS.randJson(_randomJsonGenerator, String)),
    "ctorsNamed":
       EBISU_UTILS.randJson(_randomJsonGenerator, [],
        () => EBISU_UTILS.randJson(_randomJsonGenerator, String)),
    "isFinal": EBISU_UTILS.randJson(_randomJsonGenerator, bool),
    "isConst": EBISU_UTILS.randJson(_randomJsonGenerator, bool),
    "isStatic": EBISU_UTILS.randJson(_randomJsonGenerator, bool),
    "jsonTransient": EBISU_UTILS.randJson(_randomJsonGenerator, bool),
    "name": EBISU_UTILS.randJson(_randomJsonGenerator, String),
    "varName": EBISU_UTILS.randJson(_randomJsonGenerator, String),
    };
  }

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
final RegExp _jsonMapTypeRe = new RegExp(r"Map<\s*String,\s*(.*?)\s*>");
final RegExp _jsonListTypeRe = new RegExp(r"List<\s*(.*?)\s*>");

bool isJsonableType(String t) =>_jsonableTypeRe.firstMatch(t) != null;
bool isMapType(String t) => _mapTypeRe.firstMatch(t) != null;
bool isListType(String t) => _listTypeRe.firstMatch(t) != null;

String jsonMapValueType(String t) {
  Match m = _jsonMapTypeRe.firstMatch(t);
  if(m != null) {
    return m.group(1);
  }
  return null;
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

