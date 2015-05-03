part of ebisu.ebisu_dart_meta;

/// Define the id and value for an enum value
///
class EnumValue {
  EnumValue(this._id, this.value);

  /// Id for this enum_value
  ///
  Id get id => _id;
  /// User specified value for enum value
  ///
  var value;
  /// Documentation for this enum_value
  ///
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

/// Defines an enum - to be generated idiomatically as a class
/// See (http://stackoverflow.com/questions/13899928/does-dart-support-enumerations)
/// At some point when true enums are provided this may be revisited.
///
class Enum extends Object with Entity {
  Enum(this._id);

  /// Id for this enum
  ///
  Id get id => _id;
  /// True if enum is public.
  /// Code generation support will prefix private variables appropriately
  ///
  bool isPublic = true;
  /// List of id's naming the values
  ///
  List<EnumValue> get values => _values;
  /// If true, generate toJson/fromJson on wrapper class
  ///
  bool hasJsonSupport = false;
  /// If true, generate randJson
  ///
  bool hasRandJson = false;
  /// Name of the enum class generated sans access prefix
  ///
  String get name => _name;
  /// Name of the enum class generated with access prefix
  ///
  String get enumName => _enumName;
  /// If true includes custom block for additional user supplied ctor code
  ///
  bool hasCustom = false;
  /// If true scopes the enum values to library by assigning to var outside class
  ///
  bool hasLibraryScopedValues = false;
  /// If true string value for each entry is snake case (default is shout)
  ///
  bool isSnakeString = false;
  /// Before true enum support enums were emulated with a class containing static
  /// consts. This had some unique features in terms of ability to generate json
  /// support as well as some custom functions. Setting this will ensure that
  /// a class is generated instead of the newer and generally preffered enum.
  ///
  set requiresClass(bool requiresClass) => _requiresClass = requiresClass;

  // custom <class Enum>

  /// Enum has no children
  Iterable<Entity> get children => new Iterable<Entity>.generate(0);

  /// Setting of values accepts [ (String|Id|EnumValue),... ]

  _evCheckValue(EnumValue ev, int index) =>
      ev.value == null ? ((new EnumValue(ev.id, index))..doc = ev.doc) : ev;

  set values(List values) =>
      _values =
      enumerate(values)
          .map((IndexedValue iv) => iv.value is String
              ? new EnumValue(idFromString(iv.value), iv.index)
              : iv.value is Id
                  ? new EnumValue(iv.value, iv.index)
                  : (iv.value is EnumValue)
                      ? _evCheckValue(iv.value, iv.index)
                      : throw '${iv.value} not valid type for enum value')
          .toList();

  onOwnershipEstablished() {
    _name = _id.capCamel;
    _enumName = isPublic ? _name : "_$_name";
    values = _values;
  }

  String define() => _content;

  get requiresClass =>
      _requiresClass == null ? (hasJsonSupport || hasCustom) : _requiresClass;

  String valueAsString(value) => isSnakeString ? value.snake : value.capCamel;

  String valueId(EnumValue v) => requiresClass ? v.shout : v.camel;

  String enumValueEntry(EnumValue v) => v.doc != null
      ? '''
${indentBlock(docComment(v.doc))}
${valueId(v)}'''
      : valueId(v);

  get _content => br(requiresClass
      ? [
    brCompact([chomp(_docComment), _enumClassBegin]),
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
    brCompact([
      _docComment,
      'enum $enumName {',
      combine(values.map((v) => enumValueEntry(v)), ',\n'),
      '}',
      _libraryScopedValues,
    ])
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

  get _toJson => hasJsonSupport
      ? '''
  int toJson() => value;'''
      : '';

  get _fromJson => hasJsonSupport
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

  _commentedEnumAlias(EnumValue v) {
    final userComment = v.doc == null ? '' : '\n${v.doc}\n';
    final comment = '''
Convenient access to ${enumName}.${valueId(v)} with *${valueId(v)}* see [${enumName}].
$userComment''';
    return '''
${chomp(docComment(comment), true)}
const ${enumName} ${valueId(v)} = ${enumName}.${valueId(v)};
''';
  }

  get _libraryScopedValues => hasLibraryScopedValues
      ? values.map((v) => _commentedEnumAlias(v)).join('\n')
      : '';

  // end <class Enum>

  final Id _id;
  List<EnumValue> _values = [];
  String _name;
  String _enumName;
  bool _requiresClass;
}

// custom <part enum>

/// Create a EnumValue sans new, for more declarative construction
EnumValue enumValue(_id, [var value]) => new EnumValue(makeId(_id), value);

// end <part enum>
