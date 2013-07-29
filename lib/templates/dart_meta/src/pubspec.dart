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
   if(pbdep.isHosted) {         
  _buf.add('''
  ${pbdep.name}:  ${pbdep.version!=null? '"${pbdep.version}"' : ''}
''');
   } else if(pbdep.isPath || pbdep.isGit) {                           
  _buf.add('''
  ${pbdep.name}:
''');
   } else {                                                           
  _buf.add('''
  ${pbdep.name}: '${pbdep.version}'
''');
   }                                                                  
   if(pbdep.path == null) {                                           
   } else {                                                           
     if(pbdep.isHosted) {                                             
  _buf.add('''
      hosted: 
        name: ${pbdep.name}
        url: ${pbdep.path}
      version: '${pbdep.version}' 
''');
     } else if(pbdep.isGit) {                                         
       if(pbdep != null) {                                     
  _buf.add('''
      git: 
        url: ${pbdep.path}
        ref: ${pbdep.gitRef}
''');
       } else {                                                       
  _buf.add('''
      git: ${pbdep.path}
''');
       }                                                              
  _buf.add('''

''');
     } else {                                                         
  _buf.add('''
      path: ${pbdep.path}
''');
     }                                                                
   }                                                                  
 } 
  _buf.add('''
${scriptCustomBlock('${_.name} dependencies')}
''');
  return _buf.join();
}