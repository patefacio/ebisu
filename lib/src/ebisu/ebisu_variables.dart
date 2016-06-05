/// Variables used by ebisu when generating Dart code.
part of ebisu.ebisu;

// custom <part ebisu_variables>
// end <part ebisu_variables>

/// Path to this package - for use until this becomes a pub package
final String ebisuPath = Platform.environment['EBISU_PATH'];

/// Author of the generated code
final String ebisuAuthor = Platform.environment['EBISU_AUTHOR'];

/// Hompage for pubspec
final String ebisuHomepage = Platform.environment['EBISU_HOMEPAGE'];

/// File containing default pub versions. Dart code generation at times
/// generates code that requires packages.
///
final String ebisuPubVersions =
    (Platform.environment['EBISU_PUB_VERSIONS'] != null)
        ? Platform.environment['EBISU_PUB_VERSIONS']
        : "${Platform.environment['HOME']}/.ebisu_pub_versions.json";
Map<String, String> licenseMap = {
  'boost':
      'License: <a href="http://www.boost.org/LICENSE_1_0.txt">Boost License 1.0</a>',
  'mit':
      'License: <a href="http://opensource.org/licenses/MIT">MIT License</a>',
  'apache-2.0':
      'License: <a href="http://opensource.org/licenses/Apache-2.0">Apache License 2.0</a>',
  'bsd-3':
      'License: <a href="http://opensource.org/licenses/BSD-3-Clause">BSD 3-Clause "Revised"</a>',
  'bsd-2':
      'License: <a href="http://opensource.org/licenses/BSD-2-Clause">BSD 2-Clause</a>',
  'mozilla-2.0':
      'License: <a href="http://opensource.org/licenses/MPL-2.0">Mozilla Public License 2.0 </a>',
};
