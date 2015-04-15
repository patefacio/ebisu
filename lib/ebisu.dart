/// Library with common utilities for generating code.
///
/// The *ebisu* package has two primary libraries with following focus:
///
/// - *ebisu.dart* Assist in generating source text in code generation
/// - *ebisu_dart_meta.dart* Assist in generating *Dart* source code
///
///
library ebisu.ebisu;

import 'dart:convert' as convert;
import 'dart:io';
import 'dart:math';
import 'package:dart_style/dart_style.dart';
import 'package:id/id.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as path;
import 'package:quiver/iterables.dart';
// custom <additional imports>

// end <additional imports>

part 'src/ebisu/ebisu.dart';

final _logger = new Logger('ebisu');

/// Mixin to provide a common approach to adding custom code
class CustomCodeBlock {

  /// A custom code block for a class
  set customCodeBlock(CodeBlock customCodeBlock) =>
      _customCodeBlock = customCodeBlock;

  // custom <class CustomCodeBlock>

  bool get includesCustom => _customCodeBlock != null;

  set includesCustom(bool ic) {
    if (ic) {
      _initCustomBlock();
    } else {
      _logger.warning('Turning custom code off for $runtimeType');
      _customCodeBlock = null;
    }
  }

  CodeBlock get customCodeBlock => _initCustomBlock();

  CodeBlock _initCustomBlock() {
    if (_customCodeBlock == null) {
      _customCodeBlock = new CodeBlock(null);
    }
    return _customCodeBlock;
  }

  taggedBlockText(String tag) => (customCodeBlock..tag = tag).toString();

  //_copyCodeBlock(String tag) =>

  // end <class CustomCodeBlock>

  CodeBlock _customCodeBlock;
}

/// Wraps an optional protection block with optional code injection
///
/// [CodeBlock]s have two functions, they provide an opportunity
/// to include hand written code with a protection block and they
/// provide specific target locations for injecting generated code.
///
/// For contrived example, assume there were two variables, *topCodeBlock*
/// and *bottomCodeBlock* of type CodeBlock and they were used in a
/// context like this:
///
///     """
///     class Imaginary {
///       ${topCodeBlock}
///     ....
///       ${bottomCodeBlock}
///     }
///     """
///
/// The generated text might look like:
///     """
///     class Imaginary {
///       /// custom begin top
///       /// custom end top
///     ....
///       /// custom begin bottom
///       /// custom end bottom
///     }
///     """
///
/// Now assume a code generator needed to inject into the top portion
/// something specific to the class, like a versionId stored in a file and
/// available during code generation:
///
///     topCodeBlock
///     .snippets
///     .add("versionId = ${new File(version.txt).readAsStringSync()}")
///
/// the newly generated code might look like:
///
///     """
///     class Imaginary {
///       /// custom begin top
///       /// custom end top
///       versionId = "0.1.21";
///     ...
///       /// custom begin bottom
///       /// custom end bottom
///     }
///     """
///
/// and adding:
///
///     topCodeBlock.hasSnippetsFirst = true
///
/// would give:
///
///     """
///     class Imaginary {
///       versionId = "0.1.21";
///       /// custom begin top
///       /// custom end top
///     ...
///       /// custom begin bottom
///       /// custom end bottom
///     }
///     """
///
///
class CodeBlock {
  CodeBlock(this.tag);

  /// Tag for protect block. If present includes protect block
  String tag;
  /// Effecitively a hook to throw in generated text
  List<String> snippets = [];
  /// Determines whether the injected code snippets come before the
  /// protection block or after
  bool hasSnippetsFirst = false;

  // custom <class CodeBlock>

  bool get hasTag => tag != null && tag.length > 0;

  String toString() {
    if (hasTag) {
      return hasSnippetsFirst
          ? br([snippets, customBlock(tag)])
          : br([customBlock(tag)]..addAll(snippets));
    }
    return combine(snippets);
  }

  // end <class CodeBlock>

}

/// Create a CodeBlock sans new, for more declarative construction
CodeBlock codeBlock([String tag]) => new CodeBlock(tag);

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
final String ebisuPubVersions = (Platform.environment['EBISU_PUB_VERSIONS'] !=
        null)
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
// custom <library ebisu>

bool _toJsonRequired(final object) {
  if (object is num) {
    return false;
  } else if (object is bool) {
    return false;
  } else if (object == null) {
    return false;
  } else if (object is String) {
    return false;
  } else if (object is List) {
    return false;
  } else if (object is Map) {
    return false;
  } else if (object is DateTime) {
    return false;
  }

  return true;
}

