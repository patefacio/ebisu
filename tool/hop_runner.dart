library hop_runner;

import 'dart:async';
import 'dart:io';
import 'package:hop/hop.dart';
import "package:path/path.dart" as PATH;
import 'package:hop/hop_tasks.dart';
import '../test/utils.dart';
import '../test/runner.dart' as runner;

void main() {

  Directory.current = packageRootPath;

  addTask('analyze_lib', createAnalyzerTask(_getLibs));
  addTask('docs', createDartDocTask(_getLibs));
  addTask('analyze_test', 
      createAnalyzerTask([
        "test/test_code_generation.dart"
      ]));

  addTask('test', createUnitTestTask(runner.testCore));

  runHop();
}

Future<List<String>> _getLibs() {
  return new Directory('lib').list()
      .where((FileSystemEntity fse) => fse is File)
      .map((File file) => file.path)
      .toList();
}
