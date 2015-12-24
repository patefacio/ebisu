library ebisu.test_ebisu_project;

import 'package:ebisu/ebisu.dart';
import 'package:logging/logging.dart';
import 'package:test/test.dart';

// custom <additional imports>

import 'dart:io';
import 'package:ebisu/ebisu_project.dart';
import 'package:path/path.dart';

// end <additional imports>

final _logger = new Logger('test_ebisu_project');

// custom <library test_ebisu_project>
// end <library test_ebisu_project>

main([List<String> args]) {
  Logger.root.onRecord.listen(
      (LogRecord r) => print("${r.loggerName} [${r.level}]:\t${r.message}"));
  Logger.root.level = Level.OFF;
// custom <main>

  String root = dirname(dirname(absolute(Platform.script.toFilePath())));

  test('read current ebisu project', () {
    final project = new EbisuProject.fromPath(root);
    expect(project.codegenScripts.map((f) => basename(f)).toList(),
        ['ebisu.ebisu_dart.dart']);
    expect(
        project.testScripts
            .map((f) => basename(f))
            .contains('test_ebisu_project.dart'),
        true);
    expect(
        project.binScripts
            .map((f) => basename(f))
            .contains('project_tasks.dart'),
        true);
  });

// end <main>
}
