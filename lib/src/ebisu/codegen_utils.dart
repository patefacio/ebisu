/// Common functions used in the code-generation process
part of ebisu.ebisu;

// custom <part codegen_utils>

/// Return a new string with [text] wrapped in `/*...*/` comment block
String blockComment(String text, [String indent = '   ']) {
  return "/**\n${indentBlock(text, indent)}\n*/";
}

/// Return a new string with [text] wrapped in `#...` comment block
String scriptComment(String text, [String indent = '   ']) =>
    ['#$indent', text.split('\n').join('\n#$indent')].join();

/// Return a new string with [text] wrapped in `///` doc comment block
String tripleSlashComment(String text, [String indent = ' ']) {
  String guts = text
      .split('\n')
      .join("\n///$indent")
      .replaceAll(_commentLineTrailingWhite, '///\n')
      .replaceAll(_commentFinalTrailingWhite, '///');
  return "///$indent$guts";
}

final dartComment = tripleSlashComment;

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
<!--- custom <TAG> -->
<!--- end <TAG> -->
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

/// Removes right side white space
String rightTrim(String s) => s.replaceFirst(_trailingWhiteSpace, '');

/// Replace more than 2 consecutive new lines with 2 new lines
String reduceVerticalWhitespace(String s) =>
    s.replaceAll(_multipleNewlines, '\n\n');

const List _defaultProtectionPair = const [customBegin, customEnd];
const List _defaultProtections = const [_defaultProtectionPair];

/// Defines a function that can be used to post-process merged,
/// generated text prior to writing it to a target file
typedef String PostProcessor(String generatedText);

/// The set of all generated files, whether *created*, *overwritten*,
/// or *unchanged*
final _generatedFiles = new Set<String>();

/// All directories into which code was targeted
Iterable<String> get targetedDirectories => new Set<String>.from(
    _generatedFiles.map((String filePath) => path.dirname(filePath)));

/// The set of all files within [targetedDirectories].
///
/// This can be used to determine files in [targetedDirectories] that were not
/// generated
Set<String> get potentialTargetFiles => new Set<String>.from(concat(
    targetedDirectories.map((String dir) => new Directory(dir)
        .listSync()
        .where((FileSystemEntity fse) => fse is File)
        .map((fse) => fse.path))));

/// For every path of every generated file, lists all files in those
/// paths that were not generated
Set<String> get nonGeneratedFiles =>
    potentialTargetFiles.difference(_generatedFiles);

/// Take [generated] text and merge with contents of [destFilePath]
/// taking care to preserve any *protect blocks*.
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
    [List protections = _defaultProtections,
    PostProcessor postProcessor, bool noAnnounce = false]) {
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
      if (!noAnnounce) print('No change: $destFilePath');
    } else {
      inFile.writeAsStringSync(generated);
      fileWritten = true;
      if (!noAnnounce) print('Wrote: $destFilePath');
    }
  } else {
    new Directory(path.dirname(destFilePath))..createSync(recursive: true);

    if (postProcessor != null) {
      generated = postProcessor(generated);
    }

    inFile.writeAsStringSync(generated);
    if (!noAnnounce) print('Created: $destFilePath');
    fileWritten = true;
  }

  if (_generatedFiles.contains(destFilePath)) {
    _logger.warning('File generated multiple times: $destFilePath');
  } else {
    _generatedFiles.add(destFilePath);
  }

  return fileWritten;
}

/// Take [generated] text and merge with contents of [destFilePath]
/// taking are to preserve any *protect blocks*.
///
/// returns: true iff file written
///
/// [beginProtect] and [endProtect] are used to idenfity the style of
/// protection block tags protecting the text.
///
/// [postProcessor] An optional postProcessor function that may be run
/// on merged contents prior to being written. An example usage is
/// running merged text through a formatter.
bool mergeWithFile(String generated, String destFilePath,
    [String beginProtect = customBegin,
    String endProtect = customEnd,
    PostProcessor postProcessor]) {
  return mergeBlocksWithFile(
      generated,
      destFilePath,
      [
        [beginProtect, endProtect]
      ],
      postProcessor);
}

/// Similar to `mefgeWithFile` but allows user to prevent logging of
/// whether file was updated or not (id `noAnnounce`)
bool mergeWithFileExt(String generated, String destFilePath,
    {String beginProtect = customBegin,
    String endProtect = customEnd,
    bool noAnnounce = false,
    PostProcessor postProcessor}) {
  return mergeBlocksWithFile(
      generated,
      destFilePath,
      [
        [beginProtect, endProtect]
      ],
      postProcessor,
      noAnnounce);
}

