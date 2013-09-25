/// Primary library for client usage of ebisu
library ebisu;

import 'dart:io';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as path;
// custom <additional imports>
// end <additional imports>

part 'src/ebisu/ebisu.dart';

final _logger = new Logger("ebisu");

/// Path to this package - for use until this becomes a pub package
final String ebisuPath = Platform.environment['EBISU_PATH'];

/// Author of the generated code
final String ebisuAuthor = Platform.environment['EBISU_AUTHOR'];

/// Hompage for pubspec
final String ebisuHomepage = Platform.environment['EBISU_HOMEPAGE'];

/// File containing default pub versions. Dart code generation at times
/// generates code that requires packages. For example, generated
/// test cases require unittest, generated code can require logging,
/// hop support requries hop. Since the pubspec yaml is generated
/// the idea here is to pull the versions of these packages out of 
/// the code and into a config file. Then to upgrade multiple packages
/// with multiple pubspecs would entail updating the config file and
/// regenerating.
///
final String ebisuPubVersions = (Platform.environment['EBISU_PUB_VERSIONS'] != null) ?
  Platform.environment['EBISU_PUB_VERSIONS'] :
  "${Platform.environment['HOME']}/.ebisu_pub_versions.json";

Map<String,String> licenseMap = {
   'boost' : 'License: <a href="http://www.boost.org/LICENSE_1_0.txt">Boost License 1.0</a>'
};

// custom <library ebisu>
// end <library ebisu>

