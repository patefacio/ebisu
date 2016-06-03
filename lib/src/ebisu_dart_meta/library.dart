part of ebisu.ebisu_dart_meta;

/// List of libraries supporting a feature set.
///
/// Some large features are best implemented as a collection of
/// libraries. Decomposition of large functionality can be achieved with a single
/// library with multiple *parts*. But this has drawbacks.  [see also why parts are
/// not ideal](https://groups.google.com/a/dartlang.org/d/msg/misc/Q7loz93GKf8/jsBLCSSJAQAJ)
/// A better approach is to develop libraries keeping boundaries and managing
/// dependencies, rather than the all-or-nothing nature of parts.
///
/// It may be the best way to expose that functionality is a single library.
class LibraryGroup extends Object with Entity {
  /// Id for this library_group
  Id get id => _id;

  /// Libraries exposed to the client
  List<Library> externalLibraries = [];

  /// Implementation libraries
  List<Library> internalLibraries = [];

  // custom <class LibraryGroup>

  LibraryGroup(this._id);

  Iterable<Entity> get children =>
      concat([externalLibraries, internalLibraries]);

  onOwnershipEstablished() {
    for (Library lib in externalLibraries) {
      lib.path = '$rootPath/lib';
    }
    for (Library lib in internalLibraries) {
      lib.path = '$rootPath/lib/src/${id.snake}';
    }
  }

  void generate() {
    externalLibraries.forEach((l) => l.generate());
    internalLibraries.forEach((l) => l.generate());
  }

  String get rootPath => (rootEntity as System).rootPath;

  // end <class LibraryGroup>

  final Id _id;
}

/// Defines a dart library - a collection of parts
class Library extends Object with CustomCodeBlock, Entity {
  /// Id for this library
  Id get id => _id;

  /// List of imports to be included by this library
  List<String> imports = [];

  /// List of exports to be included by this library
  List<String> exports = [];

  /// If not null this library is generated in *lib/src/${internalGroup}* folder.
  ///
  /// This is an intended as a replacement for *parts*.
  String get libraryGroup => _libraryGroup;

  /// List of parts in this library
  List<Part> parts = [];

  /// List of global variables for this library
  List<Variable> variables = [];

  /// Classes defined in this library
  List<Class> classes = [];

  /// Named benchmarks associated with this library
  List<Benchmark> benchmarks = [];

  /// Enums defined in this library
  List<Enum> enums = [];

  /// Name of the library file
  String get name => _name;

  /// Qualified name of the library used inside library and library parts - qualified to reduce collisions
  String get qualifiedName => _qualifiedName;

  /// If true includes logging support and a _logger
  bool includesLogger = false;

  /// If true this library is a test library to appear in test folder
  bool get isTest => _isTest;

  /// Code block inside main for custom code
  set mainCustomBlock(CodeBlock mainCustomBlock) =>
      _mainCustomBlock = mainCustomBlock;

  /// Set desired if generating just a lib and not a package
  String path;

  /// If set the main function
  String libMain;

  /// Default access for members
  set defaultMemberAccess(Access defaultMemberAccess) =>
      _defaultMemberAccess = defaultMemberAccess;

  /// If true classes will get library functions to construct forwarding to ctors
  bool hasCtorSansNew = false;

  /// If true the library is placed under .../lib/src
  bool isPrivate = false;

  /// If true includes comment about code being generated.
  set includeGeneratedPrologue(bool includeGeneratedPrologue) =>
      _includeGeneratedPrologue = includeGeneratedPrologue;

  /// If true includes comment containing stack trace to help find the dart code that
  /// generated the source.
  set includeStackTrace(bool includeStackTrace) =>
      _includeStackTrace = includeStackTrace;

  // custom <class Library>

  Library(this._id) {
    _name = _id.snake;
    includesProtectBlock = true;
  }

  get defaultMemberAccess => _defaultMemberAccess ?? ebisuDefaultMemberAccess;