/// Take [generated] text and merge with contents of [currentText]
/// taking are to preserve any *protect blocks*.
///
/// returns: string with the merged text
///
/// [beginProtect] and [endProtect] are used to identity the style of
/// protection block tags protecting the text.
String mergeWithContents(String generated, String currentText,
    String beginProtect, String endProtect) {
  Map<String, String> captures = {};
  Map<String, String> empties = {};

  RegExp block = new RegExp(
      '\\n?[^\\S\\r\\n]*?${beginProtect}' // Look for begin
      '\\s+<(.*?)>(?:.|\\r?\\n)*?' // Eat - non-greedy
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

/// Wrap string in double quotes
String doubleQuote(String s) => '"$s"';

/// Double quote if not already double quoted
String smartDoubleQuote(String s) =>
    (s.startsWith('"') && s.endsWith('"')) ? s : doubleQuote(s);

/// Wrap string in triple single tick quotes
String tripleSingleQuote(String s) => "'''$s'''";

/// Wrap string in triple double quotes
String tripleDoubleQuote(String s) => '"""$s"""';

var _normalizeRe = new RegExp(r'\s+');
var _blockCommentRe =
    new RegExp(r'/\*[^*]*\*+(?:[^*/][^*]*\*+)*/', multiLine: true);
var _lineCommentRe = new RegExp(r'//.*');

/// Return [s] with block and line comments removed
decomment(String s) =>
    s.replaceAll(_blockCommentRe, '').replaceAll(_lineCommentRe, '');

/// Returns true iff [s1] and [s2] are *code equivalent*, which just
/// means internal white space is ignored.
///
/// [stripComments] will ignore comments before comparison
bool codeEquivalent(String s1, String s2, {bool stripComments: false}) {
  if (stripComments) {
    s1 = decomment(s1);
    s2 = decomment(s2);
  }
  return s1.replaceAll(_normalizeRe, ' ') == s2.replaceAll(_normalizeRe, ' ');
}

/// Returns [o] as a String using [toString] if needed
asStr(o) => o is String ? o : o.toString();

/// Return true iff [darkMatter] of both inputs are the same
bool darkSame(a, b) => darkMatter(a) == darkMatter(b);

/// Returns the contents of [s], converted to String if needed, with all
/// whitespace removed
///
/// Useful for testing
String darkMatter(s) => asStr(s).replaceAll(_anyWhiteSpace, '');

/// ignores null objects and empty strings
bool _ignored(Object o) => o == null || (o is String && o == '');

/// If provided an iterable of items joins each with *nl*
///  mnemonic: like <br> in html
String br(Object o, [nl = '\n\n', chompFirst = true]) => o == null
    ? null
    : o is Iterable
        ? br(combine(o, nl, chompFirst), nl, chompFirst)
        : _ignored(o) ? '' : '${chompFirst ? chomp(o, true) : o}$nl';

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

/// Combine all entries with single new-line
/// Same as [br] but with less vertical spacing
String brCompact(o) => br(o, '\n', true);

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

final _dartFormatter = new DartFormatter();

/// Passes *contents* through *dart_style* formatting
String dartFormat(String contents) {
  try {
    return _dartFormatter.format(contents);
  } on Exception catch (ex) {
    _logger.warning('''
Caught exception $ex
-------------------------------------------------------------
$contents
-------------------------------------------------------------
''');
    return contents;
  }
}

bool _useDartFormatter = Platform.environment['EBISU_DART_FORMAT'] != null &&
    Platform.environment['EBISU_DART_FORMAT'] != '';

/// when set will format generated code using awesome *dart_style* package
set useDartFormatter(bool v) => _useDartFormatter = v;
get useDartFormatter => _useDartFormatter;

/// List of regexes identifying files to not format, even if useDartFormatter is
/// true. Occasionally a file causes dart_style some issues, so providing this
/// allows client code to exclude formatting of problem files while still
/// formatting the good ones.
final List<RegExp> _formatPrunes = [];
set formatPrunes(List<RegExp> v) => _formatPrunes
  ..clear()
  ..addAll(v);
get formatPrunes => _formatPrunes;

/// Take [generated] text and merge with contents of [destFilePath]
///
/// [useFormatter] if provided will format code using dart style
///
/// returns: true if file was written
bool mergeWithDartFile(String generated, String destFilePath,
    {bool useFormatter}) {
  if (useFormatter == null) useFormatter = _useDartFormatter;
  if (useFormatter && !_formatPrunes.isEmpty) {
    final pruned = _formatPrunes.any((re) => re.hasMatch(destFilePath));
    if (pruned) _logger.info('Pruned $destFilePath from formatting');
    useFormatter = !pruned;
  }
  return mergeWithFile(generated, destFilePath, customBegin, customEnd,
      useFormatter ? dartFormat : null);
}

/// Given a list of scalars mixed with iterables (possibly recursively), return
/// as [Iterable] of scalars. Useful for things like:
///
///    ..members = flatten([ commonMembers, member('foo'), member('goo'), ])
///
/// where *commonMembers* is Iterable<Member>
///
flatten(iterable) => iterable.expand((v) => v is Iterable ? flatten(v) : [v]);

/// Given an [Id] or [String] returns corresponding [Id]
final makeId = getOrCreateId;

/// Given [prefix] and [id], both of which may be [String] or [Id] returns the
/// [id] prefixed by [prefix]
Id addPrefixToId(prefix, id, [preventDupe = true]) {
  prefix = makeId(prefix);
  id = makeId(id);
  return (preventDupe && id.snake.startsWith('${prefix.snake}_'))
      ? id
      : idFromString('${prefix.snake}_${id.snake}');
}

/// Given [suffix] and [id], both of which may be [String] or [Id] returns the
/// [id] suffixed by [suffix]
Id addSuffixToId(suffix, id, [preventDupe = true]) {
  suffix = makeId(suffix);
  id = makeId(id);
  return (preventDupe && id.snake.endsWith('_${suffix.snake}'))
      ? id
      : idFromString('${id.snake}_${suffix.snake}');
}

/// Returns [s] unchanged if its length is less than or equal to [length] and
/// returns [s] capped to length [length] with and including a trailing ellipsis
String substringWithEllipsis(String s, int length) {
  final sLength = s.length;
  return sLength > length ? '${s.substring(0, length - 3)}...' : s;
}

/// Return a stack trace object
Trace getStackTrace() {
  try {
    throw null;
  } catch (_, stackTrace) {
    return new Trace.from(stackTrace);
  }
}

/// Includes a generated comment before the [txt]
String tagGeneratedContent(String txt) {
  final script = Platform.script.path;
  final basename = path.basename(script);
  final parent = path.basename(path.dirname(script));
  return '''
////////////////////////////////////////////////////////////////////////////////
/// File generated by .../$parent/$basename
////////////////////////////////////////////////////////////////////////////////
$txt
''';
}

/// Includes a stack trace after the [txt]
String commentStackTrace(String txt, [bool showLine = true]) => '''
$txt
////////////////////////////////////////////////////////////////////////////////
/// Stack trace associated with generated code. Useful for determining what
/// code generated this file
////////////////////////////////////////////////////////////////////////////////
${blockComment(chomp(brCompact(getStackTrace().frames.skip(3).takeWhile((f) => !f.member.contains('_startIsolate')).map((f) => '${f.library}:${showLine ? f.line : ""}\n  ${f.member}'))))}''';

scrubPubFilesFromRoot(String packageRoot) {
  final rootDirectory = new Directory(packageRoot);
  final moribunds = ['packages', '.pub'];
  moribunds.forEach((var dir) {
    final moribund = new Directory(path.join(packageRoot, dir));
    if (moribund.existsSync()) {
      _logger.info('Removing *$dir* path $moribund');
      moribund.deleteSync(recursive: true);
    }
  });

  {
    final moribunds = ['.packages', 'pubspec.lock'];
    moribunds.forEach((var file) {
      final moribund = new File(path.join(packageRoot, file));
      if (moribund.existsSync()) {
        _logger.info('Removing *pubspec.lock* path $moribund');
        moribund.deleteSync();
      }
    });
  }

  rootDirectory.listSync(recursive: true).forEach((FileSystemEntity entry) {
    final basename = path.basename(entry.path);
    if (FileSystemEntity.isLinkSync(entry.path) && basename == 'packages') {
      _logger.info('Removing *packages* softlink $entry');
      entry.deleteSync();
    }
  });
}

/// Searches up directories of [startPath] until [dirTest] is true or root is
/// reached
String findParentPath(String startPath, bool dirTest(String filePath)) {
  if (!path.isAbsolute(startPath)) {
    startPath = path.join(Directory.current.path, startPath);
  }
  if (dirTest(startPath)) {
    return startPath;
  }

  if (startPath == '/') {
    return null;
  } else {
    return findParentPath(path.dirname(startPath), dirTest);
  }
}

/// Given [filePath] searches in folders up to find git repo
String findGitRepo(String filePath) => findParentPath(
    FileSystemEntity.isDirectorySync(filePath)
        ? filePath
        : path.dirname(filePath),
    (String p) => new Directory(p)
        .listSync()
        .any((fse) => fse is Directory && path.basename(fse.path) == '.git'));

/// Path to root folder containing pubspec.yaml for given script
String _scriptRootPath;

/// Assumes script being run is within a dart package, searches up the path and
/// returns the first folder containing a pubspec.yaml file
String get scriptRootPath {
  if (_scriptRootPath != null) return _scriptRootPath;

  Directory current = new Directory(path.dirname(Platform.script.toFilePath()));
  while (current.path != '/') {
    if (new File(path.join(current.path, 'pubspec.yaml')).existsSync()) {
      return _scriptRootPath = current.path;
    }
    current = current.parent;
  }
  throw "Could not find script root path";
}

Map decodeJson(String json) => convert.json.decode(json);
String encodeJson(Object json) => convert.json.encode(json);
// end <part codegen_utils>
