part of dart_meta;

String part([dynamic _]) {
  if(_ is Map) {
    _ = new Context(_);
  }
  List<String> _buf = new List<String>();


  _buf.add('''
part of ${_.parent.name};
''');
 for(var e in _.enums) { 
  _buf.add('''

${chomp(e.define())}
''');
 } 
 for(var c in _.classes) { 
  _buf.add('''

${chomp(c.define())}
''');
 } 
 if(_.includeCustom) { 
  _buf.add('''
${customBlock("part ${_.name}")}
''');
 } 
  return _buf.join();
}
