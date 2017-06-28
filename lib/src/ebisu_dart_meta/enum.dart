part of ebisu.ebisu_dart_meta;

enum LibraryScopedValuesCase { camelCase, capCamelCase, snakeCase, shoutCase }

/// Convenient access to LibraryScopedValuesCase.camelCase with *camelCase* see [LibraryScopedValuesCase].
///
const LibraryScopedValuesCase camelCase = LibraryScopedValuesCase.camelCase;

/// Convenient access to LibraryScopedValuesCase.capCamelCase with *capCamelCase* see [LibraryScopedValuesCase].
///
const LibraryScopedValuesCase capCamelCase =
    LibraryScopedValuesCase.capCamelCase;

/// Convenient access to LibraryScopedValuesCase.snakeCase with *snakeCase* see [LibraryScopedValuesCase].
///
const LibraryScopedValuesCase snakeCase = LibraryScopedValuesCase.snakeCase;

/// Convenient access to LibraryScopedValuesCase.shoutCase with *shoutCase* see [LibraryScopedValuesCase].
///
const LibraryScopedValuesCase shoutCase = LibraryScopedValuesCase.shoutCase;

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

  /// Returns the [Id] for this enum as snake case
  get snake => _id.snake;

  /// Returns the [Id] for this enum as camel case
  get camel => _id.camel;

  /// Returns the [Id] for this enum as cap camel case
  get capCamel => _id.capCamel;

  /// Returns the [Id] for this enum as emacs case
  get emacs => _id.emacs;

  /// Returns the [Id] for this enum as shout
  get shout => _id.shout;

  toString() => 'EV($_id => $value)';

  // end <class EnumValue>

  final Id _id;
}

/// Defines an enum.
///
/// There are two styles of generation - the language supplied and the original
/// *class* paradigm proposed prior to existance of language enums. See
/// (http://stackoverflow.com/questions/13899928/does-dart-support-enumerations).
///
/// One advantage of a class enum is there is capability to add functions and
/// enforce a transformation in the serialization. For instance, you might want the
/// values to be serialized as the int value or as the string name for
/// legibility.
///
///     final colorEnum = enum_('rgb')
///       ..doc = 'Colors'
///       ..setAsRoot()
///       ..values = [
///         'red',
///         'green',
///         'blue'
///       ];
///     print(colorEnum.define());
///
/// Prints:
///
///     /// Colors
///     enum Rgb {
///     red,
///     green,
///     blue
///     }
class Enum extends Object with Entity {
  /// Id for this enum
  Id get id => _id;

  /// True if enum is public.
  /// Code generation support will prefix private variables appropriately
  bool isPublic = true;

  /// List of id's naming the values
  List<EnumValue> get values => _values;

  /// If true, generate toJson/fromJson on wrapper class
  bool hasJsonSupport = false;

  /// If true, generate randJson
  bool hasRandJson = false;

  /// Name of the enum class generated sans access prefix
  String get name => _name;

  /// Name of the enum class generated with access prefix
  String get enumName => _enumName;

  /// If true includes custom block for additional user supplied ctor code
  bool hasCustom = false;

  /// If true scopes the enum values to library by assigning to var outside class
  set hasLibraryScopedValues(bool hasLibraryScopedValues) =>
      _hasLibraryScopedValues = hasLibraryScopedValues;

  /// If set, hasLibraryScopedValues assumed true and values named accordingly
  LibraryScopedValuesCase libraryScopedValuesCase;

  /// If true string value for each entry is snake case
  bool isSnakeString = false;

  /// If true string value for each entry is shout
  bool isShoutString = false;

  /// Before true enum support enums were emulated with a class containing static
  /// consts. This had some unique features in terms of ability to generate json
  /// support as well as some custom functions. Setting this will ensure that
  /// a class is generated instead of the newer and generally preffered enum.
  set requiresClass(bool requiresClass) => _requiresClass = requiresClass;

  // custom <class Enum>

  Enum(this._id) {
    _name = id.capCamel;
    _enumName = isPublic ? _name : "_$_name";
  }

  /// Enum has no children
  Iterable<Entity> get children => new Iterable<Entity>.generate(0);

  get hasLibraryScopedValues =>
      libraryScopedValuesCase != null ? true : _hasLibraryScopedValues ?? false;

  /// Setting of values accepts [ (String|Id|EnumValue),... ]

  _evCheckValue(EnumValue ev, int index) =>
      ev.value == null ? ((new EnumValue(ev.id, index))..doc = ev.doc) : ev;

  set values(Iterable values) => _values = enumerate(values)
      .map((IndexedValue iv) => iv.value is String
          ? new EnumValue(idFromString(iv.value), iv.index)
          : iv.value is Id
              ? new EnumValue(iv.value, iv.index)
              : (iv.value is EnumValue)
                  ? _evCheckValue(iv.value, iv.index)
                  : throw '${iv.value} not valid type for enum value')
      .toList();

  onOwnershipEstablished() {
    values = _values;
  }

  /// Returns the enum definition
  String define() => _content;

  /// Returns true if this enum should use old-style class idiom for similar
  /// supporting the enumeration type. Using a class to get the same effect can
  /// be helpful in cases where you want to provide additional functionality,
  /// like json support, or custom methods on the enumeration type.
  get requiresClass =>
      _requiresClass == null ? (hasJsonSupport || hasCustom) : _requiresClass;

  String valueAsString(value) => isShoutString
      ? value.shout
      : isSnakeString ? value.snake : value.capCamel;

  String casedName(EnumValue v) =>
      libraryScopedValuesCase == camelCase
          ? v.id.camel
          : libraryScopedValuesCase == capCamelCase
              ? v.id.capCamel
              : libraryScopedValuesCase == shoutCase
                  ? v.id.shout
                  : libraryScopedValuesCase == snakeCase
                      ? v.id.snake
                      : throw new ArgumentError(
                          "Invalid case type ${libraryScopedValuesCase}");

  String valueId(EnumValue v) => requiresClass ? v.shout : v.camel;

  String libraryValueId(EnumValue v) => libraryScopedValuesCase != null
      ? casedName(v)
      : requiresClass ? v.shout : v.camel;

  String enumValueEntry(EnumValue v) => v.doc != null
      ? '''
${indentBlock(dartComment(v.doc))}
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

  get _docComment => doc != null ? dartComment(doc) : '';

  get _enumEntries => values
      .map((v) => brCompact([
            v.doc != null ? dartComment(v.doc) : '',
            'static const $enumName ${valueId(v)} = const $enumName._(${v.value});'
          ]))
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
  toJson() => toString();'''
      : '';

  get _fromJson => hasJsonSupport
      ? '''
  static $enumName fromJson(dynamic v) {
    return  (v is String)? fromString(v) : (v is int)? values[v] : v;
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
${chomp(dartComment(comment), true)}
const ${enumName} ${libraryValueId(v)} = ${enumName}.${valueId(v)};
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
  bool _hasLibraryScopedValues = false;
  bool _requiresClass;
}

// custom <part enum>

/// Create a EnumValue sans new, for more declarative construction
EnumValue enumValue(_id, [var value]) => new EnumValue(makeId(_id), value);

// end <part enum>
