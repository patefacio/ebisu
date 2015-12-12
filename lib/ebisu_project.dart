/// Provide consistency to creation of and dealing with ebisu project
library ebisu.ebisu_project;

import 'dart:io';
import 'package:ebisu/ebisu.dart';
import 'package:id/id.dart';
import 'package:path/path.dart';

// custom <additional imports>
// end <additional imports>

enum EbisuLanguage { ebisuCpp, ebisuPy, ebisuDart }

class EbisuProject {
  /// Id of the package
  Id get id => _id;

  /// Path to project
  String get path => _path;

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

  /// The contents of the pubspec file
  String get pubspec => _pubspec;

  // custom <class EbisuProject>

  /// Bootstrap this project into the [path] specified
  EbisuProject.bootstrap(this._id, this._languages, this._path) {}

  /// Construct the project from one existing at specified path
  EbisuProject.fromPath(this._path) {
    final projectName = basename(_path);
    if (projectName.startsWith('ebisu')) {
      _id = makeId(projectName);
    } else {
      throw new ArgumentError('$path does not look like an ebisu project');
    }
    _repoPath = findGitRepo(path);
    _readFiles();
  }

  get codegenPath => join(path, 'codegen');
  get codegenDir => new Directory(codegenPath);
  get binPath => join(path, 'bin');
  get binDir => new Directory(binPath);
  get testPath => join(path, 'test');
  get testDir => new Directory(testPath);
  get libPath => join(path, 'lib');
  get libDIr => new Directory(libPath);

  get _binScriptFiles =>
      binDir.listSync().where((fe) => fe is File && fe.path.endsWith('.dart'));

  get _testScriptFiles =>
      testDir.listSync().where((fe) => fe is File && fe.path.endsWith('.dart'));

  get _codegenScriptFiles => codegenDir
      .listSync()
      .where((fe) => fe is File && fe.path.endsWith('.dart'));

  _readFiles() {
    _codegenScripts = _codegenScriptFiles.map((s) => s.path).toList();
    _binScripts = _binScriptFiles.map((s) => s.path).toList();
  }

  toString() => brCompact([
        'EbisuProject(${id.snake}:repo($repoPath))',
        '  ------------------ Bin Scripts ------------------',
        indentBlock(brCompact(_binScripts.map((p) => basename(p)))),
        '  ------------------ Codegen Scripts ------------------',
        indentBlock(brCompact(_codegenScripts.map((p) => basename(p)))),
      ]);

  // end <class EbisuProject>

  Id _id;
  String _path;
  List<EbisuLanguage> _languages = [];
  List<String> _codegenScripts = [];
  List<String> _binScripts = [];
  List<String> _testScripts = [];
  String _repoPath;
  String _pubspec;
}

// custom <library ebisu_project>
// end <library ebisu_project>
