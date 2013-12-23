part of dart_meta;

String class_([dynamic _]) {
  if(_ is Map) {
    _ = new Context(_);
  }
  List<String> _buf = new List<String>();


 if(_.doc != null) { 
  _buf.add('''
${rightTrim(docComment(_.doc))}
''');
 } 
 String abstractTag = _.isAbstract? 'abstract ':''; 
 if(_.mixins.length>0) { 
  _buf.add('''
${abstractTag}class ${_.className} extends ${_.extend} with ${_.mixins.join(',')}${_.implementsClause}{
''');
 } else if(null != _.extend) { 
  _buf.add('''
${abstractTag}class ${_.className} extends ${_.extend}${_.implementsClause}{
''');
 } else { 
  _buf.add('''
${abstractTag}class ${_.className}${_.implementsClause}{
''');
 } 
 _.orderedCtors.forEach((ctorName) { 
  _buf.add('''

${indentBlock(_.ctors[ctorName].ctorText)}
''');
 }); 
 if(_.opEquals) { 
  _buf.add('''
${indentBlock(_.opEqualsMethod)}
''');
 } 
 if(_.comparable) { 
  _buf.add('''
${indentBlock(_.comparableMethod)}
''');
 } 
 for(var member in _.members) { 
   if(member.hasPublicCode) { 
  _buf.add('''
${indentBlock(chomp(member.publicCode))}
''');
   } 
 } 
 if(null != _.topInjection) { 
  _buf.add('''
${indentBlock(_.topInjection)}
''');
 } 
 if(_.includeCustom) { 
  _buf.add('''

${rightTrim(indentBlock(customBlock("class ${_.name}")))}
''');
 } 
 if(_.jsonSupport) { 
  _buf.add('''

  Map toJson() {
    return {
''');
   for(Member member in _.members.where((m) => !m.jsonTransient)) { 
  _buf.add('''
    "${member.name}": ebisu_utils.toJson(${member.hasGetter? member.name : member.varName}),
''');
   } 
   if(null != _.extend) { 
  _buf.add('''
    "${_.extend}": super.toJson(),
''');
   } else if(_.mixins.length > 0) { 
  _buf.add('''
    // TODO consider mixin support: "${_.className}": super.toJson(),
''');
   } 
  _buf.add('''
    };
  }

  static ${_.name} fromJson(Object json) {
    if(json == null) return null;
    if(json is String) {
      json = convert.JSON.decode(json);
    }
    assert(json is Map);
    ${_.name} result = new ${_.jsonCtor}();
    result._fromJsonMapImpl(json);
    return result;
  }

${indentBlock(_.fromJsonMapImpl())}

''');
 } 
 if(_.hasRandJson) { 
  _buf.add('''
  static Map randJson() {
    return {
''');
   for(Member member in _.members.where((m) => !m.jsonTransient)) { 
     if(isMapType(member.type)) { 
       String valType = jsonMapValueType(member.type);  
       String keyType = generalMapKeyType(member.type); 
       if(keyType == 'String') { 
         if(isJsonableType(valType)) { 
  _buf.add('''
    "${member.name}":
       ebisu_utils.randJsonMap(_randomJsonGenerator,
        () => ebisu_utils.randJson(_randomJsonGenerator, ${valType}),
        "${member.name}"),
''');
         } else { 
  _buf.add('''
    "${member.name}":
       ebisu_utils.randJsonMap(_randomJsonGenerator,
        () => ${valType}.randJson(),
        "${member.name}"),
''');
         } 
       } else { 
         if(isJsonableType(valType)) { 
  _buf.add('''
    "${member.name}":
       ebisu_utils.randGeneralMap(() => ${keyType}.randJson().toString(),
        _randomJsonGenerator,
        () => ebisu_utils.randJson(_randomJsonGenerator, ${valType})),
''');
         } else { 
  _buf.add('''
    "${member.name}":
       ebisu_utils.randGeneralMap(() => ${keyType}.randJson().toString(),
        _randomJsonGenerator,
        () => ${valType}.randJson()),
''');
         } 
       } 
     } else if(isListType(member.type)) { 
       String valType = jsonListValueType(member.type);  
       if(isJsonableType(valType)) { 
  _buf.add('''
    "${member.name}":
       ebisu_utils.randJson(_randomJsonGenerator, [],
        () => ebisu_utils.randJson(_randomJsonGenerator, ${valType})),
''');
       } else { 
  _buf.add('''
    "${member.name}":
       ebisu_utils.randJson(_randomJsonGenerator, [],
        () => ${valType}.randJson()),
''');
       }  
     } else if(isJsonableType(member.type)) { 
  _buf.add('''
    "${member.name}": ebisu_utils.randJson(_randomJsonGenerator, ${member.type}),
''');
     } else { 
  _buf.add('''
    "${member.name}": ebisu_utils.randJson(_randomJsonGenerator, ${member.type}.randJson),
''');
     } 
   } 
  _buf.add('''
    };
  }

''');
 } 
 for(var member in _.members) { 
   if(member.hasPrivateCode) { 
  _buf.add('''
${indentBlock(chomp(member.privateCode))}
''');
   } 
 } 
 if(null != _.bottomInjection) { 
  _buf.add('''
${indentBlock(_.bottomInjection)}
''');
 } 
  _buf.add('''
}
''');
 if(_.ctorSansNew) {  
   if(_.ctors.length>0) { 
     _.ctors.forEach((ctorName, ctor) { 
  _buf.add('''
${ctor.ctorSansNew}
''');
     }); 
   } else { 
  _buf.add('''
${_.id.camel}() => new ${_.name}();
''');
   } 
 } 
  return _buf.join();
}