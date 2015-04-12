part of ebisu.ebisu_dart_meta;

/// Specifies type of argument like (https://docs.python.org/2/library/optparse.html#optparse-standard-option-types)
class ArgType implements Comparable<ArgType> {
  static const STRING = const ArgType._(0);
  static const INT = const ArgType._(1);
  static const LONG = const ArgType._(2);
  static const CHOICE = const ArgType._(3);
  static const DOUBLE = const ArgType._(4);
  static const BOOL = const ArgType._(5);

  static get values => [STRING, INT, LONG, CHOICE, DOUBLE, BOOL];

  final int value;

  int get hashCode => value;

  const ArgType._(this.value);

  copy() => this;

  int compareTo(ArgType other) => value.compareTo(other.value);

  String toString() {
    switch (this) {
      case STRING:
        return "String";
      case INT:
        return "Int";
      case LONG:
        return "Long";
      case CHOICE:
        return "Choice";
      case DOUBLE:
        return "Double";
      case BOOL:
        return "Bool";
    }
    return null;
  }

  static ArgType fromString(String s) {
    if (s == null) return null;
    switch (s) {
      case "String":
        return STRING;
      case "Int":
        return INT;
      case "Long":
        return LONG;
      case "Choice":
        return CHOICE;
      case "Double":
        return DOUBLE;
      case "Bool":
        return BOOL;
      default:
        return null;
    }
  }
}

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
  dynamic get defaultsTo => _defaultsTo;
  /// A list of allowed values to choose from
  List<String> allowed = [];
  /// If not null - holds the position of a positional (i.e. unnamed) argument
  int position;
  /// An abbreviation (single character)
  String abbr;
  ArgType type;

  // custom <class ScriptArg>

  set parent(p) {
    _parent = p;
    _name = _id.emacs;
  }

  set defaultsTo(dynamic val) {
    _defaultsTo = val;
    type = val is int
        ? ArgType.INT
        : val is double
            ? ArgType.DOUBLE
            : val is bool ? ArgType.BOOL : ArgType.STRING;
  }

  // end <class ScriptArg>

  final Id _id;
  dynamic _parent;
  String _name;
  dynamic _defaultsTo;
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
  /// Where to create the script.
  /// If not present will be determined by parent [System] rootPath
  set scriptPath(String scriptPath) => _scriptPath = scriptPath;
  /// Arguments for this script
  List<ScriptArg> args = [];
  /// By default a *log-level* argument will be included in the script.
  /// Set this to false to prevent this
  bool noLogLevel = false;
  /// If true makes script main async
  bool isAsync = false;
  /// Classes to support this script, included directly in script above main
  List<Class> classes = [];

  // custom <class Script>

  set parent(p) {
    _parent = p;
    if (!args.any((a) => a.name == 'help')) {
      args.add(new ScriptArg(new Id('help'))
        ..isFlag = true
        ..abbr = 'h'
        ..doc = 'Display this help screen');
    }
    if (!noLogLevel) {
      args.add(new ScriptArg(new Id('log_level'))
        ..doc = '''
Select log level from:
[ all, config, fine, finer, finest, info, levels,
  off, severe, shout, warning ]
''');
    }
    args.forEach((sa) => sa.parent = this);
  }

  get nonPositionalArgs => args.where((a) => a.position == null);

  get scriptPath =>
      _scriptPath == null ? join(_parent.rootPath, 'bin') : _scriptPath;

  void generate() {
    imports.add('dart:io');
    imports.add('package:args/args.dart');
    imports.add('package:logging/logging.dart');
    imports = cleanImports(imports.map((i) => importStatement(i)).toList());
    String scriptName = _id.snake;
    String dartPath = join(scriptPath, '${scriptName}.dart');
    mergeWithDartFile('${_content}\n', dartPath);
  }

  Iterable get requiredArgs => args.where((arg) => arg.isRequired);

  get _content => brCompact([
    _scriptTag,
    _docComment,
    _imports,
    args.isEmpty
        ? null
        : brCompact([_argParser, _usage, reduceVerticalWhitespace(_parseArgs)]),
    _loggerInit,
    br(classes.map((c) => c.define())),
    _main,
  ].where((line) => line != ''));

  get _scriptTag => '#!/usr/bin/env dart';
  get _docComment => doc != null ? '${docComment(doc)}\n' : '';
  get _imports => '${imports.join('\n')}\n';

  get _argParser => '''
//! The parser for this script
ArgParser _parser;
''';

  get _usage => '''
//! The comment and usage associated with this script
void _usage() {
  print(r\'\'\'
$doc
\'\'\');
  print(_parser.getUsage());
}
''';

  _coerced(String parse, ScriptArg arg) => parse == null
      ? "result['${arg.name}'] = argResults['${arg.name}'];"
      : '''
result['${arg.name}'] = argResults['${arg.name}'] != null?
  $parse(argResults['${arg.name}']) : null;''';

  _coerceArg(ScriptArg arg) => arg.type == ArgType.INT
      ? _coerced('int.parse', arg)
      : arg.type == ArgType.LONG
          ? _coerced('int.parse', arg)
          : arg.type == ArgType.DOUBLE
              ? _coerced('double.parse', arg)
              : arg.type == ArgType.BOOL
                  ? _coerced(null, arg)
                  : _coerced(null, arg);

  get _logLevelCode => (noLogLevel
      ? ''
      : indentBlock("""
if(result['log-level'] != null) {
  const choices = const {
    'all': Level.ALL, 'config': Level.CONFIG, 'fine': Level.FINE, 'finer': Level.FINER,
    'finest': Level.FINEST, 'info': Level.INFO, 'levels': Level.LEVELS, 'off': Level.OFF,
    'severe': Level.SEVERE, 'shout': Level.SHOUT, 'warning': Level.WARNING };
  final selection = choices[result['log-level'].toLowerCase()];
  if(selection != null) Logger.root.level = selection;
}
"""));

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
    if(argResults.wasParsed('help')) {
      _usage();
      exit(0);
    }