dynamic toJson(final dynamic obj) {
  if (_toJsonRequired(obj)) {
    return obj.toJson();
  } else {
    if (obj is Map) {
      Map result = {};
      obj.forEach((k, v) => result[k.toString()] = toJson(v));
      return result;
    } else if (obj is List) {
      List result = [];
      obj.forEach((e) => result.add(toJson(e)));
      return result;
    } else if (obj is DateTime) {
      return (obj == null) ? null : '${obj.toString()}';
    } else {
      return obj;
    }
  }
}

final _sourceChars =
    r'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ~!@#$%^&*+;,';
final _randGenerator = new Random(0);
final _maxRandInt = 1 << 31;

/// Creates a string of random length capped at _maxLen_
String randString([Random generator, int maxLen = 10]) {
  if (generator == null) generator = _randGenerator;
  int numChars = generator.nextInt(maxLen) + 1;
  var chars = new List<int>(numChars);
  for (var i = 0; i < numChars; i++) {
    chars[i] = _sourceChars.codeUnitAt(generator.nextInt(_sourceChars.length));
  }
  return new String.fromCharCodes(chars);
}

/// Creates a Map<String, dynamic> of random length capped at _maxLen_ where
/// keys are random strings, optionally prefixed with _tag_ and values are built
/// from the supplied _valueBuilder_.
dynamic randJsonMap([Random generator, dynamic valueBuilder, String tag = '',
    int maxLen = 10]) {
  Map result = {};
  if (generator == null) generator = _randGenerator;
  int numEntries = generator.nextInt(maxLen) + 1;
  for (var i = 0; i < numEntries; i++) {
    String key = (tag.length > 0
        ? "${tag} <${randString(generator)}>"
        : randString(generator));
    result[key] = valueBuilder();
  }
  return result;
}

dynamic randGeneralMap(keyGenerator(),
    [Random generator, dynamic valueBuilder, int maxLen = 10]) {
  Map result = {};
  if (generator == null) generator = _randGenerator;
  int numEntries = generator.nextInt(maxLen) + 1;
  for (var i = 0; i < numEntries; i++) {
    String key = keyGenerator();
    result[key] = valueBuilder();
  }
  return result;
}

dynamic randJson(Random generator, var obj, [final dynamic type]) {
  if (obj is List) {
    List result = [];
    new List(generator.nextInt(6) + 1).forEach((i) {
      result.add(type());
    });
    return result;
  } else if (obj is Map) {
    Map result = {};
    new List(generator.nextInt(4) + 1).forEach((i) {
      result[generator.nextInt(_maxRandInt).toString()] = type;
    });
    return result;
  } else if (obj is Function) {
    return obj();
  } else {
    if (obj == null) return null;
    switch (obj) {
      case num:
        return generator.nextInt(_maxRandInt);
      case double:
        return generator.nextInt(_maxRandInt) * generator.nextDouble();
      case int:
        return generator.nextInt(_maxRandInt);
      case String:
        return randString(generator);
      case bool:
        return 0 == (generator.nextInt(_maxRandInt) % 2);
      case DateTime:
        return new DateTime(1900 + generator.nextInt(150),
            generator.nextInt(12) + 1, generator.nextInt(31) + 1).toString();
      default:
        {
          return obj.randJson();
        }
    }
  }
}

/// Given an [item] of an assumed nested structure consistent with the result of
/// json parse, iterate over the objects and pretty print them to a String
String prettyJsonMap(dynamic item,
    [String indent = "", bool showCount = false]) {
  List<String> result = new List<String>();
  if (item is Map) {
    result.add('{\n');
    var guts = new List<String>();
    var keys = new List<dynamic>.from(item.keys);
    keys.sort();
    int count = 0;
    keys.forEach((k) {
      String countTxt = showCount ? "(${++count})-" : "";
      guts.add(
          '  ${indent}$countTxt"${k}": ${prettyJsonMap(item[k], "$indent  ", showCount)}');
    });
    result.add(guts.join(',\n'));
    result.add('\n$indent}');
  } else if (item is List) {
    result.add('[\n');
    List<String> guts = new List<String>();
    int count = 0;
    item.forEach((i) {
      String countTxt = showCount ? "(${++count})-" : "";
      guts.add(
          '  ${indent}$countTxt${prettyJsonMap(i, "$indent  ", showCount)}');
    });
    result.add(guts.join(',\n'));
    result.add('\n${indent}]');
  } else {
    if (_toJsonRequired(item)) {
      Map map;
      try {
        map = item.toJson();
      } catch (e) {
        print("ERROR: Caught ${e} on ${item}");
        throw e;
      }

      result.add(prettyJsonMap(map, indent, showCount));
    } else {
      result.add(convert.JSON.encode(item));
    }
  }
  return result.join('');
}