  /// Returns children entities of the library, including [parts], [variables],
  /// [classes], etc...
  Iterable<Entity> get children =>
      concat([parts, variables, classes, benchmarks, enums]);

  /// Returns all classes from all library stub and all constituent parts
  List<Class> get allClasses {
    List<Class> result = new List.from(classes);
    parts.forEach((part) => result.addAll(part.classes));
    return result;
  }

  /// If true ensures main and logging functionality is provided as well as imports
  set isTest(bool t) {
    if (t) {
      _isTest = true;
      includesMain = true;
      includesLogger = true;
      imports
          .addAll(['package:logging/logging.dart', 'package:test/test.dart',]);
    }
  }

  /// Returns this library as it would appear in an import statement
  String get asImport => 'package:$_packageName/${id.snake}.dart';

  /// Called when all declarative work is done and the [Entity] tree is complete.
  ///
  /// Provides [Entity] instances an opportunity to perform work before
  /// code generation
  onOwnershipEstablished() {
    _qualifiedName =
        _qualifiedName == null ? _makeQualifiedName() : _qualifiedName;

    if (allClasses.any((c) => c.hasOpEquals)) {
      imports.add('package:quiver/core.dart');
    }
    if (allClasses.any((c) => c.hasJsonSupport)) {
      imports.add('"package:ebisu/ebisu.dart" as ebisu');
      imports.add('"dart:convert" as convert');
    }
    if (allClasses.any((c) => c.requiresEqualityHelpers == true)) {
      imports.add('package:collection/equality.dart');
    }
    if (includesLogger) {
      imports.add("package:logging/logging.dart");
    }
  }

  importAndExport(lib) {
    imports.add(lib);
    exports.add(lib);
  }

  importAndExportAll(Iterable libs) =>
      libs.forEach((lib) => importAndExport(lib));

  /// Returns path to the library
  String get libStubPath => join(
      (path ??
          (isPrivate
              ? join(rootPath, 'lib', 'src')
              : (isTest ? join(rootPath, 'test') : join(rootPath, 'lib')))),
      '${id.snake}.dart');

  get includeGeneratedPrologue =>
      (rootEntity as System)?.includeGeneratedPrologue ?? false;
  get includeStackTrace => (rootEntity as System)?.includeStackTrace ?? false;

  /// Generate all artifiacts within the library
  void generate() {
    _ensureOwner();
    final content = _content;
    final withPrologue =
        includeGeneratedPrologue ? tagGeneratedContent(content) : content;
    final withStackTrace =
        includeStackTrace ? commentStackTrace(withPrologue) : withPrologue;
    mergeWithDartFile('${withStackTrace}\n', libStubPath);
    parts.forEach((part) => part.generate());
    benchmarks.forEach((benchmark) => benchmark.generate());
  }

  /// Returns a string with all contents concatenated together
  get tar {
    _ensureOwner();
    return combine([_content, parts.map((p) => p._content)]);
  }

  /// Provide for modification of the [mainCustomBlock]
  withMainCustomBlock(f(CodeBlock cb)) => f(mainCustomBlock);

  /// Returns true if this library includes a *main*
  get includesMain => _mainCustomBlock != null;

  /// If true initializes a [mainCustomBlock] else removes one if set
  set includesMain(bool im) =>
      _mainCustomBlock = (im && _mainCustomBlock == null)
          ? new CodeBlock(null)
          : im ? _mainCustomBlock : null;

  /// Returns the [uri] with quotes as required by a dart import statement
  static String importUri(String uri) {
    if (null == _hasQuotes.firstMatch(uri)) {
      return '"${uri}"';
    } else {
      return '${uri}';
    }
  }

  /// Returns [theImport] as an import statement
  ///
  ///     importStatement('io') => 'import "dart:io"';
  ///
  static String importStatement(String theImport) {
    if (_standardImports.contains(theImport)) {
      return 'import "dart:$theImport";';
    } else if (_standardPackageImports.contains(theImport)) {
      return 'import "package:$theImport";';
    } else {
      return 'import ${importUri(theImport)};';
    }
  }

