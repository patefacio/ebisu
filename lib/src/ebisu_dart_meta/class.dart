part of ebisu.ebisu_dart_meta;

enum CtorArgComposition { standardMembers, namedMembers, positionalMembers }

/// When serializing json, how to name the keys
enum JsonKeyFormat { camel, capCamel, snake }

/// Select various styles for default generated ctor.
///
/// - [ requiredParms ]: Default ctor with all members required
///
/// - [ namedParms ]: Default ctor with all members optional named parms
///
/// - [ positionalParms ]: Default ctor with all members optional positional parms
///
///
enum DefaultCtorStyle { requiredParms, namedParms, positionalParms }

/// Convenient access to DefaultCtorStyle.requiredParms with *requiredParms* see [DefaultCtorStyle].
///
const DefaultCtorStyle requiredParms = DefaultCtorStyle.requiredParms;

/// Convenient access to DefaultCtorStyle.namedParms with *namedParms* see [DefaultCtorStyle].
///
const DefaultCtorStyle namedParms = DefaultCtorStyle.namedParms;

/// Convenient access to DefaultCtorStyle.positionalParms with *positionalParms* see [DefaultCtorStyle].
///
const DefaultCtorStyle positionalParms = DefaultCtorStyle.positionalParms;

/// Metadata associated with a constructor
class Ctor extends Object with CustomCodeBlock {
  /// Name of the class of this ctor.
  String className;

  /// Name of the ctor. If 'default' generated as name of class, otherwise as CLASS.NAME()
  String name;

  /// List of members initialized in this ctor
  List<Member> members = [];

  /// List of optional members initialized in this ctor (i.e. those in [])
  List<Member> optMembers = [];

  /// List of optional members initialized in this ctor (i.e. those in {})
  List<Member> namedMembers = [];

  /// Parms that come before member parms
  List<String> frontParms = [];

  /// Parms that come after all member parms
  List<String> backParms = [];

  /// Arguments to super ctor invocation - List<String> or Map<String,String>
  dynamic superArgs = [];

  /// If true includes custom block for additional user supplied ctor code
  bool hasCustom = false;

  /// True if the variable is const
  bool isConst = false;

  /// If true implementation is `=> _init()`
  bool callsInit = false;

  // custom <class Ctor>

  Ctor();

  String get qualifiedName =>
      (name == 'default' || name == '') ? className : '${className}.${name}';

  get classId => idFromString(className);
  get _hasMembers => members.isNotEmpty;
  get _hasOptMembers => optMembers.isNotEmpty;
  get _hasNamedMembers => namedMembers.isNotEmpty;

  get id => (name == 'default' || name == '')
      ? classId
      : ((name == '_default')
          ? idFromString('${classId.snake}_default')
          : new Id('${classId.snake}_${idFromString(name).snake}'));

  get _optionalMembersDecl => _hasOptMembers
      ? brCompact([
          '[',
          concat([optMembers.map((m) => m.annotatedPublic), backParms])
              .join(','),
          ']',
        ])
      : '';

  get _namedMembersDecl => _hasNamedMembers
      ? brCompact([
          '{',
          concat([namedMembers.map((m) => m.annotatedPublic), backParms])
              .join(','),
          '}',
        ])
      : '';

  String get ctorSansNew => brCompact([
        '/// Create $className without new, for more declarative construction',
        '$className ${classId.camel} (',
        [
          concat([frontParms, members.map((m) => m.annotatedPublic)]).join(','),
          _optionalMembersDecl,
          _namedMembersDecl,
        ].where((part) => part.isNotEmpty).join(','),
        ') => new $qualifiedName(',
        concat([
          frontParms.map(_parmArgName),
          concat([members, optMembers, namedMembers]).map(
              (m) => namedMembers.contains(m) ? '${m.name}:${m.name}' : m.name),
          backParms.map(_parmArgName),
        ]).join(', '),
        ');'
      ]);

  get _memberSig => brCompact([
        '(',
        concat([frontParms, members.map((m) => 'this.${m.varName}'), backParms])
            .join(', '),
        ')',
        superArgs.isNotEmpty ? ': super(${superArgs.join(", ")})' : null,
      ]);

  get _assignMemberVars => brCompact(concat([members, optMembers, namedMembers])
      .where((m) =>
          m.ctorInit != null || (namedMembers.contains(m) && !m.isPublic))
      .map(_assignMemberVar)
      .join(','));

  _assignMemberVar(m) => brCompact([
        '${m.varName} = ${m.name}',
        (m.ctorInit != null) ? ' ?? ${m.ctorInit}' : null
      ]);

  _memberParm(m) {
    return m.ctorInit == null ? 'this.${m.varName}' : m.name;
  }

