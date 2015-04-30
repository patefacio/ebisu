part of ebisu.ebisu_dart_meta;

/// Defines a dart part - as in 'part of' source file
class Part extends Object with CustomCodeBlock {
  Part(this._id);

  /// Id for this part
  Id get id => _id;
  /// Documentation for this part
  String doc;
  /// Reference to parent of this part
  dynamic get parent => _parent;
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
  set defaultMemberAccess(Access defaultMemberAccess) =>
      _defaultMemberAccess = defaultMemberAccess;
  /// If true classes will get library functions to construct forwarding to ctors
  set hasCtorSansNew(bool hasCtorSansNew) => _hasCtorSansNew = hasCtorSansNew;

  // custom <class Part>

  get defaultMemberAccess => _defaultMemberAccess == null
      ? _parent.defaultMemberAccess
      : _defaultMemberAccess;

  set parent(p) {
    _parent = p;
    _name = _id.snake;
    variables.forEach((v) => v.parent = this);
    classes.forEach((dc) => dc.parent = this);
    enums.forEach((e) => e.parent = this);
  }

  void generate() {
    _filePath = _parent.isTest
        ? "${_parent.rootPath}/test/src/${_parent.name}/${_name}.dart"
        : "${_parent.rootPath}/lib/src/${_parent.name}/${_name}.dart";
    mergeWithDartFile('${chomp(_content)}\n', _filePath);
  }

  bool get hasCtorSansNew =>
      _hasCtorSansNew == null ? _parent.hasCtorSansNew : _hasCtorSansNew;

  get _content => brCompact([
    doc != null ? docComment(chomp(doc)) : null,
    _part,
    _enums,
    _classes,
    _custom,
    _variables,
  ].where((line) => line != ''));

  get _part => 'part of ${parent.qualifiedName};\n';
  get _enums => enums.map((e) => '${chomp(e.define())}\n').join('\n');
  get _classes => classes.map((c) => '${chomp(c.define())}').join('\n\n');

  /// TODO: deprecated - use includesCustom
  set includeCustom(bool ic) => includesCustom = ic;
  get _custom => chomp(taggedBlockText('part $name'));
  get _variables => variables.map((v) => chomp(v.define())).join('\n');

  // end <class Part>

  final Id _id;
  dynamic _parent;
  String _name;
  String _filePath;
  Access _defaultMemberAccess;
  bool _hasCtorSansNew;
}
// custom <part part>
// end <part part>
