part of ebisu.ebisu_dart_meta;

/// Defines a dart system (collection of libraries and apps)
class System extends Object with Entity {
  /// Id for this system
  Id get id => _id;

  /// Path to which code is generated
  String rootPath;

  /// Scripts in the system
  List<Script> scripts = [];

  /// App for this package
  App app;

  /// List of test libraries of this app
  List<Library> testLibraries = [];

  /// LibraryGroups in the system
  List<LibraryGroup> libraryGroups = [];

  /// Libraries in the system
  List<Library> libraries = [];

  /// Regular and test libraries
  List<Library> allLibraries = [];

  /// Information for the pubspec
  PubSpec pubSpec;

  /// Map of all classes with hasJsonSupport true
  Map<String, Object> jsonableClasses = {};

  /// Set to true on finalize
  bool get finalized => _finalized;

  /// If true generate a pubspec.xml file
  bool generatesPubSpec = true;

  /// A string indicating the license.
  /// A map of common licenses is looked up and if found a link
  /// to that license is used. The current keys of the map are:
  /// [ 'boost', 'mit', 'apache-2.0', 'bsd-2', 'bsd-3', 'mozilla-2.0' ]
  /// Otherwise the text is assumed to be the
  /// text to include in the license file.
  String license;

  /// If true standard outline for readme provided
  bool includesReadme = false;

  /// A brief introduction for this system, included in README.md
  String introduction;

  /// Purpose for this system, included in README.md
  String purpose;

  /// List of todos included in the readme - If any present includesReadme assumed true
  List<String> todos = [];

  /// If true includes comment about code being generated.
  bool includeGeneratedPrologue = false;

  /// If true includes comment containing stack trace to help find the dart code that
  /// generated the source.
  bool includeStackTrace = false;

  // custom <class System>

  Iterable<Entity> get children => concat([
        scripts,
        libraryGroups,
        libraries,
        testLibraries,
        [pubSpec]
      ]);

  /// Create system from the id
  System(Id id)
      : _id = id,
        pubSpec = new PubSpec(id) {}

  /// Finalize must be called before generate
  void finalize() {
    if (!_finalized) {
      testLibraries.forEach((library) {
        library.isTest = true;
      });

      allLibraries = new List.from(libraries)..addAll(testLibraries);

      // Track all classes and enums with json support so the template side can
      // do proper inserts of code. There are classes and enums in the library
      // as well as classes and enums in each part to consider.
      bool benchmarksIncluded = false;
      allLibraries.forEach((Library library) {
        if (library.benchmarks.length > 0) benchmarksIncluded = true;

        library.classes.forEach((dclass) {
          if (dclass.hasJsonSupport) {
            jsonableClasses[dclass.name] = dclass;
          }
        });
        library.enums.forEach((e) {
          jsonableClasses[e.name] = e;
        });
        library.parts.forEach((part) {
          part.classes.forEach((dclass) {
            if (dclass.hasJsonSupport) {
              jsonableClasses[dclass.name] = dclass;
            }
          });
          part.enums.forEach((e) {
            jsonableClasses[e.name] = e;
          });
        });
      });

      if (benchmarksIncluded) {
        pubSpec.addDependency(new PubDependency('benchmark_harness'));
      }

      _finalized = true;
    }
  }

  void overridePubs() {
    var overrideFile = new File(ebisuPubVersions);
    if (overrideFile.existsSync()) {
      var overrideJson = convert.json.decode(overrideFile.readAsStringSync());
      var overrides = overrideJson['versions'];
      _logger.fine("Found version overides: ${overrideJson}");
      var deps = new List.from(pubSpec.dependencies)
        ..addAll(pubSpec.devDependencies);
      deps.forEach((dep) {
        var override = overrides[dep.name];
        if (override != null) {
          _logger
              .fine("Overriding: (((\n${dep.yamlEntry}\n))) with ${override}");
          var version = override['version'];
          if (version != null) {
            dep.version = version;
            dep.path = null;
            dep._type = PubDepType.HOSTED;
          } else {
            var path = override['path'];
            if (path != null) {
              dep.path = path;
              dep.version = null;
              dep.gitRef = null;
              dep._type = PubDepType.PATH;
              _logger.fine("Yaml: ${dep.yamlEntry}");
            } else {
              throw new FormatException('''
Entry ($override) in ${ebisuPubVersions} invalid.
Only "version" and "path" overrides are supported.
''');
            }
          }
        }
      });
    } else {
      _logger.fine("NOT Found version overrides: ${ebisuPubVersions}");
    }
  }