  get _superArgsTransformed =>
      superArgs is List? 'super(${superArgs.join(", ")})' :
      superArgs is Map? 'super(${superArgs.values.join(", ")})' :
      throw 'superArgs must be List<String> or Map<String,String>';

  get _superArgsAndAssignments {
    var memberAssignments = _assignMemberVars;
    List result = [];
    if (superArgs.isNotEmpty) {
      result.add(_superArgsTransformed);
    }
    if (memberAssignments.isNotEmpty) {
      result.add(memberAssignments);
    }
    return result.isEmpty ? '' : ':' + result.join(', ');
  }

  get _optMemberSig {
    return brCompact([
      '(',
      concat([
        /// include front parms
        frontParms,

        /// include regular members
        members.map(_memberParm),

        /// include optional members[
        [
          brCompact([
            /// open optionals
            '[',

            /// opt parms plus back parms
            concat([optMembers.map(_memberParm), backParms]).join(','),

            /// close optionals
            ']'
          ])
        ]
      ]).join(', '),
      ')',
      _superArgsAndAssignments
    ]);
  }

  get _namedMemberSig {
    return brCompact([
      '(',
      concat([
        /// include front parms
        frontParms,

        /// include regular members
        members.map(_memberParm),

        /// include optional members[
        [
          brCompact([
            /// open named
            '{',

            /// named parms plus back parms
            concat([
              namedMembers.map((m) => !m.isPublic ? m.name : _memberParm(m)),
              backParms
            ]).join(','),

            /// close named
            '}'
          ])
        ]
      ]).join(', '),
      ')',
      _superArgsAndAssignments
    ]);
  }

  get _ctorSig => brCompact([
        _hasOptMembers
            ? _optMemberSig
            : _hasNamedMembers ? _namedMemberSig : _memberSig,
      ]);

  get hasContent => hasCustom || super.hasContent;

  String get ctorText {
    String body = callsInit
        ? ' { _init(); }'
        : (isConst || !hasContent)
            ? ';'
            : '''{
$blockText
}''';

    return brCompact(
        [isConst && !callsInit ? 'const' : '', qualifiedName, _ctorSig, body]);
  }

  // end <class Ctor>

}

/// Metadata associated with a member of a Dart class
class Member extends Object with Entity {
  Member(this._id);

  /// Id for this class member
  Id get id => _id;

  /// Type of the member
  String type = 'String';

  /// Access level supported for this member
  set access(Access access) => _access = access;

  /// If provided the member will be initialized with value.
  /// The type of the member can be inferred from the type
  /// of this value.  Member type is defaulted to String. If
  /// the type of init is a String and type of the
  /// member is String, the text will be quoted if it is not
  /// already. If the type of init is other than string
  /// and the type of member is String (which is default)
  /// the type of member will be set to
  /// init.runtimeType.
  set init(dynamic init) => _init = init;

  /// If provided the member will be initialized to this text in generated
  /// ctor initializers. If this is null defaulted ctor args will be
  /// initialized to [init].
  set ctorInit(String ctorInit) => _ctorInit = ctorInit;

  /// List of ctor names to include this member in
  List<String> ctors = [];

  /// List of ctor names to include this member in as optional parameter
  List<String> ctorsOpt = [];

  /// List of ctor names to include this member in as named optional parameter
  List<String> ctorsNamed = [];

  /// True if the member is final
  bool isFinal = false;

  /// True if the member is const
  bool isConst = false;

  /// True if the member is static
  bool isStatic = false;

  /// True if the member should not be serialized if the parent class has hasJsonSupport
  bool isJsonTransient = false;

  /// If true annotated with observable
  bool isObservable = false;

  /// If true and member is in class that is comparable, it will be included in compareTo method
  bool isInComparable = true;

  /// If true and class hashCode this member will be included in the hashCode
  bool isInHashCode = true;

  /// Name of variable for the member, excluding access prefix (i.e. no '_')
  String get name => _name;

  /// Name of variable for the member - varies depending on public/private
  String get varName => _varName;

  // custom <class Member>

  /// [Member] has no children
  Iterable<Entity> get children => new Iterable<Entity>.generate(0);

  bool get isPublic => access == Access.RW;

  get access =>
      _access ?? owner?.defaultMemberAccess ?? ebisuDefaultMemberAccess;

  bool get isMap => isMapType(type);
  bool get isList => isListType(type);
  bool get isMapOrList => isMap || isList;

  @deprecated
  get classInit => init;

  @deprecated
  set classInit(classInit) => _init = classInit;

  get ctorInit => _ctorInit ?? init;

  get init => _init;

