#!/usr/bin/env dart

/// Bootstrap new ebisu project
import 'dart:io';
import 'package:args/args.dart';
import 'package:ebisu/ebisu.dart';
import 'package:ebisu/ebisu_project.dart';
import 'package:id/id.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart';

// custom <additional imports>
// end <additional imports>
//! The parser for this script
ArgParser _parser;
//! The comment and usage associated with this script
void _usage() {
  print(r'''
Bootstrap new ebisu project
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
    _parser.addFlag('dart',
        help: r'''
Include dart codegen script
''',
        abbr: null,
        defaultsTo: false);
    _parser.addFlag('cpp',
        help: r'''
Include cpp codegen script
''',
        abbr: null,
        defaultsTo: false);
    _parser.addFlag('py',
        help: r'''
Include python codegen script
''',
        abbr: null,
        defaultsTo: false);
    _parser.addFlag('help',
        help: r'''
Display this help screen
''',
        abbr: 'h',
        defaultsTo: false);

    _parser.addOption('parent-path',
        help: r'''
Path to directory into which project directory will be created
''',
        defaultsTo: null,
        allowMultiple: false,
        abbr: null,
        allowed: null);
    _parser.addOption('project-id',
        help: r'''
Id for the project
''',
        defaultsTo: null,
        allowMultiple: false,
        abbr: null,
        allowed: null);
    _parser.addOption('log-level',
        help: r'''
Select log level from:
[ all, config, fine, finer, finest, info, levels,
  off, severe, shout, warning ]

''',
        defaultsTo: null,
        allowMultiple: false,
        abbr: null,
        allowed: null);

    /// Parse the command line options (excluding the script)
    argResults = _parser.parse(args);
    if (argResults.wasParsed('help')) {
      _usage();
      exit(0);
    }
    result['parent-path'] = argResults['parent-path'];
    result['project-id'] = argResults['project-id'];
    result['dart'] = argResults['dart'];
    result['cpp'] = argResults['cpp'];
    result['py'] = argResults['py'];
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

final _logger = new Logger('createEbisuProject');

main(List<String> args) {
  Logger.root.onRecord.listen(
      (LogRecord r) => print("${r.loggerName} [${r.level}]:\t${r.message}"));
  Logger.root.level = Level.OFF;
  Map argResults = _parseArgs(args);
  Map options = argResults['options'];
  List positionals = argResults['rest'];
  try {
    if (options["parent-path"] == null)
      throw new ArgumentError("option: parent-path is required");
    if (options["project-id"] == null)
      throw new ArgumentError("option: project-id is required");
  } on ArgumentError catch (e) {
    print(e);
    _usage();
    exit(-1);
  }
  // custom <createEbisuProject main>

  List languages = [];
  if (options['dart']) languages.add(EbisuLanguage.ebisuDart);
  if (options['cpp']) languages.add(EbisuLanguage.ebisuCpp);
  if (options['py']) languages.add(EbisuLanguage.ebisuPy);

  final parentPath = options['parent-path'];
  final projectId = makeId(options['project-id']);
  new EbisuProject.bootstrap(projectId, languages, options['parent-path']);
  final targetPath = join(parentPath, projectId.snake);
  final gitRepo = findGitRepo(targetPath);
  print(new EbisuProject.fromPath(targetPath));

  // end <createEbisuProject main>
}

// custom <createEbisuProject global>
// end <createEbisuProject global>
