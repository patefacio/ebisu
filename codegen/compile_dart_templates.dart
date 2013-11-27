import "dart:io";
import "package:path/path.dart" as path;
import "package:ebisu/ebisu.dart";
import "package:ebisu/ebisu_id.dart";
import "package:ebisu/ebisu_compiler.dart";

main() {
  Options options = new Options();
  String here = path.absolute(options.script);
  bool noCompile = options.arguments.contains('--no_compile');
  bool compileOnly = options.arguments.contains('--compile_only');
  String topDir = path.dirname(path.dirname(here));
  String templateFolderPath =
    path.join(topDir, 'lib', 'templates', 'dart_meta');
  if(! (new Directory(templateFolderPath).existsSync())) {
    throw new StateError(
        "Could not find ebisu templates in $templateFolderPath");
  }

  if(!noCompile) {
    TemplateFolder templateFolder = new TemplateFolder(templateFolderPath);
    int filesUpdated = templateFolder.compile();
  }
}
