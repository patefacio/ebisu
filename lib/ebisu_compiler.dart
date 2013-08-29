/// 
/// Supports generating dart code from template files.  A choice had to be made
/// about a templating system. Originally dart had a library to support templates
/// but it was later abandoned in preference for a new approach (_Web UI_) that does
/// much more than just templating as it is a very web specific solution. Mustache
/// is another good option, but for code generation the arguments for separating
/// templates and logic fall apart (the coders are the ones writing the templates to
/// make their life of coding easier). Rather than try to incorporate one in NIH/DIY
/// fashion a very simple template engine is provided here. The rules for templating
/// are simple:
/// 
/// - Template file is line based (each line is a comment, code or template text)
/// - _#<# dart comment here >_
/// - _#< dart code here >_
/// - All template text is wrapped in tripple quotes.
/// 
/// 
/// 
library ebisu_compiler;

import "dart:io";
import "package:ebisu/ebisu.dart";
import "package:ebisu/ebisu_dart_meta.dart";
import "package:path/path.dart" as path;
part "src/ebisu_compiler/compiler.dart";

/// Regex to match a single line if dart code (i.e. in looks like #< ... >)
final RegExp codeRe = new RegExp("^#<(.*)>\\s*");

/// Regex to match the comment portion of a comment line (i.e. in looks like #<# ... >)
final RegExp commentRe = new RegExp("^\\s*#");

// custom <library ebisu_compiler>
// end <library ebisu_compiler>