typedef Object FromJsonConstructor(Object jsonData);
constructMapFromJsonData(Map map, FromJsonConstructor ctor,
    [FromJsonConstructor keyCtor]) => map == null
    ? null
    : map.keys.fold({}, (newMap, key) => newMap
  ..[keyCtor == null ? key : keyCtor(key)] = ctor(map[key]));

constructListFromJsonData(List list, FromJsonConstructor ctor) => list == null
    ? null
    : list.fold([], (newList, key) => newList..add(ctor(key)));

/** TODO: Following not used, but consider them for cleaning up bulky copy functions

checkedCopy(Object obj) => obj == null? null : obj.copy();

deepCopyList(List list) =>
  list == null? null :
  new List.from(list.map((elm) => checkedCopy(elm)));

deepCopySet(Set set) =>
  set == null? null :
  new Set.from(set.map((elm) => checkedCopy(elm)));

deepCopySplayTreeSet(SplayTreeSet set) =>
  set == null? null :
  new SplayTreeSet().addAll(set);
*/

/// Return a new string with [text] wrapped in `/*...*/` comment block
String blockComment(String text, [String indent = '   ']) {
  return "/**\n${indentBlock(text, indent)}\n*/";
}

/// Return a new string with [text] wrapped in `///` doc comment block
String docComment(String text, [String indent = ' ']) {
  String guts = text
      .split('\n')
      .join("\n///$indent")
      .replaceAll(_commentLineTrailingWhite, '///\n')
      .replaceAll(_commentFinalTrailingWhite, '///');
  return "///$indent$guts";
}

/// Return a new string with each line [block] indented by [indent]
String indentBlock(String block, [String indent = '  ']) {
  return block == null
      ? null
      : block
          .split('\n')
          .map((p) => "$indent$p".replaceAll(_allWhiteSpace, ''))
          .join('\n');
}

/// Given list of lines, appends a suffix to all lines but the last.
List<String> prepJoin(List<String> lines, [String suffix = ',']) {
  for (int i = 0; i < lines.length - 1; i++) {
    lines[i] += suffix;
  }
  return lines;
}

/// Given list of lines, joins with sep on all including the last
String joinIncludeEnd(List<String> lines, [String sep = ';\n']) =>
    (lines.length > 0) ? (lines.join(sep) + sep) : '';

/// Join the entries with spaces by default taking care break at maxLenth
String formatFill(List<String> entries,
    {String indent: '  ', String sep: ' ', int maxLength: 80}) {
  if (entries.length == 0) return '';
  List<String> result = [];
  String current = '${entries.first}';
  int currentLength = 0;
  for (int i = 1; i < entries.length; i++) {
    var entry = entries[i];
    if ((current.length + entry.length) >= maxLength) {
      result.add(current);
      current = '$indent$entry';
    } else {
      current += '$sep$entry';
    }
  }
  if (current.length > 0) {
    result.add(current);
  }
  return result.join('\n');
}

/// Standard *custom begin* opening text for *C* based languages
const String customBegin = r'//\s*custom';

/// Standard *custom end* closing text for *C* based languages
const String customEnd = r'//\s*end';

/// Defines the textual structure of a block of text that needs to be identified
/// within a source text and treated in a special manner
const String customBlockText = '''
// ${'custom'} <TAG>
// ${'end'} <TAG>
''';

/// Returns an empty customBlock_ with the [tag] as identifier.  The
/// customBlock_ is a block of code that can be stored in a C, Dart, D,
/// etc. code file allowing custom_ (i.e. user hand written) text to be
/// protected during the (re)generation of that code file.
///
/// For example, the call to `customBlock('main')` would return:
///
///     // custom <main>
///     // end <main>
///
/// thus allowing lines of text to be written between the lines containing `//
/// custom <main>` and `// end <main>`
String customBlock(String tag) {
  return customBlockText.replaceAll('TAG', tag);
}

/// Standard *custom begin* opening text for *html* based languages
const String htmlCustomBegin = r'<!--\s*custom';

/// Standard *custom end* closing text for *html* based languages
const String htmlCustomEnd = r'<!--\s*end';