${
indentBlock(nonPositionalArgs.map((arg) => _coerceArg(arg)).join('\n'), '    ')
}
$_pullPositionals
$_positionals
$_logLevelCode
    return { 'options': result, 'rest': argResults.rest };

  } catch(e) {
    _usage();
    throw e;
  }
}
''';

  _defaultsTo(ScriptArg arg) =>
      arg.defaultsTo == null ? null : smartQuote(arg.defaultsTo.toString());

  get _addFlags => args.where((arg) => arg.isFlag).map((arg) => '''
    _parser.addFlag('${arg.name}',
      help: r\'\'\'
${arg.doc}
\'\'\',
      abbr: ${arg.abbr == null? null : "'${arg.abbr}'"},
      defaultsTo: ${arg.defaultsTo == null? false : arg.defaultsTo}
    );''').join('\n') + '\n';

  get _addOptions => args
      .where((arg) => !arg.isFlag && arg.position == null)
      .map((arg) => '''
    _parser.addOption('${arg.name}',
      help: ${arg.doc == null? "''" : "r\'\'\'\n${arg.doc}\n\'\'\'"},
      defaultsTo: ${_defaultsTo(arg)},
      allowMultiple: ${arg.isMultiple},
      abbr: ${arg.abbr == null? null : "'${arg.abbr}'"},
      allowed: ${arg.allowed.length>0? arg.allowed.map((a) => "'$a'").toList() : null}
    );''').join('\n') + '\n';

  get _pullPositionals => args.where((sa) => sa.position != null).length > 0
      ? '''
    // Pull out positional args as they were named
    remaining = new List.from(argResults.rest);'''
      : '';

  get _positionals => args.where((sa) => sa.position != null).map((sa) => '''
    if(${sa.position} >= remaining.length) {
      throw new
        ArgumentError('Positional argument ${sa.name} (position ${sa.position}) not available - not enough args');
    }
    result['${sa.name}'] = remaining.removeAt(${sa.position});
''').join('\n');

  get _loggerInit => "final _logger = new Logger('$id');\n";

  get _argMap => args.isEmpty
      ? null
      : '''
  Map argResults = _parseArgs(args);
  Map options = argResults['options'];
  List positionals = argResults['rest'];
${_requiredArgs}
''';

  get _main => '''
main(List<String> args) ${isAsync? 'async ':''}{
  Logger.root.onRecord.listen((LogRecord r) =>
      print("\${r.loggerName} [\${r.level}]:\\t\${r.message}"));
  Logger.root.level = Level.OFF;
${indentBlock(customBlock("$id main"))}
}

${customBlock("$id global")}''';

  get _requiredArgs => indentBlock(requiredArgs.length > 0
      ? '''
try {

$_processArgs
} on ArgumentError catch(e) {
  print(e);
  _usage();
}
'''
      : '');

  get _processArgs => requiredArgs.map((arg) => '''
  if(options["${arg.name}"] == null)
    throw new ArgumentError("option: ${arg.name} is required");
''').join('');

  // end <class Script>

  final Id _id;
  dynamic _parent;
  String _scriptPath;
}

// custom <part script>
// end <part script>
