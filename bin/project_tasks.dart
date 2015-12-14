#!/usr/bin/env dart

/// This script performs tasks (e.g. run tests, regenerate code) on specified ebisu
/// projects
///
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
This script performs tasks (e.g. run tests, regenerate code) on specified ebisu
projects

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
    _parser.addFlag('git-status',
        help: r'''
Run *git status* on all the projects
''',
        abbr: 's',
        defaultsTo: false);
    _parser.addFlag('run-tests',
        help: r'''
Run tests on the projects
''',
        abbr: 't',
        defaultsTo: false);
    _parser.addFlag('codegen',
        help: r'''
Regenerate the code
''',
        abbr: 'g',
        defaultsTo: false);
    _parser.addFlag('regen-project',
        help: r'''
Regenerate the project itself
''',
        abbr: null,
        defaultsTo: false);
    _parser.addFlag('help',
        help: r'''
Display this help screen
''',
        abbr: 'h',
        defaultsTo: false);

    _parser.addOption('project-path',
        help: r'''
Path to a file or directory within a project.
If no paths are specified the proejct of the current directory is assumed.

''',
        defaultsTo: null,
        allowMultiple: true,
        abbr: 'p',
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
    result['project-path'] = argResults['project-path'];
    result['git-status'] = argResults['git-status'];
    result['run-tests'] = argResults['run-tests'];
    result['codegen'] = argResults['codegen'];
    result['regen-project'] = argResults['regen-project'];
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

final _logger = new Logger('projectTasks');

main(List<String> args) {
  Logger.root.onRecord.listen(
      (LogRecord r) => print("${r.loggerName} [${r.level}]:\t${r.message}"));
  Logger.root.level = Level.OFF;
  Map argResults = _parseArgs(args);
  Map options = argResults['options'];
  List positionals = argResults['rest'];
  // custom <projectTasks main>

  List projectPaths = options['project-path'].isEmpty
      ? [Directory.current.path]
      : options['project-path'];

  for (var path in projectPaths) {
    final ebisuProject = new EbisuProject.fromPath(path);

    if (options['run-tests']) {
      print(
          '------------------ Running (${ebisuProject.title}) tests -----------------');
      ebisuProject.runTests();
    }

    if (options['codegen']) {
      print(
          '------------------ Running (${ebisuProject.title}) codegen -----------------');
      ebisuProject.runCodegen();
    }

    if (options['git-status']) {
      print(
          '------------------ Running (${ebisuProject.title}) codegen -----------------');
      ebisuProject.runGitStatus();
    }

    if (options['regen-project']) {
      print(
          '------------------ Regenning (${ebisuProject.title}) -----------------');
      ebisuProject.regenProject();
    }
  }

  // end <projectTasks main>
}

// custom <projectTasks global>
// end <projectTasks global>
