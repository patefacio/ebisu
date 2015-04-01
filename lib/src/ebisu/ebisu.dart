part of ebisu.ebisu;

// custom <part ebisu>

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
Id makeId(id) => id is Id ? id : idFromString(id);

/// Given [prefix] and [id], both of which may be [String] or [Id] returns the
/// [id] prefixed by [prefix]
Id addPrefixToId(prefix, id, [preventDupe = true]) {
  prefix = makeId(prefix);
  id = makeId(id);
  return (preventDupe && id.snake.startsWith(prefix.snake))
      ? id
      : idFromString('${prefix.snake}_${id.snake}');
}

/// Given [suffix] and [id], both of which may be [String] or [Id] returns the
/// [id] suffixed by [suffix]
Id addSuffixToId(suffix, id, [preventDupe = true]) {
  suffix = makeId(suffix);
  id = makeId(id);
  return (preventDupe && id.snake.endsWith(suffix.snake))
      ? id
      : idFromString('${id.snake}_${suffix.snake}');
}

// end <part ebisu>
