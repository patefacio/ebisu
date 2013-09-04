part of dart_meta;

String pubspec([dynamic _]) {
  if(_ is Map) {
    _ = new Context(_);
  }
  List<String> _buf = new List<String>();


  _buf.add('''
name: ${_.name}
version: ${_.version}
''');
 if(_.author != null) {                                               
  _buf.add('''
author: ${_.author}
''');
 }                                                                    
 if(_.homepage != null) {                                             
  _buf.add('''
homepage: ${_.homepage}
''');
 }                                                                    
 if(_.doc != null) {                                                  
  _buf.add('''
description: >
${indentBlock(_.doc)}
''');
 }                                                                    
  _buf.add('''
dependencies:
''');
 for(PubDependency pbdep in _.dependencies) {                         
  _buf.add('''
${pbdep.yamlEntry}
''');
 } 
  _buf.add('''
${scriptCustomBlock('${_.name} dependencies')}
dev_dependencies:
''');
 for(PubDependency pbdep in _.devDependencies) {                      
  _buf.add('''
${pbdep.yamlEntry}
''');
 } 
  _buf.add('''
${scriptCustomBlock('${_.name} dev dependencies')}

''');
  return _buf.join();
}