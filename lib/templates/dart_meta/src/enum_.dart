part of dart_meta;

String enum_([dynamic _]) {
  if(_ is Map) {
    _ = new Context(_);
  }
  List<String> _buf = new List<String>();


 if(_.doc != null) { 
  _buf.add('''
${docComment(_.doc)}
''');
 } 
  _buf.add('''
class ${_.enumName} {
''');
 int i = 0; 
 for(var value in _.values) { 
  _buf.add('''
  static const ${value.shout} = const ${_.enumName}._(${i++});
''');
 } 
  _buf.add('''

  static get values => [
    ${_.values.map((v) => v.shout).join(",\n    ")}
  ];

  final int value;

  const ${_.enumName}._(this.value);

  String toString() {
    switch(this) {
''');
 for(var value in _.values) { 
  _buf.add('''
      case ${value.shout}: return "${value.shout}";
''');
 } 
  _buf.add('''
    }
  }

  static ${_.enumName} fromString(String s) {
    switch(s) {
''');
 for(var value in _.values) { 
  _buf.add('''
      case "${value.shout}": return ${value.shout};
''');
 } 
  _buf.add('''
    }
  }

''');
 if(_.jsonSupport) { 
  _buf.add('''
  int toJson() {
    return this.value;
  }

  static int randJson() {
   return _randomJsonGenerator.nextInt(${_.values.length});
  }

  static ${_.enumName} fromJson(int v) {
    switch(v) {
''');
 i = 0; 
 for(var value in _.values) { 
  _buf.add('''
      case ${i++}: return ${value.shout};
''');
 } 
  _buf.add('''
    }
  }

''');
 } 
 if(_.hasCustom) { 
  _buf.add('''

${rightTrim(indentBlock(customBlock("enum ${_.name}")))}
''');
 } 
  _buf.add('''

}
''');
  return _buf.join();
}