part of ebisu;

/// Convenience wrapper for a map - passed into templates as variable '_'
class Context {
  /// Data being wrapped
  Map get data => _data;

// custom <class Context>

  Context(Map data) :
    _data = data 
  { 
  }

  dynamic noSuchMethod(Invocation msg) {
    String memberName = msg.memberName;
    if(! _data.containsKey(memberName)) {
      throw new ArgumentError("Context could not find key '$memberName' in data");
    }
    return _data[memberName];
  }

  dynamic operator[](dynamic index) {
    return _data[index];
  }

// end <class Context>
  final Map _data;
}
// custom <part ebisu>

/// Return an [Iterable] of [items] with each [item] wrapped by a Context.
Iterable asContexts(Iterable items) {
  return items.toList().map((i) => new Context(i));
}

/// Return a new string with [text] wrapped in `/*...*/` comment block
String blockComment(String text, [String indent = '   ']) {
  String guts = text.split('\n').join("\n$indent");
  return "/**\n$indent$guts\n*/";
}

/// Return a new string with [text] wrapped in `///` doc comment block
String docComment(String text, [String indent = ' ']) {
  String guts = text.split('\n')
    .join("\n///$indent")
    .replaceAll('///$indent\n', '///\n');
  return "///$indent$guts";
}

Map _deadSpacePatternMap = {};

/// Return a new string with each line [block] indented by [indent]
String indentBlock(String block, [String indent = '  ']) {
  var trailingDead = _deadSpacePatternMap.putIfAbsent(indent, 
      () => new RegExp('\n$indent\$'));
  var leadingDead = _deadSpacePatternMap.putIfAbsent(indent, 
      () => new RegExp('^$indent\n'));
  return '$indent${block.split("\n").join("\n$indent")}'
    .replaceAll('\n$indent\n', '\n\n')
    .replaceAll(trailingDead, '\n')
    .replaceAll(leadingDead, '\n');
}

List<String> prepJoin(List<String> lines, [ String suffix = ',' ]) {
  for(int i=0; i<lines.length-1; i++) {
    lines[i] += suffix;
  }
  return lines;
}

String formatFill(List<String> entries, 
    [ String indent = '  ', String separator = ' ', int maxLength = 80 ]) {
  if(entries.length == 0) return '';
  List<String> result = [];
  String current = '${entries.first}';
  int currentLength = 0;
  for(int i=1; i<entries.length; i++) {
    var entry = entries[i];
    if((current.length + entry.length) >= maxLength) {
      result.add(current);
      current = '$indent$entry';
    } else {
      current += '$separator$entry';
    }
  }
  if(current.length > 0) {
    result.add(current);
  }
  return result.join('\n');
}

const String _customBegin = r'//\s*custom';
const String _customEnd = r'//\s*end';
const String _customBlockText = '''
// ${'custom'} <TAG>
// ${'end'} <TAG>
''';

/// Returns an empty _customBlock_ with the [tag] as identifier.  The
/// _customBlock_ is a block of code that can be stored in a C, Dart, D,
/// etc. code file allowing _custom_ (i.e. user hand written) text to be
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
  return _customBlockText.replaceAll('TAG', tag);
}

const String _htmlCustomBegin = r'<!--\s*custom';
const String _htmlCustomEnd = r'<!--\s*end';
const String _htmlCustomBlockText = '''
<!-- custom <TAG> -->
<!-- end <TAG> -->
''';
String htmlCustomBlock(String tag) {
  return _htmlCustomBlockText.replaceAll('TAG', tag);
}

bool htmlMergeWithFile(String generated, String destFilePath) {
  return mergeWithFile(generated, destFilePath, _htmlCustomBegin, _htmlCustomEnd);
}

const String _panDocCustomBegin = r'<!---\s*custom';
const String _panDocCustomEnd = r'<!---\s*end';
const String _panDocCustomBlockText = '''
<!--- custom <TAG> --->
<!--- end <TAG> --->
''';
String panDocCustomBlock(String tag) {
  return _panDocCustomBlockText.replaceAll('TAG', tag);
}

