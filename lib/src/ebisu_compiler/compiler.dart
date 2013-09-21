part of ebisu_compiler;

/// A file with ".tmpl" extension containing mixed dart code and text that can be "realized" by the template engine
class TemplateFile {

  TemplateFile(this.inputPath, { this.outputPath, this.partOf });

  /// Path to file containting template code
  String inputPath;
  /// Path to write the supporting dart file for the template
  String outputPath;
  /// Name of library this "part" is a part of
  String partOf;
  /// Each file is given a corresponding top level function for running the template
  String get functionName => _functionName;

// custom <class TemplateFile>

  bool compile() {

    if(inputPath == null) {
      throw new StateError(
        "You must set the inputPath on the TemplateFile to compile");
    }

    _functionName = path.basenameWithoutExtension(inputPath);

    if(outputPath == null) {
      outputPath = path.join(path.dirname(inputPath), 'src');

      new Directory(outputPath)
        ..createSync(recursive: true);
    }

    outputPath = path.join(outputPath, _functionName+'.dart');

    DateTime inputModtime = new File(inputPath).lastModifiedSync();
    DateTime outputModtime;

    File outfile = new File(outputPath);
    if(outfile.existsSync()) {
      outputModtime = outfile.lastModifiedSync();
    }

    if(null != outputModtime) {
      if(outputModtime.isBefore(inputModtime)) {
        compileImpl();
        return true;
      } 
    } else {
      compileImpl();
      return true;
    }
    return false;
  }

  void compileImpl() {
    bool inString = false;
    List<String> output = [];

    if(null != partOf) {
      output.add('part of $partOf;');
    }

    output.add('''

String ${_functionName}([dynamic _]) {
  if(_ is Map) {
    _ = new Context(_);
  }
  List<String> _buf = new List<String>();

''');
    openString() {
      if(!inString) {
          output.add("  _buf.add('''");
          inString = true;
      }
    }
    closeString() {
      if(inString) {
          output.add("''');");
          inString = false;
      }
    }
    File inFile = new File(inputPath);
    inFile.readAsLinesSync().forEach((line) {
      Match codeMatch = codeRe.firstMatch(line);
      if(codeMatch != null) {
        closeString();
        String code = codeMatch.group(1);
        if(null == commentRe.firstMatch(code)) {
          output.add("$code");
        }
      } else {
        openString();
        output.add(line);
      }
    });
    closeString();
    output.add('''  return _buf.join();\n}''');
    File outFile = new File(outputPath);
    outFile.writeAsStringSync(output.join('\n'));
  }

// end <class TemplateFile>
  String _functionName;
}

/// Create a TemplateFile sans new, for more declarative construction
TemplateFile templateFile(String inputPath,
    {
      String outputPath,
      String partOf
    }) {
  return new TemplateFile(inputPath,
      outputPath:outputPath,
      partOf:partOf);
}


/// A class to process a folder full of templates, 
/// all of which get compiled into a single dart library
class TemplateFolder {

  TemplateFolder(this.inputPath, [ this.outputPath, this.libName ]);

  /// Path to folder of templates
  String inputPath;
  /// Path to write the supporting dart files for the template folder
  String outputPath;
  /// Name of dart library to be generated
  String libName;
  /// List of imports required by the generated dart library
  List<String> imports = [];

// custom <class TemplateFolder>

  /// Compiles all files in the folder, returning number of files updated
  int compile() {

    if(inputPath == null) {
      throw new StateError(
        "You must set the inputPath on the TemplateFolder to compile");
    }

    if(outputPath == null) {
      outputPath = path.join(inputPath, 'src');

      new Directory(outputPath)
        ..createSync(recursive: true);
    }

    if(libName == null) {
      libName = path.basename(inputPath);
    }

    String libPath = path.join(path.dirname(inputPath), libName + '.dart');
    RegExp templateRe = new RegExp(r"\.tmpl$");
    Directory dir = new Directory(inputPath);
    int updateCount = 0;
    for(var file in dir.listSync()) {
      String p = file.path;
      if(null != templateRe.firstMatch(p)) {
        TemplateFile tFile = templateFile(p,
            outputPath: outputPath,
            partOf: libName);

        bool compiled = tFile.compile();
        if(compiled) {
          updateCount++;
          print("Compiled: $p => ${tFile.outputPath}");
        } else {
          print("No change: $p => ${tFile.outputPath}");
        }
      }
    }

    List<String> libContents = ['''
library $libName;

import "package:ebisu/ebisu.dart";
import "package:ebisu/ebisu_dart_meta.dart";
'''];

    if(null != imports) {
      for(String imp in imports) {
        libContents.add(importStatement(imp));
      }
    }

    dir = new Directory(outputPath);
    RegExp dartRe = new RegExp(r"\.dart$");
    for(var file in dir.listSync()) {
      String p = file.path;
      if(null != dartRe.firstMatch(p)) {
        String relPath = path.relative(p, from: path.dirname(libPath));
        libContents.add('part "$relPath";');
      }
    }

    bool libUpdated = mergeWithFile(libContents.join("\n"), libPath);
    if(libUpdated) {
      updateCount++;
    }

    return updateCount;
  }


// end <class TemplateFolder>
}
// custom <part compiler>
// end <part compiler>

