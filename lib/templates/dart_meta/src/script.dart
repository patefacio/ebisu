part of dart_meta;

String script([dynamic _]) {
  if(_ is Map) {
    _ = new Context(_);
  }
  List<String> _buf = new List<String>();


  _buf.add('''
#!/usr/bin/env dart
''');
 if(_.doc != null) { 
  _buf.add('''
${docComment(_.doc)}
''');
 } 
  _buf.add('''

''');
 for(var i in _.imports) { 
  _buf.add('''
${i}
''');
 } 
  _buf.add('''

//! The parser for this script
ArgParser _parser;

//! The comment and usage associated with this script
void _usage() { 
  print(\'\'\'
${_.doc}
\'\'\');
  print(_parser.getUsage());
}

//! Method to parse command line options.
//! The result is a map containing all options, including positional options
Map _parseArgs() { 
  ArgResults argResults;
  Map result = { };
  List remaining = [];

  _parser = new ArgParser();
  try { 
    /// Fill in expectations of the parser
''');
 for(var scriptArg in _.args) { 
   if(scriptArg.isFlag) { 
  _buf.add('''
    _parser.addFlag('${scriptArg.name}', 
      help: \'\'\'
${scriptArg.doc}
\'\'\',
      defaultsTo: ${scriptArg.defaultsTo}
    );
''');
   } else if(scriptArg.position == null) { 
  _buf.add('''
    _parser.addOption('${scriptArg.name}', 
''');
     if(scriptArg.doc != null) { 
  _buf.add('''
      help: \'\'\'
${scriptArg.doc}
\'\'\',
''');
     }  
  _buf.add('''
      defaultsTo: ${scriptArg.defaultsTo == null? null : '${scriptArg.defaultsTo}'},
      allowMultiple: ${scriptArg.isMultiple},
      abbr: ${scriptArg.abbr == null? null : "'${scriptArg.abbr}'"},
      allowed: ${scriptArg.allowed.length>0 ? scriptArg.allowed.map((a) => "'$a'").toList() : null});
''');
   }  
 } 
  _buf.add('''

    /// Parse the command line options (excluding the script)
    var arguments = new Options().arguments;
    argResults = _parser.parse(arguments);
    argResults.options.forEach((opt) { 
      result[opt] = argResults[opt];
    });
''');
 if(_.args.where((sa) => sa.position != null).toList().length > 0) { 
  _buf.add('''
    // Pull out positional args as they were named
    remaining = new List.from(argResults.rest);
''');
 } 
 for(var scriptArg in _.args) { 
   if(scriptArg.position != null) { 
  _buf.add('''
    if(${scriptArg.position} >= remaining.length) { 
      throw new ArgumentError("Positional argument ${scriptArg.name} (position ${scriptArg.position}) not avaiable - not enough args");
    }
    result['${scriptArg.name}'] = remaining.removeAt(${scriptArg.position});
''');
   }  
 } 
  _buf.add('''
    
    return { 'options': result, 'rest': remaining };

  } catch(e) { 
    _usage();
    throw e;
  }
}

final _logger = new Logger("${_.id}");

main() { 
  Logger.root.onRecord.listen(new PrintHandler());
  Logger.root.level = Level.INFO;
  Map argResults = _parseArgs();
  Map options = argResults['options'];
  List positionals = argResults['rest'];

''');
 var required = _.requiredArgs.toList();              
 if(required.length > 0) {                            
  _buf.add('''
  try { 
''');
   _.requiredArgs.forEach((arg) {                     
  _buf.add('''
    if(options["${arg.name}"] == null)
      throw new ArgumentError("option: ${arg.name} is required");

''');
   }); 
  _buf.add('''
  } on ArgumentError catch(e) { 
    print(e);
    _usage();
  }
''');
 } 
  _buf.add('''
${indentBlock(customBlock("${_.id} main"))}
}

${customBlock("${_.id} global")}

''');
  return _buf.join();
}