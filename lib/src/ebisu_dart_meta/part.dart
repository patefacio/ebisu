part of ebisu.ebisu_dart_meta;

/// Defines a dart part - as in 'part of' source file
class Part extends Object with CustomCodeBlock, Entity {
  Part(this._id);

  /// Id for this part
  Id get id => _id;
  /// Documentation for this part
  String doc;
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

  Iterable<Entity> get children => concat([classes, enums, variables]);

  get defaultMemberAccess => _defaultMemberAccess == null
      ? _owningLibrary.defaultMemberAccess
      : _defaultMemberAccess;

  onOwnershipEstablished() {
    _name = _id.snake;
  }

  void generate() {
    _filePath = _owningLibrary.isTest
        ? "${root.rootPath}/test/src/${owner.name}/${_name}.dart"
        : "${root.rootPath}/lib/src/${owner.name}/${_name}.dart";
    mergeWithDartFile('${chomp(_content)}\n', _filePath);
  }

  get _owningLibrary => owner as Library;

  bool get hasCtorSansNew =>
      _hasCtorSansNew == null ? owner.hasCtorSansNew : _hasCtorSansNew;

  get _content => br([
    brCompact([doc != null ? docComment(chomp(doc)) : null, _part]),
    brCompact(_enums),
    brCompact(_classes),
    _custom,
    brCompact(_variables),
  ]);

  get _part => 'part of ${owner.qualifiedName};\n';
  get _enums => enums.map((e) => '${chomp(e.define())}\n').join('\n');
  get _classes => classes.map((c) => '${chomp(c.define())}').join('\n\n');

  /// TODO: deprecated - use includesCustom
  set includeCustom(bool ic) => includesCustom = ic;
  get _custom => chomp(taggedBlockText('part $name'));
  get _variables => variables.map((v) => chomp(v.define())).join('\n');

  // end <class Part>

  final Id _id;
  String _name;
  String _filePath;
  Access _defaultMemberAccess;
  bool _hasCtorSansNew;
}

// custom <part part>
// end <part part>