  /// Generate the code
  void generate(
      {generateRunner: true,
      generateDrudge: true,
      reportNonGeneratedFiles: false}) {
    setAsRoot();

    if (rootPath == null) rootPath = '.';

    if (app != null) {
      if (pubSpec == null) {
        pubSpec = new PubSpec(app.id)
          ..addDependency(new PubDependency('browser'))
          ..addDependency(new PubDependency('path'))
          ..addDependency(new PubDependency('polymer'));
      }
    }

    if (generateDrudge) {
      final drudgeScript = join(rootPath, 'bin', 'drudge.${id.snake}.dart');
      mergeWithFile(new DrudgeScriptGenerator(this).contents, drudgeScript);
    }

    finalize();

    scripts.forEach((script) => script.generate());
    if (app != null) {
      app.generate();
    }

    allLibraries.forEach((lib) => lib.generate());

    if (pubSpec != null && generatesPubSpec) {
      overridePubs();
      String pubSpecPath = "${rootPath}/pubspec.yaml";
      scriptMergeWithFile('${pubSpec.content}\n', pubSpecPath);
    }

    if (license != null) {
      var text = licenseMap[license];
      if (text == null) text = license;
      String licensePath = "${rootPath}/LICENSE";
      mergeWithFile(text, licensePath);
    }

    {
      String gitIgnorePath = "${rootPath}/.gitignore";
      scriptMergeWithFile('''
*.~*~
.packages
packages
build/
.pub/
.project
*.iml
*.ipr
*.iws
.idea/
*.dart.js
*.js_
*.js.deps
*.js.map
${scriptCustomBlock('additional')}
''', gitIgnorePath);
    }

    if (includesReadme ||
        todos.length > 0 ||
        introduction != null ||
        purpose != null) {
      String readmePath = "${rootPath}/README.md";
      panDocMergeWithFile('''
# ${id.title}


${(introduction != null) ? introduction : ''}
${panDocCustomBlock('introduction')}

# Purpose
${(purpose != null) ? purpose : ''}
${panDocCustomBlock('purpose')}

${panDocCustomBlock('body')}

# Examples

${panDocCustomBlock('examples')}

${(todos.length > 0) ? "# Todos\n\n- ${todos.join('\n-')}\n${panDocCustomBlock('todos')}" : ""}

''', readmePath);
    }

    if (generateRunner) {
      String testRunnerPath = "${rootPath}/test/runner.dart";
      testLibRelativePath(Library testLib) =>
          relative(testLib.libStubPath, from: dirname(testRunnerPath));
      mergeWithDartFile('''
import 'package:logging/logging.dart';
${testLibraries.where((t) => t.id.snake.startsWith('test_')).map((t) => "import '${testLibRelativePath(t)}' as ${t.id.snake};").join('\n')}

void main() {
  Logger.root.level = Level.OFF;
  Logger.root.onRecord.listen((LogRecord rec) {
    print('\${rec.level.name}: \${rec.time}: \${rec.message}');
  });

${testLibraries.where((t) => t.id.snake.startsWith('test_')).map((t) => "  ${t.id.snake}.main(null);").join('\n')}
}

''', testRunnerPath);
    }

    if (testLibraries.length > 0) {
      /// *TODO* Figure out how html testing works in [test]
    }

    if (reportNonGeneratedFiles) {
      print('''
**** NON GENERATED FILES ****
${indentBlock(brCompact(nonGeneratedFiles))}
''');
    }
  }

  scrubPubFiles() => scrubPubFilesFromRoot(rootPath);

  // end <class System>

  Id _id;
  bool _finalized = false;
}

// custom <part system>
// end <part system>
