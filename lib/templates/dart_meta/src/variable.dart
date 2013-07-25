part of dart_meta;

String variable([dynamic _]) {
  if(_ is Map) {
    _ = new Context(_);
  }
  List<String> _buf = new List<String>();


 if(_.doc != null) { 
  _buf.add('''
// ${_.doc}
''');
 } 
 if(_.init == null) { 
  _buf.add('''
${_.isFinal? 'final ':''}${_.type} ${_.varName};
''');
 } else { 
  _buf.add('''
${_.isFinal? 'final ':''}${_.type} ${_.varName} = ${_.init};
''');
 } 
  return _buf.join();
}