  onOwnershipEstablished() {
    _name = id.camel;
    if (type == 'String' && (init != null) && (init is! String)) {
      type = '${init.runtimeType}';
      if (type.contains('LinkedHashMap')) type = 'Map';
    }
    _varName = isPublic ? _name : "_$_name";
  }

  bool get hasGetter => !isPublic && access == RO;
  bool get hasSetter => !isPublic && access == WO;

  bool get hasPublicCode => isPublic || hasGetter || hasSetter;
  bool get hasPrivateCode => !isPublic;

  String get finalDecl => isFinal ? 'final ' : '';
  String get observableDecl => isObservable ? '@observable ' : '';
  String get staticDecl => isStatic ? 'static ' : '';
  bool get _ignoreinit =>
      (owner as Class).nonTransientMembers.every((m) => m.isFinal) &&
      (owner as Class).hasCourtesyCtor &&
      !isJsonTransient;

  /// returns the member annotated, suitable for decl or parm in function
  String get annotated =>
      '${observableDecl}${staticDecl}${finalDecl}${type} ${varName}';

  /// returns the member annotated named without private
  String get annotatedPublic =>
      '${observableDecl}${staticDecl}${finalDecl}${type} ${name}';

  /// returns the declaration
  String get decl => brCompact([
        annotated,
        (_ignoreinit || init == null)
            ? ';'
            : (type == 'String') ? ' = ${smartQuote(init)};' : ' = $init;'
      ]);

  String get publicCode => brCompact([
        this.docComment,
        hasGetter ? '$type get $name => $varName;' : '',
        hasSetter ? 'set $name($type $name) => $varName = $name;' : '',
        isPublic ? decl : ''
      ]);

  String get privateCode {
    var result = [];
    if (doc != null && !hasPublicCode)
      result.add('${dartComment(rightTrim(doc))}');
    if (!isPublic) result.add(decl);
    return result.join('\n');
  }

  // end <class Member>

  final Id _id;
  Access _access;
  dynamic _init;
  String _ctorInit;
  String _name;
  String _varName;
}

/// Metadata associated with a Dart class
///
/// A class consists primarily of its [members], but other niceties are provided.
///
/// For example:
///
///       print(dartFormat(
///               (class_('pair')
///                   ..members = [
///                     member('a'),
///                     member('b'),
///                   ])
///               .definition));
///
/// Prints:
///
///     class Pair {
///       String a;
///       String b;
///
///       // custom <class Pair>
///       // end <class Pair>
///     }
///
/// Note by default a custom block is provided since most classes have behavior -
/// i.e. are more than just *plain old data*. To exclude the custom block set
/// *includeCustom* to false.
///
///       print(dartFormat(
///               (class_('pair')
///                   ..includeCustom = false
///                   ..members = [
///                     member('a'),
///                     member('b'),
///                   ])
///               .definition));
///
/// Prints:
///
///         class Pair {
///           String a;
///           String b;
///         }
///
/// Dart classes may extend another class:
///
///       print(dartFormat(
///               (class_('a')..extend = 'B')
///               .definition));
///
/// Prints:
///
///     class A extends B {
///       // custom <class A>
///       // end <class A>
///     }
///
/// Dart classes may implement interfaces:
///
///       print(dartFormat(
///               (class_('a')..implement = [ 'B', 'C' ])
///               .definition));
///
/// Prints:
///
///     class A implements B, C {
///       // custom <class A>
///       // end <class A>
///     }
///
/// Note the tense of the attributes *extend* and *implement* avoids the *s* at the
/// end and therefore conflicts with keywords. That may take getting used to.
///
/// Dart classes may include *mixins*:
///
///       print(dartFormat(
///               (class_('a')
///                   ..extend = 'Base'
///                   ..mixins = [ 'B', 'C' ]
///                   ..implement = [ 'D', 'E' ]
///                )
///               .definition));
///
/// Prints:
///
///     class A extends Base with B, C implements D, E {
///
///       // custom <class A>
///       // end <class A>
///
///     }
///
/// Dart classes may be abstract:
///
///       print(dartFormat(
///               (class_('a')..isAbstract = true)
///               .definition));
///
/// Prints:
///
///     abstract class A {
///       // custom <class A>
///       // end <class A>
///     }
class Class extends Object with CustomCodeBlock, Entity {
  /// Id for this Dart class
  Id get id => _id;

  /// True if Dart class is public.
  /// Code generation support will prefix private variables appropriately
  bool isPublic = true;

  /// List of mixins
  List<String> mixins = [];

  /// List of class annotations
  List<Annotation> annotations = [];

  /// Any extends (NOTE extend not extends) declaration for the class - conflicts with mixin
  String extend;

  /// Any implements (NOTE implement not implements)
  List<String> implement = [];