const String htmlCustomBlockText = '''
<!-- custom <TAG> -->
<!-- end <TAG> -->
''';
String htmlCustomBlock(String tag) {
  return htmlCustomBlockText.replaceAll('TAG', tag);
}

bool htmlMergeWithFile(String generated, String destFilePath) {
  return mergeWithFile(generated, destFilePath, htmlCustomBegin, htmlCustomEnd);
}

const String panDocCustomBegin = r'<!---\s*custom';
const String panDocCustomEnd = r'<!---\s*end';
const String panDocCustomBlockText = '''
<!--- custom <TAG> --->
<!--- end <TAG> --->
''';
String panDocCustomBlock(String tag) {
  return panDocCustomBlockText.replaceAll('TAG', tag);
}

bool panDocMergeWithFile(String generated, String destFilePath) {
  return mergeWithFile(
      generated, destFilePath, panDocCustomBegin, panDocCustomEnd);
}

const String cssCustomBegin = r'/\*\s*custom';
const String cssCustomEnd = r'/\*\s*end';
const String cssCustomBlockText = '''
/* custom <TAG> */
/* end <TAG> */
''';
String cssCustomBlock(String tag) {
  return cssCustomBlockText.replaceAll('TAG', tag);
}

bool cssMergeWithFile(String generated, String destFilePath) {
  return mergeWithFile(generated, destFilePath, cssCustomBegin, cssCustomEnd);
}

const String scriptCustomBegin = r'#\s*custom';
const String scriptCustomEnd = r'#\s*end';
const String scriptCustomBlockText = '''
# custom <TAG>
# end <TAG>
''';
String scriptCustomBlock(String tag) {
  return scriptCustomBlockText.replaceAll('TAG', tag);
}

bool scriptMergeWithFile(String generated, String destFilePath) {
  return mergeWithFile(
      generated, destFilePath, scriptCustomBegin, scriptCustomEnd);
}

final RegExp _trailingNewline = new RegExp(r'\n$');
final RegExp _trailingNewlines = new RegExp(r'\n*$');
final RegExp _leadingWhiteSpace = new RegExp(r'^\s+');
final RegExp _trailingWhiteSpace = new RegExp(r'\s+$');
final RegExp _anyWhiteSpace = new RegExp(r'\s+');
final RegExp _allWhiteSpace = new RegExp(r'^\s+$');
final RegExp _multipleNewlines = new RegExp(r'\n\n+');
final RegExp _commentLineTrailingWhite = new RegExp(r'///\s+\n');
final RegExp _commentFinalTrailingWhite = new RegExp(r'///\s+$');

/// Removes trailing any `\n` from `s`
String chomp(String s, [bool multiple = false]) {
  String result = multiple
      ? s.replaceFirst(_trailingNewlines, '')
      : s.replaceFirst(_trailingNewline, '');
  return result;
}

/// Removes left side white space
String leftTrim(String s) => s.replaceFirst(_leadingWhiteSpace, '');
String rightTrim(String s) => s.replaceFirst(_trailingWhiteSpace, '');

String reduceVerticalWhitespace(String s) =>
    s.replaceAll(_multipleNewlines, '\n\n');

const List _defaultProtectionPair = const [customBegin, customEnd];
const List _defaultProtections = const [_defaultProtectionPair];

/// Defines a function that can be used to post-process merged,
/// generated text prior to writing it to a target file
typedef String PostProcessor(String);

final _generatedFiles = new Set();

/// The set of all generated files, whether *created*, *overwritten*,
/// or *unchanged*
Set<String> get generatedFiles => _generatedFiles;

/// All directories into which code was targeted
Iterable<String> get targetedDirectories => concat(new Set<String>.from(
    generatedFiles.map((String filePath) => path.dirname(filePath))).map(
    (String dir) => new Directory(dir)
        .listSync()
        .where((FileSystemEntity fse) => fse is File)));

/// For every path of every generated file, lists all files in those
/// paths that were not generated
List<String> get nonGeneratedFiles => targetedDirectories
    .where((FileSystemEntity fse) => !generatedFiles.contains(fse.path))
    .toList();

