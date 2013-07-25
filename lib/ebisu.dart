/// Primary library for client usage of ebisu
library ebisu;

import "dart:io";
import "package:pathos/path.dart" as path;
part "src/ebisu/ebisu.dart";

// Path to this package - for use until this becomes a pub package
final dynamic ebisuPath = Platform.environment['EBISU_PATH'];

// Author of the generated code
final dynamic ebisuAuthor = Platform.environment['EBISU_AUTHOR'];

// Hompage for pubspec
final dynamic ebisuHomepage = Platform.environment['EBISU_HOMEPAGE'];

// custom <library ebisu>
// end <library ebisu>