  /// Returns the root path of this [Library]
  String get rootPath => (rootEntity as System).rootPath ?? '/tmp';

  String get _additionalPathParts {
    List relPath = split(relative(dirname(libStubPath), from: rootPath));
    if (relPath.length > 0 &&
        (relPath.first == '.' || relPath.first == 'lib')) {
      relPath.removeAt(0);
    }
    return relPath.join('.');
  }

  String get _packageName => root.id.snake;

  String _makeQualifiedName() {
    var pathParts = _additionalPathParts;
    var pkgName = _packageName;
    String result = _id.snake;
    if (pathParts.length > 0) result = '$pathParts.$result';
    if (pkgName.length > 0) result = '$pkgName.$result';
    return result;
  }

  _ensureOwner() {
    if (owner == null) {
      owner = system('ignored');
    }
  }

  get _content => br([
        brCompact([this.docComment, _libraryStatement]),
        brCompact(_cleansedImports),
        brCompact(_cleansedExports),
        _additionalImports,
        brCompact(_parts),
        _loggerInit,
        _enums,
        _classes,
        _variables,
        _libraryCustom,
        _libraryMain,
      ]);

  get _cleansedImports =>
      cleanImports(imports.map((i) => importStatement(i)).toList());
  get _exportStatements => exports.map((e) => "export '$e';");
  get _cleansedExports {
    final unique = new Set();
    return _exportStatements.where((e) => unique.add(e)).toList()..sort();
  }
  get _libraryStatement => 'library $qualifiedName;\n';
  get _additionalImports => customBlock('additional imports');
  get _parts => parts.length > 0
      ? ([]
        ..addAll(parts.map((p) => "part 'src/$name/${p.name}.dart';\n"))
        ..sort())
      : '';
  get _loggerInit =>
      includesLogger ? "final _logger = new Logger('$name');\n" : '';
  get _enums => enums.map((e) => '${chomp(e.define())}\n').join('\n');
  get _classes => classes.map((c) => '${chomp(c.define())}\n').join('\n');
  get _variables => variables.map((v) => chomp(v.define())).join('\n');

  set includesProtectBlock(bool value) =>
      customCodeBlock.tag = value ? 'library $name' : null;

  get _libraryCustom => indentBlock(blockText);

  get _initLogger => isTest
      ? r"""
  Logger.root.onRecord.listen((LogRecord r) =>
      print("${r.loggerName} [${r.level}]:\t${r.message}"));
  Logger.root.level = Level.OFF;
"""
      : '';

  get mainCustomBlock => _mainCustomBlock =
      _mainCustomBlock == null ? new CodeBlock(null) : _mainCustomBlock;

  get _mainCustomText => _mainCustomBlock != null
      ? (_mainCustomBlock..tag = 'main').toString()
      : '';

  get _libraryMain => includesMain
      ? '''
main([List<String> args]) {
$_initLogger${_mainCustomText}
}'''
      : (libMain != null) ? libMain : '';

  static final _standardImports = new Set.from([
    'async',
    'chrome',
    'collection',
    'core',
    'crypto',
    'html',
    'indexed_db',
    'io',
    'isolate',
    'json',
    'math',
    'mirrors',
    'scalarlist',
    'svg',
    'uri',
    'utf',
    'web_audio',
    'web_sql',
    'convert',
    'typed_data',
  ]);

  static final _standardPackageImports = new Set.from([
    'args',
    'fixnum',
    'intl',
    'logging',
    'matcher',
    'meta',
    'mock',
    'scheduled_test',
    'serialization',
    'unittest',
    'test',
  ]);

  static final RegExp _hasQuotes = new RegExp(r'''[\'"]''');

  // end <class Library>

  final Id _id;
  String _libraryGroup;
  String _name;
  String _qualifiedName;
  bool _isTest = false;
  CodeBlock _mainCustomBlock;
  Access _defaultMemberAccess;
  bool _includeGeneratedPrologue;
  bool _includeStackTrace;
}

// custom <part library>
// end <part library>
