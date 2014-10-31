part of ebisu.ebisu_dart_meta;

/// An agrument to a script
class ScriptArg {

  ScriptArg(this._id);

  /// Id for this script argument
  Id get id => _id;
  /// Documentation for this script argument
  String doc;
  /// Reference to parent of this script argument
  dynamic get parent => _parent;
  /// Name of the the arg (emacs naming convention)
  String get name => _name;
  /// If true the argument is required
  bool isRequired = false;
  /// If true this argument is a boolean flag (i.e. no option is required)
  bool isFlag = false;
  /// If true the argument may be specified mutiple times
  bool isMultiple = false;
  /// Used to initialize the value in case not set
  dynamic defaultsTo;
  /// A list of allowed values to choose from
  List<String> allowed = [];
  /// If not null - holds the position of a positional (i.e. unnamed) argument
  int position;
  /// An abbreviation (single character)
  String abbr;

  // custom <class ScriptArg>

  set parent(p) {
    _parent = p;
    _name = _id.emacs;
  }

  // end <class ScriptArg>
  final Id _id;
  dynamic _parent;
  String _name;
}

/// A typical script - (i.e. like a bash/python/ruby script but in dart)
class Script {

  Script(this._id);

  /// Id for this script
  Id get id => _id;
  /// Documentation for this script
  String doc;
  /// Reference to parent of this script
  dynamic get parent => _parent;
  /// If true a custom section will be included for script
  bool includeCustom = true;
  /// List of imports to be included by this script
  List<String> imports = [];
  /// Arguments for this script
  List<ScriptArg> args = [];

  // custom <class Script>


  set parent(p) {
    _parent = p;
    args.forEach((sa) => sa.parent = this);
    imports.add('dart:io');
    imports.add('package:args/args.dart');
    imports.add('package:logging/logging.dart');
    imports = cleanImports(
      imports.map((i) => importStatement(i)).toList());
  }

  void generate() {
    String scriptName = _id.snake;
    String scriptPath = "${_parent.rootPath}/bin/${scriptName}.dart";
    mergeWithFile('${_content}\n', scriptPath);
  }

  Iterable get requiredArgs =>
    args.where((arg) => arg.isRequired);

  get _content =>
    [
      _scriptTag,
      _docComment,
      _imports,
      _argParser,
      _usage,
      reduceVerticalWhitespace(_parseArgs),
      _loggerInit,
      _main,
    ]
    .where((line) => line != '')
    .join('\n');

  get _scriptTag => '#!/usr/bin/env dart';
  get _docComment => doc != null? '${docComment(doc)}\n' : '';
  get _imports => '${imports.join('\n')}\n';
  get _argParser => '''
//! The parser for this script
ArgParser _parser;
''';
  get _usage => '''
//! The comment and usage associated with this script
void _usage() {
  print(\'\'\'
$doc
\'\'\');
  print(_parser.getUsage());
}
''';
  get _parseArgs => '''
//! Method to parse command line options.
//! The result is a map containing all options, including positional options
Map _parseArgs(List<String> args) {
  ArgResults argResults;
  Map result = { };
  List remaining = [];

  _parser = new ArgParser();
  try {
    /// Fill in expectations of the parser
$_addFlags
$_addOptions
    /// Parse the command line options (excluding the script)
    argResults = _parser.parse(args);
    argResults.options.forEach((opt) {
      result[opt] = argResults[opt];
    });
$_pullPositionals
$_positionals

    return { 'options': result, 'rest': remaining };

  } catch(e) {
    _usage();
    throw e;
  }
}
''';

  get _addFlags => args
    .where((arg) => arg.isFlag)
    .map((arg) => '''
    _parser.addFlag('${arg.name}',
      help: \'\'\'
${arg.doc}
\'\'\',
      defaultsTo: ${arg.defaultsTo}
    );''').join('\n') + '\n';

  get _addOptions => args
    .where((arg) => !arg.isFlag && arg.position == null)
    .map((arg) => '''
    _parser.addOption('${arg.name}',
      help: ${arg.doc == null? "''" : "\'\'\'\n${arg.doc}\n\'\'\'"},
      defaultsTo: ${arg.defaultsTo == null? null : '${arg.defaultsTo}'},
      allowMultiple: ${arg.isMultiple},
      abbr: ${arg.abbr == null? null : "'${arg.abbr}'"},
      allowed: ${arg.allowed.length>0? arg.allowed.map((a) => "'$a'").toList() : null}
    );''').join('\n') + '\n';

  get _pullPositionals => args
    .where((sa) => sa.position != null).length > 0 ? '''
    // Pull out positional args as they were named
    remaining = new List.from(argResults.rest);''' : '';

  get _positionals => args
    .where((sa) => sa.position != null)
    .map((sa) => '''
    if(${sa.position} >= remaining.length) {
      throw new
        ArgumentError('Positional argument ${sa.name} (position ${sa.position}) not available - not enough args');
    }
    result['${sa.name}'] = remaining.removeAt(${sa.position});
''').join('\n');

  get _loggerInit => "final _logger = new Logger('$id');\n";
  get _main => '''
main(List<String> args) {
  Logger.root.onRecord.listen((LogRecord r) =>
      print("\${r.loggerName} [\${r.level}]:\\t\${r.message}"));
  Logger.root.level = Level.INFO;
  Map argResults = _parseArgs(args);
  Map options = argResults['options'];
  List positionals = argResults['rest'];
${_requiredArgs}
${indentBlock(customBlock("$id main"))}
}

${customBlock("$id global")}''';

  get _requiredArgs => indentBlock(requiredArgs.length>0? '''
try {

$_processArgs
} on ArgumentError catch(e) {
  print(e);
  _usage();
}
''':'');

  get _processArgs => requiredArgs.map((arg) => '''
  if(options["${arg.name}"] == null)
    throw new ArgumentError("option: ${arg.name} is required");
''').join('');

  // end <class Script>
  final Id _id;
  dynamic _parent;
}
// custom <part script>
// end <part script>
