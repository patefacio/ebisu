part of ebisu.ebisu_dart_meta;

class Variable {

  Variable(this._id);

  /// Id for this variable
  Id get id => _id;
  /// Documentation for this variable
  String doc;
  /// Reference to parent of this variable
  dynamic get parent => _parent;
  /// True if variable is public.
  /// Code generation support will prefix private variables appropriately
  bool isPublic = true;
  /// Type for the variable
  String type;
  /// Data used to initialize the variable
  /// If init is a String and type is not specified, [type] is a String
  ///
  /// member('foo')..init = 'goo' => String foo = "goo";
  ///
  /// If init is a String and type is specified, then:
  ///
  /// member('foo')..type = 'int'..init = 3
  ///   String foo = 3;
  /// member('foo')..type = 'DateTime'..init = 'new DateTime(1929, 10, 29)' =>
  ///   DateTime foo = new DateTime(1929, 10, 29);
  ///
  /// If init is not specified, it will be inferred from init if possible:
  ///
  /// member('foo')..init = 'goo'
  ///   String foo = "goo";
  /// member('foo')..init = 3
  ///   String foo = 3;
  /// member('foo')..init = [1,2,3]
  ///   Map foo = [1,2,3];
  dynamic init;
  /// True if the variable is final
  bool isFinal = false;
  /// True if the variable is const
  bool isConst = false;
  /// True if the variable is static
  bool isStatic = false;
  /// Name of the enum class generated sans access prefix
  String get name => _name;
  /// Name of variable - varies depending on public/private
  String get varName => _varName;

  // custom <class Variable>

  void set parent(p) {
    _name = id.camel;
    _varName = isPublic? _name : "_${_name}";
    if(type == null) {
      if((init != null) && (init is! String)) {
        type = '${init.runtimeType}';
        if(type == 'LinkedHashMap') type = 'Map';
      } else {
        type = 'String';
      }
    }

    _parent = p;
  }

  String define() => _content;

  get _content =>
    [
      _docComment,
      _init
    ]
    .where((line) => line != '')
    .join('\n');

  get _docComment => (doc != null)? rightTrim(docComment(doc)) : '';
  get _const => isConst? 'const ' : '';
  get _final => isFinal? 'final ' : '';
  get _uninitialized => '$type $varName;';
  get _initialized => '$type $varName = $_initVal;';
  get _initVal => type == 'String'? smartQuote(init) : init;
  get _init => '$_const$_final${init == null? _uninitialized : _initialized}';

  // end <class Variable>
  final Id _id;
  dynamic _parent;
  String _name;
  String _varName;
}
// custom <part variable>
// end <part variable>
