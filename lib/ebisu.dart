/// Primary library for client usage of ebisu
library ebisu;

import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:logging/logging.dart';
// custom <additional imports>
// end <additional imports>

part "src/ebisu/ebisu.dart";

final _logger = new Logger("ebisu");

/// Path to this package - for use until this becomes a pub package
final dynamic ebisuPath = Platform.environment['EBISU_PATH'];

/// Author of the generated code
final dynamic ebisuAuthor = Platform.environment['EBISU_AUTHOR'];

/// Hompage for pubspec
final dynamic ebisuHomepage = Platform.environment['EBISU_HOMEPAGE'];

dynamic licenseMap = {
   'boost' : 'License: <a href="http://www.boost.org/LICENSE_1_0.txt">Boost License 1.0</a>'
}
;

// custom <library ebisu>
// end <library ebisu>

