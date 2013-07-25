part of dart_meta;

String member([dynamic _]) {
  if(_ is Map) {
    _ = new Context(_);
  }
  List<String> _buf = new List<String>();


 bool hasGetter = (_.access == Access.RO); 
 bool hasSetter = _.access == Access.RW; 
 if(_.doc != null && !hasGetter) { 
  _buf.add('''
${docComment(rightTrim(_.doc))}
''');
 } 
 if(_.classInit == null) { 
  _buf.add('''
${_.isFinal? 'final ':''}${_.type} ${_.varName};
''');
 } else { 
   if(_.type == 'String') { 
  _buf.add('''
${_.isFinal? 'final ':''}${_.type} ${_.varName} = "${_.classInit}";
''');
   } else { 
  _buf.add('''
${_.isFinal? 'final ':''}${_.type} ${_.varName} = ${_.classInit};
''');
   } 
 } 
 if(!_.isPublic) { 
   if(hasGetter) { 
     if(_.doc != null) { 
  _buf.add('''
${docComment(_.doc)}
''');
     } 
  _buf.add('''
${_.type} get ${_.name} => ${_.varName};
''');
   } 
 } 
  return _buf.join();
}