  /// Default access for members
  set defaultMemberAccess(Access defaultMemberAccess) =>
      _defaultMemberAccess = defaultMemberAccess;

  /// List of members of this class
  List<Member> members = [];

  /// List of ctors requiring custom block
  List<String> ctorCustoms = [];

  /// List of ctors that should be const
  List<String> ctorConst = [];

  /// List of ctors of this class
  Map<String, Ctor> get ctors => _ctors;

  /// If true, class is abstract
  bool isAbstract = false;

  /// If true, generate toJson/fromJson on all members that are not isJsonTransient
  set hasJsonSupport(bool hasJsonSupport) => _hasJsonSupport = hasJsonSupport;

  /// If true, generate randJson function
  bool hasRandJson = false;

  /// If true, generate operator== using all members
  set hasOpEquals(bool hasOpEquals) => _hasOpEquals = hasOpEquals;

  /// If true, generate `operator==` using all members.
  ///
  /// Rather than type the argument to the method the argument is untyped (`bool
  /// operator==(value)`) but a runtimeType comparison is made. This allows types in a
  /// hierarchy to be compared without exceptions in checked mode.
  ///
  /// Note: Since this only provides different *specialized* implementation for
  /// `operator==` hasOpEquals returns true if either [hasOpEquals] or
  /// `_hasUntypedOpEquals` is true.
  bool hasUntypedOpEquals = false;

  /// If true, implements comparable
  bool isComparable = false;

  /// If true, implements comparable with runtimeType check followed by rest
  bool isPolymorphicComparable = false;

  /// Specifies style of default ctor.
  ///
  /// null implies no generated default ctor
  ///
  DefaultCtorStyle defaultCtorStyle;

  /// If true adds sets all members to final
  bool allMembersFinal = false;

  /// If true adds empty default ctor
  bool hasDefaultCtor = false;

  /// If true sets allMembersFinal and hasDefaultCtor to true
  bool isImmutable = false;

  /// If true creates library functions to construct forwarding to ctors
  set hasCtorSansNew(bool hasCtorSansNew) => _hasCtorSansNew = hasCtorSansNew;

  /// If true includes a copy function
  bool isCopyable = false;

  /// Name of the class - sans any access prefix (i.e. no '_')
  String get name => _name;

  /// Name of the class, including access prefix
  String get className => _className;

  /// Additional code included in the class near the top
  String topInjection;

  /// Additional code included in the class near the bottom
  String bottomInjection;

  /// If true includes a ${className}Builder class
  bool hasBuilder = false;

  /// If true includes a toString() => prettyJsonMap(toJson())
  bool hasJsonToString = false;

  /// If true adds transient hash code and caches the has on first call
  bool cacheHash = false;

  /// If true hasCourtesyCtor is `=> _init()`
  bool ctorCallsInit = false;

  /// When serializing json, how to format the keys
  JsonKeyFormat jsonKeyFormat;

  // custom <class Class>

  Class(this._id) {
    _name = id.capCamel;
    includesProtectBlock = true;
  }

  Iterable<Entity> get children => concat([members]);

  withClass(f(Class c)) => f(this);

  withCtor(ctorName, f(Ctor ctor)) =>
      f(_ctors.putIfAbsent(ctorName, () => new Ctor())..name = ctorName);

  withDefaultCtor(f(Ctor ctor)) => withCtor('', f);

  tagCtor(String ctorName, String tag) =>
      withCtor(ctorName, ((ctor) => ctor.tag = tag));

  /// *Deprecated* If true adds '..ctors[''] to all members (i.e. ensures
  /// generation of empty ctor with all members passed as arguments)
  @deprecated
  bool get hasCourtesyCtor => defaultCtorStyle != null;

  /// *Deprecated* If set to true adds default ctor with style requiredParms
  @deprecated
  set hasCourtesyCtor(bool hasCourtesyCtor) => defaultCtorStyle = requiredParms;

  bool get hasCtorSansNew => _hasCtorSansNew == null
      ? ((owner is Library) ? (owner as Library).hasCtorSansNew : false)
      : _hasCtorSansNew;

  bool get hasJsonSupport =>
      _hasJsonSupport || hasJsonToString || jsonKeyFormat != null;

  bool get hasOpEquals => _hasOpEquals || hasUntypedOpEquals;

  List<Member> get publicMembers =>
      members.where((member) => member.isPublic).toList();

  List<Member> get privateMembers =>
      members.where((member) => !member.isPublic).toList();

  List<Member> get nonStaticMembers =>
      members.where((member) => !member.isStatic).toList();

  List<Member> get nonTransientMembers =>
      nonStaticMembers.where((member) => !member.isJsonTransient).toList();

