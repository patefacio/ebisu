/// Provide consistency to creation of and dealing with ebisu project
library ebisu.ebisu_project;

import 'dart:io';
import 'package:ebisu/ebisu.dart';
import 'package:ebisu/ebisu_dart_meta.dart';
import 'package:id/id.dart';
import 'package:path/path.dart';
import 'package:yaml/yaml.dart';

// custom <additional imports>
// end <additional imports>

enum EbisuLanguage { ebisuCpp, ebisuPy, ebisuDart }

/// Represents an ebisu project
class EbisuProject {
  /// Id of the package
  Id get id => _id;

  /// Pubspec version of the package
  String get version => _version;

  /// Languages the project has ebisu scripts for
  List<EbisuLanguage> get languages => _languages;

  /// Scripts found in the codegen directory
  List<String> get codegenScripts => _codegenScripts;

  /// Scripts found in the bin directory
  List<String> get binScripts => _binScripts;

  /// Scripts found in the test directory
  List<String> get testScripts => _testScripts;

  /// Path to repo - should be same as project path
  String get repoPath => _repoPath;

  /// Path to project within repo
  String get projectPath => _projectPath;

  /// The contents of the pubspec file
  String get pubspec => _pubspec;

  // custom <class EbisuProject>

  /// Bootstrap this project into the [path] specified
  EbisuProject.bootstrap(this._id, this._languages, String path) {
    _projectPath = join(path, id.snake);
    _repoPath = findGitRepo(_projectPath);
    if (_repoPath == null) {
      _repoPath = _projectPath;
    }
    regenProject();
    final hasGit = findGitRepo(repoPath);
    if (hasGit == null) {
      print('Doing git init on $repoPath');
      final stash = Directory.current;
      Directory.current = repoPath;
      final result = Process.runSync('git', ['init']);
      print('Result(${result.exitCode}): ${result.stdout}');
      Directory.current = stash;
    }

    final pubspecFile = new File(join(projectPath, 'pubspec.yaml'));
    if (!pubspecFile.existsSync()) {
      pubspecFile.writeAsStringSync((new PubSpec(id)
            ..name = id.snake
            ..version = '0.0.0')
          .content);
    }
  }

  /// Construct the project from one existing at specified path
  EbisuProject.fromPath(this._projectPath) {
    _repoPath = findGitRepo(_projectPath);
    final projectName = basename(_projectPath);
    _id = makeId(projectName);
    _readFiles();
    if (codegenScripts.isEmpty) {
      throw new ArgumentError(
          '$_projectPath does not look like an ebisu project - no codegen scripts');
    }
  }

  get codegenPath => join(_projectPath, 'codegen');
  get codegenDir => new Directory(codegenPath);
  get binPath => join(_projectPath, 'bin');
  get binDir => new Directory(binPath);
  get testPath => join(_projectPath, 'test');
  get testDir => new Directory(testPath);
  get libPath => join(_projectPath, 'lib');
  get libDIr => new Directory(libPath);

  Iterable<FileSystemEntity> get _binScriptFiles => binDir.existsSync()
      ? binDir.listSync().where((fe) => fe is File && fe.path.endsWith('.dart'))
      : [];

  Iterable<FileSystemEntity> get _testScriptFiles => testDir.existsSync()
      ? testDir
          .listSync()
          .where((fe) => fe is File && fe.path.endsWith('.dart'))
      : [];

  Iterable<FileSystemEntity> get _codegenScriptFiles => codegenDir
      .listSync()
      .where((fe) => fe is File && fe.path.endsWith('.dart'));

  _readFiles() {
    _codegenScripts = _codegenScriptFiles.map((s) => s.path).toList();
    _binScripts = _binScriptFiles.map((s) => s.path).toList();
    _testScripts = _testScriptFiles.map((s) => s.path).toList();
    var pubspec = loadYaml(
        new File(join(projectPath, 'pubspec.yaml')).readAsStringSync());
    _version = pubspec['version'];
    _readLanguages();
  }

  String get title => '$id(version=$version)';

  toString() => brCompact([
        'EbisuProject(${id.snake}:repo($repoPath))',
        '  ------------------ Bin Scripts ------------------',
        indentBlock(brCompact(_binScripts.map((p) => basename(p)))),
        '  ------------------ Codegen Scripts ------------------',
        indentBlock(brCompact(_codegenScripts.map((p) => basename(p)))),
      ]);

  runTests() {
    final runner = new File(join(testPath, 'runner.dart'));
    if (!runner.existsSync()) {
      throw 'Could not run tests - $runner does not exist';
    }
    final result = Process.runSync('dart', [runner.path]);
    print(result.stdout);
  }

  runCodegen() {
    for (var codegenScript in codegenScripts) {
      final result = Process.runSync('dart', [codegenScript]);
      print(result.stdout);
    }
  }

  regenProject() {
    if (languages.contains(EbisuLanguage.ebisuDart)) {
      print('Regening Dart codegen script');

      script(id.snake + '_ebisu_dart')
        ..basename = '${id.snake}.ebisu_dart.dart'
        ..scriptPath = join(projectPath, 'codegen')
        ..customCodeBlock.hasSnippetsFirst = true
        ..customCodeBlock.snippets.add('''
useDartFormatter = true;
String here = absolute(Platform.script.toFilePath());
''')
        ..imports.addAll([
          'package:ebisu/ebisu.dart',
          'package:ebisu/ebisu_dart_meta.dart',
          'package:path/path.dart',
        ])
        ..generate();
    }

    if (languages.contains(EbisuLanguage.ebisuCpp)) {
      print('Regening C++ codegen script');

      script(id.snake + '_ebisu_cpp')
        ..basename = '${id.snake}.ebisu_cpp.dart'
        ..scriptPath = join(projectPath, 'codegen')
        ..customCodeBlock.hasSnippetsFirst = true
        ..customCodeBlock.snippets.add('''
useDartFormatter = true;
String here = absolute(Platform.script.toFilePath());
''')
        ..imports.addAll([
          'package:ebisu/ebisu.dart',
          'package:ebisu_cpp/ebisu_cpp.dart',
          'package:path/path.dart',
        ])
        ..generate();
    }
  }

  runGitStatus() {
    final result = Process.runSync('git', [
      '--git-dir=${repoPath}/.git',
      '--work-tree=${repoPath}',
      'status',
      '-s'
    ]);
    print(result.stdout);
  }

  runGitLsFiles() {
    final result = Process.runSync('git', [
      '--git-dir=${repoPath}/.git',
      '--work-tree=${repoPath}',
      'ls-files',
    ]);
    print(result.stdout.split('\n').map((l) => join(repoPath, l)).join('\n'));
  }

  _readLanguages() {
    for (var codegenScript in codegenScripts) {
      final script = basename(codegenScript);
      if (script.endsWith('ebisu_dart.dart')) {
        _languages.add(EbisuLanguage.ebisuDart);
      } else if (script.endsWith('ebisu_py.dart')) {
        _languages.add(EbisuLanguage.ebisuPy);
      } else if (script.endsWith('ebisu_cpp.dart')) {
        _languages.add(EbisuLanguage.ebisuCpp);
      }
    }
  }

  // end <class EbisuProject>

  Id _id;
  String _version;
  List<EbisuLanguage> _languages = [];
  List<String> _codegenScripts = [];
  List<String> _binScripts = [];
  List<String> _testScripts = [];
  String _repoPath;
  String _projectPath;
  String _pubspec;
}

// custom <library ebisu_project>
// end <library ebisu_project>