bool panDocMergeWithFile(String generated, String destFilePath) {
  return mergeWithFile(generated, destFilePath, _panDocCustomBegin, _panDocCustomEnd);
}

const String _cssCustomBegin = r'/\*\s*custom';
const String _cssCustomEnd = r'/\*\s*end';
const String _cssCustomBlockText = '''
/* custom <TAG> */
/* end <TAG> */
''';
String cssCustomBlock(String tag) {
  return _cssCustomBlockText.replaceAll('TAG', tag);
}

bool cssMergeWithFile(String generated, String destFilePath) {
  return mergeWithFile(generated, destFilePath, _cssCustomBegin, _cssCustomEnd);
}

const String _scriptCustomBegin = r'#\s*custom';
const String _scriptCustomEnd = r'#\s*end';
const String _scriptCustomBlockText = '''
# custom <TAG>
# end <TAG>
''';
String scriptCustomBlock(String tag) {
  return _scriptCustomBlockText.replaceAll('TAG', tag);
}

bool scriptMergeWithFile(String generated, String destFilePath) {
  return mergeWithFile(generated, destFilePath, _scriptCustomBegin, _scriptCustomEnd);
}

final RegExp _trailingNewline = new RegExp(r'\n$');
final RegExp _trailingNewlines = new RegExp(r'\n*$');
final RegExp _leadingWhiteSpace = new RegExp(r'^\s+');
final RegExp _trailingWhiteSpace = new RegExp(r'\s+$');

/// Removes trailing any `\n` from `s`
String chomp(String s, [bool multiple = false ]) {
  String result = multiple? s.replaceFirst(_trailingNewlines, '') :
      s.replaceFirst(_trailingNewline, '');
  return result;
}

/// Removes left side white space
String leftTrim(String s) => s.replaceFirst(_leadingWhiteSpace, '');
String rightTrim(String s) => s.replaceFirst(_trailingWhiteSpace, '');

/// Merge the contents of some generated text into the [destFilePath].  If there
/// are no protect blocks in the contents of [destFilePath] it is effectively a
/// write of the genereated text. Otherwise it is a merge that protects the
/// protect blocks. Returns true if a write was necessary, false otherwise
/// leaving the file unmodified if not.
bool mergeWithFile(String generated, String destFilePath,
    [ String beginProtect, String endProtect ]) {

  if(beginProtect==null) beginProtect = _customBegin;
  if(endProtect==null) endProtect = _customEnd;

  File inFile = new File(destFilePath);

  if(inFile.existsSync()) {
    String currentText = inFile.readAsStringSync();

    Map<String, String> captures = {};
    Map<String, String> empties = {};

    RegExp block = 
      new RegExp(
          "\\n?[^\\S\\n]*?${beginProtect}"             // Look for begin
          "\\s+<(.*?)>(?:.|\\n)*?"                     // Eat - non-greedy
          "${endProtect}\\s+<\\1>",                    // Require matching end
          multiLine: true);

    block.allMatches(currentText).forEach((m) 
        { captures[m.group(1)] = m.group(0); });
    block.allMatches(generated).forEach((m) 
        { empties[m.group(1)] = m.group(0); });

    captures.forEach((k,v) {
      if(!empties.containsKey(k)) {
        print("Warning: protect block <$k> removed");
      } else {
        generated = generated.replaceFirst(empties[k], captures[k]);
      }
    });

    //if(false && generated == currentText) {
    if(generated == currentText) {
      print("No change: $destFilePath");
      return false;
    } else {
      inFile.writeAsStringSync(generated);
      print("Wrote: $destFilePath");
    }
  } else {
    new Directory(path.dirname(destFilePath))
      ..createSync(recursive: true);
    inFile.writeAsStringSync(generated);
    print("Created $destFilePath");
  }
  return true;
}

List<String> cleanImports(List<String> dirtyImports) {
  List<String> result = [];
  var hit = new Set<String>();
  dirtyImports.forEach((i) {
    i = i.replaceAll('"', "'");
    if(hit.contains(i)) return;
    hit.add(i);
    result.add(i);
  });
  result.sort();
  return result;
}

// end <part ebisu>