  List<Member> get hashableMembers => nonStaticMembers
      .where((member) => !member.isJsonTransient && member.isInHashCode)
      .toList();

  List<Member> get transientMembers =>
      nonStaticMembers.where((member) => member.isJsonTransient).toList();

  List<Ctor> get publicCtors => ctors.keys
      .where((String name) => name.length == 0 || name[0] != '_')
      .map((String name) => ctors[name])
      .toList();

  bool get requiresEqualityHelpers =>
      hasOpEquals && members.any((m) => m.isMapOrList);

  String get jsonCtor {
    if (hasCourtesyCtor) {
      return '''
return new ${_className}._fromJsonMapImpl(json);''';
    } else if (_ctors.containsKey('_default')) {
      return '''
return new ${_className}._default()
  .._fromJsonMapImpl(json);''';
    } else {
      return '''
return new ${_className}()
  .._fromJsonMapImpl(json);''';
    }
  }

  static String memberCompare(m) {
    final myName = m.varName == 'other' ? 'this.other' : m.varName;
    final otherName = 'other.${m.varName}';
    if (m.type.startsWith('List')) {
      return '  const ListEquality().equals($myName, $otherName)';
    } else if (m.type.startsWith('Map')) {
      return '  const MapEquality().equals($myName, $otherName)';
    } else {
      return '  $myName == $otherName';
    }
  }

  String get overrideHashCode {
    String result;
    var parts = [];
    parts.addAll(hashableMembers.map((Member m) {
      if (m.isList) {
        return 'const ListEquality<${jsonListValueType(m.type)}>().hash(${m.varName})';
      } else if (m.isMap) {
        return 'const MapEquality().hash(${m.varName})';
      } else {
        return '${m.varName}';
      }
    }));

    int numMembers = hashableMembers.length;
    if (numMembers == 1) {
      result = '${parts.first}.hashCode';
    } else if (numMembers == 2) {
      result = 'hash2(${parts.join(r", ")})';
    } else if (numMembers == 3) {
      result = 'hash3(${parts.join(r", ")})';
    } else if (numMembers == 4) {
      result = 'hash4(${parts.join(",\n  ")})';
    } else {
      result = 'hashObjects([\n  ${parts.join(",\n  ")}])';
    }
    if (cacheHash) {
      result = '''
_hashCode != null? _hashCode :
  (_hashCode = $result)''';
    }
    return result;
  }

  String get hasOpEqualsMethod => hasUntypedOpEquals
      ? '''
bool operator==(other) =>
  identical(this, other) || (runtimeType == other.runtimeType &&
${nonTransientMembers
  .where((m) => m.id.id != 'hash_code')
  .map((m) => memberCompare(m))
    .join(' &&\n')});

int get hashCode => ${overrideHashCode};
'''
      : '''
bool operator==($_className other) =>
  identical(this, other) ||
${nonTransientMembers
  .where((m) => m.id.id != 'hash_code')
  .map((m) => memberCompare(m))
    .join(' &&\n')};

int get hashCode => ${overrideHashCode};
''';

  static final _simpleCopies = new Set.from(
      ['int', 'double', 'num', 'bool', 'String', 'DateTime', 'Date']);

  static _assignCopy(String type, String varname) {
    if (_simpleCopies.contains(type)) return varname;
    if (isMapType(type)) {
      return '''
valueApply($varname, (v) =>
  ${_assignCopy(jsonMapValueType(type), "v")})''';
    } else if (isSplayTreeSetType(type)) {
      final elementType = templateParameterType(type);
      //      return 'ebisu.deepCopySplayTreeSet($varname)';
      return '''
$varname == null? null :
  (new $type()
  ..addAll(${varname}.map((e) =>
    ${_assignCopy(elementType, "e")})))''';
    } else if (isSetType(type)) {
      final elementType = templateParameterType(type);
      //return 'ebisu.deepCopySet($varname)';
      return '''
$varname == null? null :
  (new Set.from(${varname}.map((e) =>
    ${_assignCopy(elementType, "e")})))''';
    } else if (isListType(type)) {
      final elementType = jsonListValueType(type);
      if (_simpleCopies.contains(elementType)) {
        return '$varname == null? null: new List.from($varname)';
      } else {
        return '''
$varname == null? null :
  (new List.from(${varname}.map((e) =>
    ${_assignCopy(elementType, "e")})))''';
      }
    }
    return '${varname} == null? null : ${varname}.copy()';
  }

  String get copyMethod {
    if (hasCourtesyCtor) {
      return 'copy() => new ${className}._copy(this);';
    } else {
      var terms = [];
      members.forEach((m) {
        final rhs = _assignCopy(m.type, m.varName);
        terms.add('\n  ..${m.varName} = $rhs');
      });
      var ctorName = hasDefaultCtor ? _className : '${_className}._default';
      return 'copy() => new ${ctorName}()${terms.join()};\n';
    }
  }

