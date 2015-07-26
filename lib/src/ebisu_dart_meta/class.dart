part of ebisu.ebisu_dart_meta;

/// When serializing json, how to name the keys
enum JsonKeyFormat { camel, capCamel, snake }

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

  String get ctorSansNew {
    var classId = idFromString(className);
    var id = (name == 'default' || name == '')
        ? classId
        : ((name == '_default')
            ? idFromString('${classId.snake}_default')
            : new Id('${classId.snake}_${idFromString(name).snake}'));

    List<String> parms = [];
    List<String> args = [];
    if (members.length > 0) {
      List<String> required = [];
      members.forEach((m) => required.add('${m.type} ${m.varName}'));
      parms.add("${required.join(',\n')}");
      args.add(members.map((m) => '  ${m.varName}').join(',\n'));
    }
    if (optMembers.length > 0) {
      List<String> optional = [];
      optMembers.forEach((m) => optional.add('    ${m.type} ${m.varName}' +
          ((m.ctorInit == null) ? '' : ' = ${m.ctorInit}')));
      parms.add("  [\n${optional.join(',\n')}\n  ]");
      args.add(optMembers.map((m) => '  ${m.varName}').join(',\n'));
    }
    if (namedMembers.length > 0) {
      List<String> named = [];
      namedMembers.forEach((m) => named.add('    ${m.type} ${m.varName}' +
          ((m.ctorInit == null) ? '' : ' : ${m.ctorInit}')));
      parms.add("  {\n${named.join(',\n')}\n  }");
      args.add(
          namedMembers.map((m) => '  ${m.varName}:${m.varName}').join(',\n'));
    }
    String parmText = parms.join(',\n');
    String argText = args.join(',\n');
    bool hasParms = parms.length > 0;
    bool allowAllOptional = optMembers.length == 0 && namedMembers.length == 0;

    var lb = hasParms && allowAllOptional ? '[' : '';
    var rb = hasParms && allowAllOptional ? ']' : '';
    return '''
/// Create a ${className} sans new, for more declarative construction
${className}
${id.camel}($lb${leftTrim(chomp(indentBlock(parmText, '  ')))}$rb) =>
  new ${qualifiedName}(${leftTrim(chomp(indentBlock(argText, '    ')))});''';
  }

  String get ctorText {
    List<String> result = [];
    if (members.length > 0) {
      List<String> required = [];
      members.forEach((m) => required.add('this.${m.varName}'));
      result.addAll(prepJoin(required));
    }
    if (optMembers.length > 0) {
      if (result.length > 0) result[result.length - 1] += ',';
      result.add('[');
      List<String> optional = [];
      optMembers.forEach((m) => optional.add('this.${m.varName}' +
          ((m.ctorInit == null) ? '' : ' = ${m.ctorInit}')));
      result.addAll(prepJoin(optional));
      result.add(']');
    }
    if (namedMembers.length > 0) {
      if (result.length > 0) result[result.length - 1] += ',';
      result.add('{');
      List<String> named = [];
      namedMembers.forEach((m) => named.add('this.${m.varName}' +
          ((m.ctorInit == null) ? '' : ' : ${m.ctorInit}')));
      result.addAll(prepJoin(named));
      result.add('}');
    }

    String cb = hasCustom
        ? indentBlock(rightTrim(customBlock('${qualifiedName}')))
        : '';
    String constTag = isConst && !callsInit ? 'const ' : '';
    String body = callsInit
        ? ' { _init(); }'
        : (isConst || !hasCustom)
            ? ';'
            : ''' {
${chomp(cb, true)}
}''';

    List decl = [];
    var method = '${constTag}${qualifiedName}(';
    if (result.length > 0) {
      decl
        ..add('$method${result.removeAt(0)}')
        ..addAll(result);
    } else {
      decl.add(method);
    }

    return '''
${formatFill(decl)})${body}
''';
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
  Access access;
  /// If provided the member will be initialized with value.
  /// The type of the member can be inferred from the type
  /// of this value.  Member type is defaulted to String. If
  /// the type of classInit is a String and type of the
  /// member is String, the text will be quoted if it is not
  /// already. If the type of classInit is other than string
  /// and the type of member is String (which is default)
  /// the type of member will be set to
  /// classInit.runtimeType.
  dynamic classInit;
  /// If provided the member will be initialized to this
  /// text in generated ctor initializers
  String ctorInit;
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
  /// Name of variable for the member, excluding access prefix (i.e. no '_')
  String get name => _name;
  /// Name of variable for the member - varies depending on public/private
  String get varName => _varName;

  // custom <class Member>

  /// [Member] has no children
  Iterable<Entity> get children => new Iterable<Entity>.generate(0);

  bool get isPublic => access == Access.RW;

  bool get isMap => isMapType(type);
  bool get isList => isListType(type);
  bool get isMapOrList => isMap || isList;

  onOwnershipEstablished() {
    _name = id.camel;
    if (type == 'String' && (classInit != null) && (classInit is! String)) {
      type = '${classInit.runtimeType}';
      if (type.contains('LinkedHashMap')) type = 'Map';
    }
    if (access == null) access = Access.RW;
    _varName = isPublic ? _name : "_$_name";
  }

  bool get hasGetter => !isPublic && access == RO;
  bool get hasSetter => !isPublic && access == WO;

  bool get hasPublicCode => isPublic || hasGetter || hasSetter;
  bool get hasPrivateCode => !isPublic;

  String get finalDecl => isFinal ? 'final ' : '';
  String get observableDecl => isObservable ? '@observable ' : '';
  String get staticDecl => isStatic ? 'static ' : '';
  bool get _ignoreClassInit =>
      (owner as Class).nonTransientMembers.every((m) => m.isFinal) &&
          (owner as Class).hasCourtesyCtor &&
          !isJsonTransient;

  String get decl => (_ignoreClassInit || classInit == null)
      ? "${observableDecl}${staticDecl}${finalDecl}${type} ${varName};"
      : ((type == 'String')
          ? "${observableDecl}${staticDecl}${finalDecl}${type} ${varName} = ${smartQuote(classInit)};"
          : "${observableDecl}${staticDecl}${finalDecl}${type} ${varName} = ${classInit};");

  String get publicCode => brCompact([
    this.docComment,
    hasGetter ? '$type get $name => $varName;' : '',
    hasSetter ? 'set $name($type $name) => $varName = $name;' : '',
    isPublic ? decl : ''
  ]);

  String get privateCode {
    var result = [];
    if (doc != null && !hasPublicCode) result
        .add('${dartComment(rightTrim(doc))}');
    if (!isPublic) result.add(decl);
    return result.join('\n');
  }

  // end <class Member>

  final Id _id;
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
  bool hasOpEquals = false;
  /// If true, implements comparable
  bool isComparable = false;
  /// If true, implements comparable with runtimeType check followed by rest
  bool isPolymorphicComparable = false;
  /// If true adds '..ctors[''] to all members (i.e. ensures generation of
  /// empty ctor with all members passed as arguments)
  ///
  bool hasCourtesyCtor = false;
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

  bool get hasCtorSansNew => _hasCtorSansNew == null
      ? ((owner is Library) ? (owner as Library).hasCtorSansNew : false)
      : _hasCtorSansNew;

  bool get hasJsonSupport =>
      _hasJsonSupport || hasJsonToString || jsonKeyFormat != null;

  List<Member> get publicMembers =>
      members.where((member) => member.isPublic).toList();

  List<Member> get privateMembers =>
      members.where((member) => !member.isPublic).toList();

  List<Member> get nonStaticMembers =>
      members.where((member) => !member.isStatic).toList();

  List<Member> get nonTransientMembers =>
      nonStaticMembers.where((member) => !member.isJsonTransient).toList();

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
    parts.addAll(nonTransientMembers.map((Member m) {
      if (m.isList) {
        return 'const ListEquality<${jsonListValueType(m.type)}>().hash(${m.varName})';
      } else if (m.isMap) {
        return 'const MapEquality().hash(${m.varName})';
      } else {
        return '${m.varName}';
      }
    }));

    int numMembers = nonTransientMembers.length;
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

  String get hasOpEqualsMethod => '''
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
      ? indentBlock('''
${className}._copy(${className} other) :
${
  indentBlock(members
    .map((m) => '${m.varName} = ${_assignCopy(m.type, "other.${m.varName}")}')
    .join(',\n'), '  ')
};
''', '  ')
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

  get defaultMemberAccess =>
      _defaultMemberAccess == null ? _defaultOwnerAccess : _defaultMemberAccess;

  setDefaultMemberAccess(Member m) {
    if (m.access == null) m.access = defaultMemberAccess;
  }

  onOwnershipEstablished() {
    _className = isPublic ? _name : "_$_name";
    _ctors.clear();

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

    if (hasDefaultCtor) _ctors.putIfAbsent('', () => new Ctor()
      ..name = ''
      ..className = _className);

    if (allMembersFinal) nonTransientMembers.forEach((m) => m.isFinal = true);

    if (isPolymorphicComparable) isComparable = true;

    if (isComparable) {
      if (isPolymorphicComparable) {
        implement.add('Comparable<Object>');
      } else {
        implement.add('Comparable<$_className>');
      }
    }

    if (hasCourtesyCtor) {
      members.forEach((m) {
        if (!m.ctors.contains('') && !m.isJsonTransient) m.ctors.add('');
      });
    }

    // Iterate on all members and create the appropriate ctors
    members.forEach((m) {
      setDefaultMemberAccess(m);

      m.owner = this;

      makeCtorName(ctorName) {
        if (ctorName == '') return '';
        bool isPrivate = ctorName.startsWith('_');
        if (isPrivate) {
          return '_${idFromString(ctorName.substring(1)).camel}';
        } else {
          return idFromString(ctorName).camel;
        }
      }

      m.ctors.forEach((ctorName) {
        ctorName = makeCtorName(ctorName);
        ctors.putIfAbsent(ctorName, () => new Ctor())
          ..name = ctorName
          ..hasCustom = ctorCustoms.contains(ctorName)
          ..isConst = ctorConst.contains(ctorName)
          ..className = _className
          ..members.add(m);
      });
      m.ctorsOpt.forEach((ctorName) {
        ctorName = makeCtorName(ctorName);
        ctors.putIfAbsent(ctorName, () => new Ctor())
          ..name = ctorName
          ..hasCustom = ctorCustoms.contains(ctorName)
          ..isConst = ctorConst.contains(ctorName)
          ..className = _className
          ..optMembers.add(m);
      });
      m.ctorsNamed.forEach((ctorName) {
        ctorName = makeCtorName(ctorName);
        _ctors.putIfAbsent(ctorName, () => new Ctor())
          ..name = ctorName
          ..hasCustom = ctorCustoms.contains(ctorName)
          ..isConst = ctorConst.contains(ctorName)
          ..className = _className
          ..namedMembers.add(m);
      });
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
  get _classOpener => '$_classWithExtends${implementsClause}{';
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
        ..members = (members.map((m) => member(m.id.snake)
          ..type = m.type
          ..classInit = m.classInit).toList())
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
  bool _hasCtorSansNew;
  String _name;
  String _className;
}

// custom <part class>

final snake = JsonKeyFormat.snake;
final capCamel = JsonKeyFormat.capCamel;
final camel = JsonKeyFormat.camel;

// end <part class>
