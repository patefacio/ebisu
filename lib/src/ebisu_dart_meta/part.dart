part of ebisu.ebisu_dart_meta;

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
  /// Default access for members
  set defaultMemberAccess(Access defaultMemberAccess) => _defaultMemberAccess = defaultMemberAccess;
  /// If true classes will get library functions to construct forwarding to ctors
  set ctorSansNew(bool ctorSansNew) => _ctorSansNew = ctorSansNew;
  // custom <class Part>

  get defaultMemberAccess => _defaultMemberAccess == null ?
    _parent.defaultMemberAccess : _defaultMemberAccess;

  set parent(p) {
    _parent = p;
    _name = _id.snake;
    variables.forEach((v) => v.parent = this);
    classes.forEach((dc) => dc.parent = this);
    enums.forEach((e) => e.parent = this);
  }

  void generate() {
    _filePath =
      _parent.isTest?
      "${_parent.rootPath}/test/src/${_parent.name}/${_name}.dart" :
      "${_parent.rootPath}/lib/src/${_parent.name}/${_name}.dart";
    mergeWithDartFile('${chomp(_content)}\n', _filePath);
  }

  bool get ctorSansNew => _ctorSansNew == null?
  _parent.ctorSansNew : _ctorSansNew;

  get _content =>
    [
      _part,
      _enums,
      _classes,
      _custom,
      _variables,
    ]
    .where((line) => line != '')
    .join('\n');

  get _part => 'part of ${parent.qualifiedName};\n';
  get _enums => enums.map((e) => '${chomp(e.define())}\n').join('\n');
  get _classes => classes.map((c) => '${chomp(c.define())}').join('\n\n');
  get _custom => includeCustom? customBlock('part $name') : '';
  get _variables => variables.map((v) => chomp(v.define())).join('\n');

  // end <class Part>
  final Id _id;
  dynamic _parent;
  String _name;
  String _filePath;
  Access _defaultMemberAccess;
  bool _ctorSansNew;
}
// custom <part part>
// end <part part>