  String get _copyCtor => hasCourtesyCtor && (hasJsonSupport || isCopyable)
      ? indentBlock(
          '''
${className}._copy(${className} other) :
${
  indentBlock(members
    .map((m) => '${m.varName} = ${_assignCopy(m.type, "other.${m.varName}")}')
    .join(',\n'), '  ')
};
''',
          '  ')
      : '';

  String get comparableMethod {
    var comparableMembers = members.where((m) => m.isInComparable).toList();
    if (comparableMembers.any((m) => isListType(m.type) || isMapType(m.type))) {
      throw new ArgumentError(
          '$name can not have compareTo with list or map members');
    }
    if (comparableMembers.length == 1) {
      return '''
int compareTo($_className other) =>
  ${comparableMembers[0].varName}.compareTo(other.${comparableMembers[0].varName});
''';
    }
    var terms = [];
    comparableMembers.forEach((m) {
      terms.add('((result = ${m.varName}.compareTo(other.${m.varName})) == 0)');
    });
    final otherType = isPolymorphicComparable ? 'Object' : _className;
    return '''
int compareTo($otherType other) {
  int result = 0;
  ${terms.join(' &&\n  ')};
  return result;
}
''';
  }

  set includesProtectBlock(bool value) =>
      customCodeBlock.tag = value ? 'class $name' : null;

  get _defaultOwnerAccess {
    var ancestor = owner;
    while (ancestor != null) {
      final result = ancestor is Class
          ? (ancestor as Class).defaultMemberAccess
          : ancestor is Part
              ? (ancestor as Part).defaultMemberAccess
              : ancestor is Library
                  ? (ancestor as Library).defaultMemberAccess
                  : null;
      if (result != null) return result;
      ancestor = ancestor.owner;
    }
    return null;
  }

  get defaultMemberAccess {
    if (_defaultMemberAccess == null) {
      if (owner is Library) {
        return (owner as Library).defaultMemberAccess;
      } else if (owner is Part) {
        return (owner as Part).defaultMemberAccess;
      }
      return ebisuDefaultMemberAccess;
    }
    return _defaultMemberAccess;
  }

  onOwnershipEstablished() {
    _className = isPublic ? _name : "_$_name";

    if (hasDefaultCtor && hasCourtesyCtor) {
      throw new ArgumentError(
          '$_name can not have hasDefaultCtor and hasCourtesyCtor both set to true');
    }

    if (cacheHash) {
      members.add(member('hash_code')
        ..type = 'int'
        ..access = IA
        ..isInComparable = false
        ..isJsonTransient = true);
    }

    if (isImmutable) {
      hasCourtesyCtor = true;
      allMembersFinal = true;
    }

    if (hasDefaultCtor) _ctors.putIfAbsent('', () => new Ctor()..name = '');

    ctors.values.forEach((ctor) => ctor.className = _className);

    if (allMembersFinal) nonTransientMembers.forEach((m) => m.isFinal = true);

    if (isPolymorphicComparable) isComparable = true;

    if (isComparable) {
      if (isPolymorphicComparable) {
        implement.add('Comparable<Object>');
      } else {
        implement.add('Comparable<$_className>');
      }
    }

    members.forEach((m) => m.owner = this);
    _addMemberToDefaultCtor();

    // Iterate on all members and create the appropriate ctors
    members.forEach((m) {
      makeCtorName(ctorName) {
        if (ctorName == '') return '';
        bool isPrivate = ctorName.startsWith('_');
        if (isPrivate) {
          return '_${idFromString(ctorName.substring(1)).camel}';
        } else {
          return idFromString(ctorName).camel;
        }
      }

      addCtor(ctorName) {
        var ctor = ctors[ctorName];
        if (ctor == null) {
          ctor = new Ctor()
            ..name = ctorName
            ..hasCustom = ctorCustoms.contains(ctorName)
            ..isConst = ctorConst.contains(ctorName)
            ..className = _className;

          if (ctor.hasContent && ctor.tag == null) {
            ctor.tag = _className;
          }

          ctors[ctorName] = ctor;
        }
        return ctor;
      }

      m.ctors.forEach(
          (ctorName) => addCtor(makeCtorName(ctorName))..members.add(m));

      m.ctorsOpt.forEach(
          (ctorName) => addCtor(makeCtorName(ctorName))..optMembers.add(m));

      m.ctorsNamed.forEach(
          (ctorName) => addCtor(makeCtorName(ctorName))..namedMembers.add(m));
    });

    // To deserialize or copy a default ctor is needed
    if (_hasPrivateDefaultCtor) {
      _ctors.putIfAbsent('_default', () => new Ctor())
        ..name = '_default'
        ..className = _name;
    }

    if (hasCourtesyCtor && allMembersFinal && transientMembers.length == 0) {
      _ctors[''].isConst = true;
    }

    if (ctorCallsInit) {
      _ctors[''].callsInit = true;
    }
  }

