/// Support for generating a drudge script to auto-run codegen files
part of ebisu.ebisu_dart_meta;

class DrudgeScriptGenerator {
  System get system => _system;

  // custom <class DrudgeScriptGenerator>

  DrudgeScriptGenerator(this._system);

  get _ebisuDartScript => relative(absolute(Platform.script.toFilePath()),
      from: join(_system.rootPath, 'bin'));

  get _libPath =>
      relative(join(_system.rootPath, 'lib'), from: dirname(_ebisuDartScript));

  get _testPath =>
      relative(join(_system.rootPath, 'test'), from: dirname(_ebisuDartScript));

  get contents => brCompact([
        """
import 'package:drudge/drudge.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart';
import 'dart:io';

final _logger = new Logger('drudge_${system.id.snake}');

main() {
  String ebisuScript = '$_ebisuDartScript';
  String libPath = '$_libPath';
  String testPath = '$_testPath';
  String here = absolute(Platform.script.toFilePath());

  Logger.root.onRecord.listen(
      (LogRecord r) => print("\${r.loggerName} [\${r.level}]:\t\${r.message}"));
  Logger.root.level = Level.FINE;

  _logger.info('''
Drudge(\$here)
  libPath: \$libPath
  testPath: \$testPath
''');

  driver([
    fileSystemEventRunner(
        changeSpec(FileSystemEvent.ALL, [ebisuScript]),
        recipe('regenerate', [
          command('regenerate', 'dart', [ ebisuScript ]),
        ])),
    fileSystemEventRunner(
        changeSpec(FileSystemEvent.ALL, [ libPath ]),
        recipe('run_tests', [
          command('run_tests', 'dart', [ join(testPath, 'runner.dart') ]),
        ]))
  ]).run();

}

"""
      ]);

  // end <class DrudgeScriptGenerator>

  System _system;
}

// custom <part drudge_support>
// end <part drudge_support>
