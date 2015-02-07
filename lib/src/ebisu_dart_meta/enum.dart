part of ebisu.ebisu_dart_meta;

/// Define the id and value for an enum value
class EnumValue {
  EnumValue(this._id, this.value);

  /// Id for this enum_value
  Id get id => _id;
  /// User specified value for enum value
  var value;
  /// Documentation for this enum_value
  String doc;
  // custom <class EnumValue>

  get snake => _id.snake;
  get camel => _id.camel;
  get capCamel => _id.capCamel;
  get emacs => _id.emacs;
  get shout => _id.shout;

  toString() => 'EV($_id => $value)';

  // end <class EnumValue>
  final Id _id;
}

/// Create a EnumValue sans new, for more declarative construction
EnumValue enumValue([Id _id, var value]) => new EnumValue(_id, value);

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
  List<dynamic> values = [];
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
  /// If true scopes the enum values to library by assigning to var outside class
  bool libraryScopedValues = false;
  /// If true string value for each entry is snake case (default is shout)
  bool isSnakeString = false;
  /// Before true enum support enums were emulated with a class containing static
  /// consts. This had some unique features in terms of ability to generate json
  /// support as well as some custom functions. Setting this will ensure that
  /// a class is generated instead of the newer and generally preffered enum.
  set requiresClass(bool requiresClass) => _requiresClass = requiresClass;
  // custom <class Enum>

  set parent(p) {
    _name = _id.capCamel;
    _enumName = isPublic ? _name : "_$_name";
    for (int i = 0; i < values.length; i++) {
      if (values[i] is Id) {
        values[i] = new EnumValue(values[i], i);
      }
    }
    _parent = p;
  }

  String define() => _content;

  get requiresClass =>
      _requiresClass == null ? (jsonSupport || hasCustom) : _requiresClass;

  String valueAsString(value) => isSnakeString ? value.snake : value.capCamel;

  String valueId(EnumValue v) => requiresClass? v.shout : v.camel;

  get _content => br(requiresClass
      ? [
    _docComment,
    _enumClassBegin,
    _toString,
    _fromString,
    _toJson,
    _fromJson,
    _randJson,
    _custom,
    _enumClassEnd,
    _libraryScopedValues,
  ]
      : [
    _docComment,
    'enum $enumName {',
    values.map((v) => '  ${valueId(v)}').join(',\n'),
    '}',
    _libraryScopedValues,
  ]);

  get _docComment => doc != null ? docComment(doc) : '';
  get _enumEntries => values
      .map((v) => 'static const ${valueId(v)} = const $enumName._(${v.value});')
      .join('\n');
  get _enumValues => values.map((v) => v.shout).join(',\n  ');
  get _enumClassBegin => '''
class $enumName implements Comparable<$enumName> {
${indentBlock(_enumEntries)}

  static get values => [
  ${indentBlock(_enumValues)}
  ];

  final int value;

  int get hashCode => value;

  const $enumName._(this.value);

  copy() => this;

  int compareTo($enumName other) => value.compareTo(other.value);
''';

  get _toString => '''
  String toString() {
    switch(this) {
${
indentBlock(
  values.map((v) =>
    'case ${valueId(v)}: return "${valueAsString(v)}";').join('\n'), '      ')
}
    }
    return null;
  }
''';

  get _fromString => '''
  static $enumName fromString(String s) {
    if(s == null) return null;
    switch(s) {
${
indentBlock(
  values.map((v) =>
    'case "${valueAsString(v)}": return ${valueId(v)};').join('\n'), '      ')
}
      default: return null;
    }
  }
''';

  get _toJson => jsonSupport
      ? '''
  int toJson() => value;'''
      : '';

  get _fromJson => jsonSupport
      ? '''
  static $enumName fromJson(int v) {
    return v==null? null : values[v];
  }
'''
      : '';

  get _randJson => hasRandJson
      ? '''
  static String randJson() {
   return values[_randomJsonGenerator.nextInt(${values.length})].toString();
  }
'''
      : '';
  get _custom =>
      hasCustom ? rightTrim(indentBlock(customBlock("enum $name"))) : '';
  get _enumClassEnd => '}\n';
  get _libraryScopedValues => libraryScopedValues
      ? '''
${values.map((v) => 'const ${valueId(v)} = ${enumName}.${valueId(v)};').join('\n')}
'''
      : '';

  // end <class Enum>
  final Id _id;
  dynamic _parent;
  String _name;
  String _enumName;
  bool _requiresClass;
}
// custom <part enum>
// end <part enum>