  _addMemberToDefaultCtor() {
    /// Get iterator of the eligible members
    defaultCtorParms() =>
        members.where((m) => !m.ctors.contains('') && !m.isJsonTransient);

    switch (defaultCtorStyle) {
      case requiredParms:
        {
          defaultCtorParms().forEach((m) => m.ctors.add(''));
        }
        break;

      case namedParms:
        {
          defaultCtorParms().forEach((m) => m.ctorsNamed.add(''));
        }
        break;
      case positionalParms:
        {
          defaultCtorParms().forEach((m) => m.ctorsOpt.add(''));
        }
        break;
    }
  }

  bool get _hasPrivateDefaultCtor =>
      (!hasCourtesyCtor && (isCopyable || hasJsonSupport)) && !hasDefaultCtor;

  List get orderedCtors {
    var keys = _ctors.keys.toList();
    bool hasDefault = keys.remove('');
    var privates = keys.where((k) => k[0] == '_').toList();
    var publics = keys.where((k) => k[0] != '_').toList();
    privates.sort();
    publics.sort();
    var result = new List.from(publics)..addAll(privates);
    if (hasDefault) {
      result.insert(0, '');
    }
    return result;
  }

  String get implementsClause {
    if (implement.length > 0) {
      return '\n  implements ${implement.join(',\n    ')} ';
    } else {
      return ' ';
    }
  }

  static String _fromJsonData(String type, String source) {
    if (isClassJsonable(type)) {
      return '${type}.fromJson($source)';
    } else if (type == 'DateTime') {
      return 'DateTime.parse($source)';
    }
    return source;
  }

  String _fromJsonMapMember(Member member, [String source = 'jsonMap']) {
    String result;
    var lhs = '${member.varName}';
    var key = '"${_formattedMember(member)}"';
    var value = '$source[$key]';

    if (isClassJsonable(member.type)) {
      result = '$lhs = ${member.type}.fromJson($value)';
    } else {
      if (isMapType(member.type)) {
        final keyType = generalMapKeyType(member.type);
        final convertKey = keyType == 'String'
            ? ''
            : ',\n    (key) => $keyType.fromString(key)';

        result = '''
// ${member.name} is ${member.type}
$lhs = ebisu
  .constructMapFromJsonData(
    $value,
    (value) => ${_fromJsonData(jsonMapValueType(member.type), 'value')}$convertKey)
''';
      } else if (isListType(member.type)) {
        result = '''
// ${member.name} is ${member.type}
$lhs = ebisu
  .constructListFromJsonData($value,
                             (data) => ${_fromJsonData(jsonListValueType(member.type), 'data')})
''';
      } else {
        result = '$lhs = $value';
      }
    }
    return result;
  }

  String fromJsonMapImpl() => hasCourtesyCtor
      ? '''
$className._fromJsonMapImpl(Map jsonMap) :
${
   chomp(indentBlock(
     members
       .where((m) => !m.isJsonTransient)
       .map((m) => chomp(_fromJsonMapMember(m)))
       .join(',\n')))};
'''
      : '''
void _fromJsonMapImpl(Map jsonMap) {
${
   indentBlock(
     members
       .where((m) => !m.isJsonTransient)
       .map((m) => _fromJsonMapMember(m))
       .join(';\n'))};
}''';

  get definition => define();

  String define() {
    if (owner == null) owner = library('stub');
    return _content;
  }

  dynamic noSuchMethod(Invocation msg) {
    throw new ArgumentError("Class does not support ${msg.memberName}");
  }

  bool get _isComparable => isPolymorphicComparable || isComparable;

  get _content => br([
        brCompact([this.docComment, _classOpener]),
        _orderedCtors,
        _opEquals,
        _comparable,
        _copyable,
        _memberPublicCode,
        _topInjection,
        _includedCustom,
        _jsonToString,
        _jsonSerialization,
        _copyCtor,
        _randJson,
        _memberPrivateCode,
        _bottomInjection,
        _classCloser,
        _ctorSansNewImpl,
        _builderClass,
      ].where((line) => line != ''));