/// Take [generated] text and merge with contents of [destFilePath] taking care
/// to preserve any *protect blocks*.
///
/// returns: true iff file written
///
/// [protections] A list of lists with two elements - (i.e. a list of
/// pairs). The first element in the pair is the String that opens a
/// protection block, the second a String that closes the protection
/// block. By default the protections are:
///
///    [ [ r'//\s*custom', r'//\s*end' ] ]
///
/// [postProcess] An optional postProcessor function that may be run
/// on merged contents prior to being written. An example usage is
/// running merged text through a formatter.
bool mergeBlocksWithFile(String generated, String destFilePath,
    [List protections = _defaultProtections, PostProcessor postProcessor]) {
  File inFile = new File(destFilePath);
  bool fileWritten = false;

  if (inFile.existsSync()) {
    String currentText = inFile.readAsStringSync();
    protections.forEach((pair) {
      generated = mergeWithContents(generated, currentText, pair[0], pair[1]);
    });

    if (postProcessor != null) {
      generated = postProcessor(generated);
    }

    if (generated == currentText) {
      print('No change: $destFilePath');
    } else {
      inFile.writeAsStringSync(generated);
      fileWritten = true;
      print('Wrote: $destFilePath');
    }
  } else {
    new Directory(path.dirname(destFilePath))..createSync(recursive: true);
    inFile.writeAsStringSync(generated);
    print('Created $destFilePath');
    fileWritten = true;
  }

  if (_generatedFiles.contains(destFilePath)) {
    _logger.warning('File generated multiple times: $destFilePath');
  } else {
    _generatedFiles.add(destFilePath);
  }

  return fileWritten;
}

bool mergeWithFile(String generated, String destFilePath,
    [String beginProtect = customBegin, String endProtect = customEnd,
    PostProcessor postProcessor]) {
  return mergeBlocksWithFile(
      generated, destFilePath, [[beginProtect, endProtect]], postProcessor);
}

String mergeWithContents(String generated, String currentText,
    String beginProtect, String endProtect) {
  Map<String, String> captures = {};
  Map<String, String> empties = {};

  RegExp block = new RegExp('\\n?[^\\S\\n]*?${beginProtect}' // Look for begin
      '\\s+<(.*?)>(?:.|\\n)*?' // Eat - non-greedy
      '${endProtect}\\s+<\\1>', // Require matching end
      multiLine: true);

  block.allMatches(currentText).forEach((m) {
    captures[m.group(1)] = m.group(0);
  });
  block.allMatches(generated).forEach((m) {
    empties[m.group(1)] = m.group(0);
  });

  captures.forEach((k, v) {
    if (!empties.containsKey(k)) {
      print('Warning: protect block <$k> removed');
    } else {
      generated = generated.replaceFirst(empties[k], captures[k]);
    }
  });
  return generated;
}

/// Returns the string as '$s' with single quotes, assuming it does
/// not already end in either a single or double quote
String smartQuote(String s) =>
    ((s.indexOf("'") == -1) && (s.indexOf('"') == -1)) ? "'$s'" : s;

var _normalizeRe = new RegExp(r'\s+');
var _blockCommentRe =
    new RegExp(r'/\*[^*]*\*+(?:[^*/][^*]*\*+)*/', multiLine: true);
var _lineCommentRe = new RegExp(r'//.*');

decomment(String s) =>
    s.replaceAll(_blockCommentRe, '').replaceAll(_lineCommentRe, '');

bool codeEquivalent(String s1, String s2, {bool stripComments: false}) {
  if (stripComments) {
    s1 = decomment(s1);
    s2 = decomment(s2);
  }
  return s1.replaceAll(_normalizeRe, ' ') == s2.replaceAll(_normalizeRe, ' ');
}

asStr(o) => o is String ? o : o.toString();

bool darkSame(a, b) => darkMatter(a) == darkMatter(b);
String darkMatter(s) => asStr(s).replaceAll(_anyWhiteSpace, '');

/// ignores null objects and empty strings
bool _ignored(Object o) => o == null || (o is String && o == '');

/// If provided an iterable of items joins each with *nl*
///  mnemonic: like <br> in html
String br(Object o, [nl = '\n\n', chompFirst = true]) => o == null
    ? null
    : o is Iterable
        ? br(combine(o, nl, chompFirst), nl, chompFirst)
        : _ignored(o) ? '' : '${chompFirst?chomp(o,true):o}$nl';

/// combines the parts recursively if necessary
String combine(Iterable<Object> parts, [nl = '', chompFirst = false]) {
  final result = parts
      .where((o) => !_ignored(o))
      .map((o) => (o is Iterable)
          ? combine(o, nl, chompFirst)
          : chompFirst ? chomp(asStr(o), true) : asStr(o))
      .where((o) => !_ignored(o))
      .join(nl);
  return result;
}

String brCompact(o) => br(o, '\n', true);

// end <library ebisu>
