/// 
/// Support for consistent use of identifiers.  Identifiers are words used to create
/// things like class names, variable names, function names, etc. Because different
/// outputs will want different case conventions for different contexts, using the
/// Id class allows a simple consistent input format (snake case) to be combined
/// with the appropriate conventions (usually via templates) to produce consistent
/// correct naming. Most ebisu entities are named (Libraries, Parts, Classes, etc).
/// 
/// 
library ebisu_id;

import "dart:io";
import "package:ebisu/ebisu.dart";
import "package:pathos/path.dart" as path;
import "ebisu_utils.dart" as EBISU_UTILS;
part "src/ebisu_id/id.dart";

// custom <library ebisu_id>
// end <library ebisu_id>