  get _abstractTag => isAbstract ? 'abstract ' : '';
  get _annotationTxt => brCompact(annotations);
  get _classOpener => '$_annotationTxt$_classWithExtends${implementsClause}{';
  get _extendClass => (mixins.length > 0 && extend == null) ? 'Object' : extend;
  get _classWithExtends => mixins.length > 0
      ? ('''
${_abstractTag}class $className extends $_extendClass with ${mixins.join(', ')}''')
      : (extend != null
          ? '${_abstractTag}class $className extends $extend'
          : '${_abstractTag}class $className');
  get _orderedCtors =>
      orderedCtors.map((c) => indentBlock(ctors[c].ctorText)).join('\n');
  get _opEquals => hasOpEquals ? indentBlock(hasOpEqualsMethod) : '';
  get _comparable => _isComparable ? indentBlock(comparableMethod) : '';
  get _copyable => isCopyable ? indentBlock(copyMethod) : '';
  get _memberPublicCode => members
      .where((m) => m.hasPublicCode)
      .map((m) => indentBlock(chomp(m.publicCode)))
      .join('\n');
  get _topInjection => topInjection != null ? indentBlock(topInjection) : '';

  get _includedCustom => indentBlock(blockText);

  _formattedMember(Member m) => jsonKeyFormat == snake
      ? m.id.snake
      : jsonKeyFormat == capCamel
          ? m.id.capCamel
          : jsonKeyFormat == camel ? m.id.camel : m.id.camel;

  get _jsonMembers => members
      .where((m) => !m.isJsonTransient)
      .map((m) =>
          '"${_formattedMember(m)}": ebisu.toJson(${m.hasGetter? m.name : m.varName}),')
      .join('\n');

  get _jsonExtend => extend != null
      ? indentBlock('\n"$extend": super.toJson()', '      ')
      : ((mixins.length > 0) ? '// TODO: consider mixin support' : '');

  get _jsonToString => hasJsonToString
      ? '''

  toString() => '(\${runtimeType}) => \${ebisu.prettyJsonMap(toJson())}';
'''
      : '';

  get _jsonSerialization => hasJsonSupport
      ? '''

  Map toJson() => {
${indentBlock(_jsonMembers, '      ')}$_jsonExtend
  };

  static $name fromJson(Object json) {
    if(json == null) return null;
    if(json is String) {
      json = convert.JSON.decode(json);
    }
    assert(json is Map);
${indentBlock(jsonCtor, '    ')}
  }

${indentBlock(fromJsonMapImpl())}'''
      : '';
  get _randJson => hasRandJson
      ? ''' // TODO: randjson support
'''
      : '';

  get _memberPrivateCode => members
      .where((m) => m.hasPrivateCode)
      .map((m) => indentBlock(chomp(m.privateCode)))
      .join('\n');

  get _bottomInjection =>
      bottomInjection != null ? indentBlock(bottomInjection) : '';

  get _ctorSansNewImpl => hasCtorSansNew
      ? ((ctors.length > 0)
              ? publicCtors.map((ctor) => ctor.ctorSansNew).join('\n')
              : '${id.camel}() => new ${name}();') +
          '\n'
      : '';

  get _classCloser => '}\n';

  get _builderClass {
    if (hasBuilder) {
      final builderClass = class_('${id.snake}_builder')
        ..hasCtorSansNew = true
        ..hasDefaultCtor = true
        ..members = (members
            .map((m) => member(m.id.snake)
              ..type = m.type
              ..init = m.init)
            .toList())
        ..bottomInjection = '''
${className} buildInstance() => new ${className}(
${indentBlock(
formatFill(nonTransientMembers
           .map((m)=>m.varName)
           .join(',\n')
           .split('\n'), indent:''), '  ')});

factory ${className}Builder.copyFrom(${className} _) =>
  new ${className}Builder._copyImpl(_.copy());

${className}Builder._copyImpl(${className} _) :
  ${nonTransientMembers.map((m) => '${m.varName} = _.${m.varName}').join(',\n  ')};

''';
      return '${builderClass.define()}\n';
    }
    return '';
  }

  // end <class Class>

  final Id _id;
  Access _defaultMemberAccess;
  Map<String, Ctor> _ctors = {};
  bool _hasJsonSupport = false;
  bool _hasOpEquals = false;
  bool _hasCtorSansNew;
  String _name;
  String _className;
}

// custom <part class>

final snake = JsonKeyFormat.snake;
final capCamel = JsonKeyFormat.capCamel;
final camel = JsonKeyFormat.camel;

Access _ebisuDefaultMemberAccess = Access.RW;
Access get ebisuDefaultMemberAccess => _ebisuDefaultMemberAccess;
set ebisuDefaultMemberAccess(Access access) =>
    _ebisuDefaultMemberAccess = access;

final _ws = new RegExp(r'\s+');
_parmArgName(String s) => s.split(_ws).last;

// end <part class>
