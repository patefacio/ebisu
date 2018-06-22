///
/// Support for storing dart meta data for purpose of generating *Dart*
/// code. Essentially this is a model of structural code items that comprise dart
/// systems. Things like libraries (Library), classes (Class), class members
/// (Member), pubspecs (PubSpec), etc. A very nice feature of Dart is the dot-dot
/// _.._ operator, which allows one to conveniently string together accessor calls
/// to objects. For example, the following is the structure of the imported id
/// library.
///
///       library_('id')
///       ..doc = '...'
///       ..includesLogger = true
///       ..imports = [
///         'dart:convert'
///       ]
///       ..classes = [
///         class_('id')
///         ..doc = "Given an id (all lower case string of words separated by '_')..."
///         ..hasCtorSansNew = true
///         ..members = [
///           member('id')
///           ..doc = "String containing the lower case words separated by '_'"
///           ..access = Access.RO
///           ..isFinal = true,
///           member('words')
///           ..doc = "Words comprising the id"
///           ..type = 'List<String>'
///           ..access = Access.RO
///           ..isFinal = true
///         ]
///       ]
///     ];
///
///
/// The libraries are composed into a system and the system is generated. So, all
/// the code structure in ebisu was generated by itself. Code generation of this
/// sort is much more useful in the more verbose languages like C++ where things
/// like ORM, object serialization, object streaming etc are very
/// boilerplate. However some good use cases exist in Dart, like generating the
/// structure of a large Dart library from an existing spec or data input
/// (e.g. imagine trying to create a Dart library to support a FIX specification
/// which is stored in XML). A simple use that is provided as an extension is the
/// ability take a simple Altova UML model in XMI format and convert it to Dart
/// classes with JSON support.
library ebisu.ebisu_dart_meta;

import 'dart:convert' as convert;
import 'dart:io';
import 'package:ebisu/ebisu.dart';
import 'package:id/id.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart';
import 'package:quiver/iterables.dart';

// custom <additional imports>
// end <additional imports>

part 'src/ebisu_dart_meta/annotation.dart';
part 'src/ebisu_dart_meta/app.dart';
part 'src/ebisu_dart_meta/benchmark.dart';
part 'src/ebisu_dart_meta/class.dart';
part 'src/ebisu_dart_meta/dart_meta.dart';
part 'src/ebisu_dart_meta/drudge_support.dart';
part 'src/ebisu_dart_meta/emacs_support.dart';
part 'src/ebisu_dart_meta/enum.dart';
part 'src/ebisu_dart_meta/library.dart';
part 'src/ebisu_dart_meta/part.dart';
part 'src/ebisu_dart_meta/pub.dart';
part 'src/ebisu_dart_meta/script.dart';
part 'src/ebisu_dart_meta/system.dart';
part 'src/ebisu_dart_meta/variable.dart';

final Logger _logger = new Logger('ebisu_dart_meta');

List<String> _nonJsonableTypes = [
  'String',
  'int',
  'double',
  'bool',
  'num',
  'Map',
  'List',
  'DateTime',
  'dynamic',
];

// custom <library ebisu_dart_meta>

/// Returns true if the class name alone indicates the type may be convertible
/// to json
bool isClassJsonable(String className) =>
    !_nonJsonableTypes.contains(className) &&
    !className.startsWith('Map<') &&
    !className.startsWith('List<');

/// Given a list of [dirtyImports], cleans them up and removes duplicates
///
List<String> cleanImports(List<String> dirtyImports) {
  List<String> result = [];
  var hit = new Set<String>();
  dirtyImports.forEach((i) {
    i = i.replaceAll('"', "'");
    if (hit.contains(i)) return;
    hit.add(i);
    result.add(i);
  });
  result.sort();
  return result;
}

// end <library ebisu_dart_meta>
