#!/usr/bin/env dart
/// Creates an ebisu setup
import 'dart:io';
import 'package:args/args.dart';
import 'package:ebisu/ebisu.dart' as ebisu;
import 'package:ebisu/ebisu_dart_meta.dart';
import 'package:id/id.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart';

//! The parser for this script
ArgParser _parser;
//! The comment and usage associated with this script
void _usage() {
  print(r'''
Creates an ebisu setup
''');
  print(_parser.getUsage());
}
//! Method to parse command line options.
//! The result is a map containing all options, including positional options
Map _parseArgs(List<String> args) {
  ArgResults argResults;
  Map result = {};
  List remaining = [];

  _parser = new ArgParser();
  try {
    /// Fill in expectations of the parser
    _parser.addFlag('help', help: r'''
Display this help screen
''', abbr: 'h', defaultsTo: false);

    _parser.addOption('project-path', help: r'''
Path to top level of desired ebisu project
''', defaultsTo: null, allowMultiple: false, abbr: 'p', allowed: null);
    _parser.addOption('log-level', help: r'''
Select log level from:
[ all, config, fine, finer, finest, info, levels,
  off, severe, shout, warning ]

''', defaultsTo: null, allowMultiple: false, abbr: null, allowed: null);

    /// Parse the command line options (excluding the script)
    argResults = _parser.parse(args);
    if (argResults.wasParsed('help')) {
      _usage();
      exit(0);
    }
    result['project-path'] = argResults['project-path'];
    result['help'] = argResults['help'];
    result['log-level'] = argResults['log-level'];

    if (result['log-level'] != null) {
      const choices = const {
        'all': Level.ALL,
        'config': Level.CONFIG,
        'fine': Level.FINE,
        'finer': Level.FINER,
        'finest': Level.FINEST,
        'info': Level.INFO,
        'levels': Level.LEVELS,
        'off': Level.OFF,
        'severe': Level.SEVERE,
        'shout': Level.SHOUT,
        'warning': Level.WARNING
      };
      final selection = choices[result['log-level'].toLowerCase()];
      if (selection != null) Logger.root.level = selection;
    }

    return {'options': result, 'rest': argResults.rest};
  } catch (e) {
    _usage();
    throw e;
  }
}
final _logger = new Logger('bootstrapEbisu');
class Project {
  Project._default();

  Id id;
  String rootPath;
  String codegenPath;
  String scriptName;
  String ebisuFilePath;

  // custom <class Project>

  Project(this.rootPath) {
    final rootPathBasename = basename(rootPath);
    id = idFromString(rootPathBasename);
    if (id.snake != basename(rootPath)) {
      throw 'Will only create snake name projects *not* $rootPathBasename';
    }
    codegenPath = join(rootPath, 'codegen');
    scriptName = '${id.snake}_ebisu';
    ebisuFilePath = join(codegenPath, scriptName);
  }

  bootstrap() {
    [rootPath, codegenPath].forEach((String dir) {
      if (!new Directory(dir).existsSync()) {
        print('Creating $dir');
      }
    });
    final ebisuScript = script(scriptName)
      ..scriptPath = codegenPath
      ..generate();
  }

  // end <class Project>

  toString() => '(${runtimeType}) => ${ebisu.prettyJsonMap(toJson())}';

  Map toJson() => {
    "id": ebisu.toJson(id),
    "rootPath": ebisu.toJson(rootPath),
    "codegenPath": ebisu.toJson(codegenPath),
    "scriptName": ebisu.toJson(scriptName),
    "ebisuFilePath": ebisu.toJson(ebisuFilePath),
  };

  static Project fromJson(Object json) {
    if (json == null) return null;
    if (json is String) {
      json = convert.JSON.decode(json);
    }
    assert(json is Map);
    return new Project._default().._fromJsonMapImpl(json);
  }

  void _fromJsonMapImpl(Map jsonMap) {
    id = Id.fromJson(jsonMap["id"]);
    rootPath = jsonMap["rootPath"];
    codegenPath = jsonMap["codegenPath"];
    scriptName = jsonMap["scriptName"];
    ebisuFilePath = jsonMap["ebisuFilePath"];
  }
}
main(List<String> args) {
  Logger.root.onRecord.listen(
      (LogRecord r) => print("${r.loggerName} [${r.level}]:\t${r.message}"));
  Logger.root.level = Level.OFF;
  Map argResults = _parseArgs(args);
  Map options = argResults['options'];
  List positionals = argResults['rest'];
  // custom <bootstrapEbisu main>

  String path = options['project-path'];
  if (path == null) {
    path = absolute(Directory.current.path);
  }

  final project = new Project(path);
  print(project);
  project.bootstrap();

  // end <bootstrapEbisu main>

}

// custom <bootstrapEbisu global>
// end <bootstrapEbisu global>
