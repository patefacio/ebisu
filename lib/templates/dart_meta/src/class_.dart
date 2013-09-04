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
 for(var member in _.members) { 
  _buf.add('''
${indentBlock(chomp(member.define()))}
''');
 } 
 if(_.includeCustom) { 
  _buf.add('''

${rightTrim(indentBlock(customBlock("class ${_.name}")))}
''');
 } 
 if(_.toJsonSupport) { 
  _buf.add('''

  Map toJson() {
    return {
''');
   for(Member member in _.members.where((m) => !m.jsonTransient)) { 
  _buf.add('''
    "${member.name}": EBISU_UTILS.toJson(${member.varName}),
''');
   } 
   if(null != _.extend) { 
  _buf.add('''
    "${_.extend}": super.toJson(),
''');
   } else if(null != _.mixins) { 
  _buf.add('''
    // TODO: "${_.className}": super.toJson(),
''');
   } 
  _buf.add('''
    };
  }

  static Map randJson() {
    return {
''');
   for(Member member in _.members.where((m) => !m.jsonTransient)) { 
     if(isMapType(member.type)) { 
       String valType = jsonMapValueType(member.type);  
       if(isJsonableType(valType)) { 
  _buf.add('''
    "${member.name}":
       EBISU_UTILS.randJsonMap(_randomJsonGenerator,
        () => EBISU_UTILS.randJson(_randomJsonGenerator, ${valType}),
        "${member.name}"),
''');
       } else { 
  _buf.add('''
    "${member.name}":
       EBISU_UTILS.randJsonMap(_randomJsonGenerator,
        () => ${valType}.randJson(),
        "${member.name}"),
''');
       } 
     } else if(isListType(member.type)) { 
       String valType = jsonListValueType(member.type);  
       if(isJsonableType(valType)) { 
  _buf.add('''
    "${member.name}":
       EBISU_UTILS.randJson(_randomJsonGenerator, [],
        () => EBISU_UTILS.randJson(_randomJsonGenerator, ${valType})),
''');
       } else { 
  _buf.add('''
    "${member.name}":
       EBISU_UTILS.randJson(_randomJsonGenerator, [],
        () => ${valType}.randJson()),
''');
       }  
     } else if(isJsonableType(member.type)) { 
  _buf.add('''
    "${member.name}": EBISU_UTILS.randJson(_randomJsonGenerator, ${member.type}),
''');
     } else { 
  _buf.add('''
    "${member.name}": EBISU_UTILS.randJson(_randomJsonGenerator, ${member.type}.randJson),
''');
     } 
   } 
  _buf.add('''
    };
  }

''');
   } 
 if(_.jsonSupport) { 
  _buf.add('''

  static ${_.name} fromJson(String json) {
    Map jsonMap = convert.JSON.decode(json);
    ${_.name} result = new ${_.jsonCtor}();
    result._fromJsonMapImpl(jsonMap);
    return result;
  }

  static ${_.name} fromJsonMap(Map jsonMap) {
    ${_.name} result = new ${_.jsonCtor}();
    result._fromJsonMapImpl(jsonMap);
    return result;
  }

  void _fromJsonMapImpl(Map jsonMap) {
''');
   for(Member m in _.members.where((m) => !m.jsonTransient)) { 
     if(_.isClassJsonable(m.type)) { 
  _buf.add('''
    ${m.varName} = (jsonMap["${m.name}"] is Map)?
      ${m.type}.fromJsonMap(jsonMap["${m.name}"]) :
      ${m.type}.fromJson(jsonMap["${m.name}"]);
''');
     } else if(isMapType(m.type)) { 
       String valType = jsonMapValueType(m.type);  
       if(valType != null) { 
  _buf.add('''
    // ${m.name} map of <String, ${valType}>
    ${m.name} = { };
    jsonMap["${m.name}"].forEach((k,v) {
      ${m.varName}[k] = ${valType}.fromJsonMap(v);
    });
''');
       } 
     } else if(isListType(m.type)) { 
       String valType = jsonListValueType(m.type);  
       if(valType != null) { 
  _buf.add('''
    // ${m.name} list of ${valType}
    ${m.varName} = new ${m.type}();
    jsonMap["${m.name}"].forEach((v) {
      ${m.varName}.add(${valType}.fromJsonMap(v));
    });
''');
       } 
     } else { 
       if(m.type == 'DateTime') { 
  _buf.add('''
    ${m.varName} = DateTime.parse(jsonMap["${m.name}"]);
''');
       } else { 
  _buf.add('''
    ${m.varName} = jsonMap["${m.name}"];
''');
       } 
     } 
   } 
  _buf.add('''
  }
''');
 } 
  _buf.add('''
}
''');
 if(_.ctorSansNew) {  
   _.ctors.forEach((ctorName, ctor) { 
  _buf.add('''
${ctor.ctorSansNew}
''');
 }); 
  _buf.add('''

''');
 } 
  return _buf.join();
}