part of ebisu.ebisu_dart_meta;

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
  /// Named benchmarks associated with this library
  List<Benchmark> benchmarks = [];
  /// Enums defined in this library
  List<Enum> enums = [];
  /// Name of the library file
  String get name => _name;
  /// Qualified name of the library used inside library and library parts - qualified to reduce collisions
  String get qualifiedName => _qualifiedName;
  /// If true includes logging support and a _logger
  bool includeLogger = false;
  /// If true this library is a test library to appear in test folder
  bool get isTest => _isTest;
  /// If true a main is included in the library file
  bool includeMain = false;
  /// Set desired if generating just a lib and not a package
  String path;
  /// If set the main function
  String libMain;
  /// Default access for members
  Access defaultMemberAccess = Access.RW;
  /// If true classes will get library functions to construct forwarding to ctors
  bool ctorSansNew = false;
  // custom <class Library>

  List<Class> get allClasses {
    List<Class> result = new List.from(classes);
    parts.forEach((part) => result.addAll(part.classes));
    return result;
  }

  set isTest(bool t) {
    if (t) {
      _isTest = true;
      includeMain = true;
      imports.add('package:unittest/unittest.dart');
    }
  }

  String get _additionalPathParts {
    String rootPath = _parent.rootPath == null ? path : _parent.rootPath;
    List relPath = split(relative(dirname(libStubPath), from: rootPath));
    if (relPath.length > 0 &&
        (relPath.first == '.' || relPath.first == 'lib')) {
      relPath.removeAt(0);
    }
    return relPath.join('.');
  }

  String get _packageName {
    var parent = _parent;
    while (parent != null) {
      if (parent is System) break;
      parent = parent.parent;
    }
    return parent == null ? '' : parent.id.snake;
  }

  String _makeQualifiedName() {
    var pathParts = _additionalPathParts;
    var pkgName = _packageName;
    String result = _id.snake;
    if (pathParts.length > 0) result = '$pathParts.$result';
    if (pkgName.length > 0) result = '$pkgName.$result';
    return result;
  }

  set parent(p) {
    _parent = p;
    _name = _id.snake;
    _qualifiedName =
        _qualifiedName == null ? _makeQualifiedName() : _qualifiedName;
    parts.forEach((part) => part.parent = this);
    variables.forEach((v) => v.parent = this);
    enums.forEach((e) => e.parent = this);
    classes.forEach((c) => c.parent = this);
    benchmarks.forEach((b) => b.parent = this.parent);

    if (allClasses.any((c) => c.opEquals)) {
      imports.add('package:quiver/core.dart');
    }
    if (allClasses.any((c) => c.jsonSupport)) {
      imports.add('"package:ebisu/ebisu_utils.dart" as ebisu_utils');
      imports.add('"dart:convert" as convert');
    }
    if (allClasses.any((c) => c.requiresEqualityHelpers == true)) {
      imports.add('package:collection/equality.dart');
    }
    if (includeLogger) {
      imports.add("package:logging/logging.dart");
    }
    imports = cleanImports(imports.map((i) => importStatement(i)).toList());
  }

  ensureParent() {
    if (_parent == null) {
      parent = system('ignored');
    }
  }

  String get libStubPath => path != null
      ? "${path}/${id.snake}.dart"
      : (isTest
          ? "${_parent.rootPath}/test/${id.snake}.dart"
          : "${_parent.rootPath}/lib/${id.snake}.dart");

  void generate() {
    ensureParent();
    mergeWithDartFile('${_content}\n', libStubPath);
    parts.forEach((part) => part.generate());
    benchmarks.forEach((benchmark) => benchmark.generate());
  }

  get _content => [
    _docComment,
    _libraryStatement,
    _imports,
    _additionalImports,
    _parts,
    _loggerInit,
    _enums,
    _classes,
    _variables,
    _libraryCustom,
    _libraryMain,
  ].where((line) => line != '').join('\n');

  get _docComment => doc != null ? docComment(doc) : '';
  get _libraryStatement => 'library $qualifiedName;\n';
  get _imports => imports.join('\n');
  get _additionalImports => customBlock('additional imports');
  get _parts => parts.length > 0
      ? parts.map((p) => "part 'src/$name/${p.name}.dart';\n").join('')
      : '';
  get _loggerInit =>
      includeLogger ? "final _logger = new Logger('$name');\n" : '';
  get _enums => enums.map((e) => '${chomp(e.define())}\n').join('\n');
  get _classes => classes.map((c) => '${chomp(c.define())}\n').join('\n');
  get _variables => variables.map((v) => chomp(v.define())).join('\n');
  get _libraryCustom =>
      includeCustom ? chomp(customBlock('library $name')) : '';
  get _libraryMain => includeMain
      ? '''
main() {
${customBlock('main')}
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
    'convert'
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
    'unittest'
  ]);

  static final RegExp _hasQuotes = new RegExp(r'''[\'"]''');

  static String importUri(String uri) {
    if (null == _hasQuotes.firstMatch(uri)) {
      return '"${uri}"';
    } else {
      return '${uri}';
    }
  }

  static String importStatement(String i) {
    if (_standardImports.contains(i)) {
      return 'import "dart:$i";';
    } else if (_standardPackageImports.contains(i)) {
      return 'import "package:$i";';
    } else {
      return 'import ${importUri(i)};';
    }
  }

  String get rootPath => _parent.rootPath;

  get _defaultAccess => defaultMemberAccess;

  // end <class Library>
  final Id _id;
  dynamic _parent;
  String _name;
  String _qualifiedName;
  bool _isTest = false;
}
// custom <part library>
// end <part library>
