part of ebisu.ebisu;

class ParsedOption {
  const ParsedOption(this.name, this.value);

  @override
  bool operator ==(ParsedOption other) =>
      identical(this, other) || name == other.name && value == other.value;

  @override
  int get hashCode => hash2(name, value);

  final String name;
  final String value;

  // custom <class ParsedOption>

  get isFlag => value == null;

  toString() => 'ParsedOption($name:$value)';

  // end <class ParsedOption>

}

class ArgDetails {
  ArgDetails(this._index, {optionIndices, parsedOption})
      : _optionIndices = optionIndices ?? [],
        _parsedOption = parsedOption;

  @override
  bool operator ==(ArgDetails other) =>
      identical(this, other) ||
      _index == other._index &&
          const ListEquality().equals(_optionIndices, other._optionIndices) &&
          _parsedOption == other._parsedOption;

  @override
  int get hashCode => hash3(
      _index,
      const ListEquality<int>().hash(_optionIndices ?? const []),
      _parsedOption);

  int get index => _index;

  /// List of related indices comprising the option
  List<int> get optionIndices => _optionIndices;
  ParsedOption get parsedOption => _parsedOption;

  // custom <class ArgDetails>

  toString() => brCompact(['$index:${optionIndices}:$parsedOption']);

  // end <class ArgDetails>

  int _index;
  List<int> _optionIndices = [];
  ParsedOption _parsedOption;
}

/// Given a command line that is assumed correct, with no up-front knowledge of
/// flags/options available, parses the command line and infers all options.
class CommandLineParser {
  /// Command line to be parsed
  String get commandLine => _commandLine;

  /// Args determined by whitespace
  List<String> get args => _args;

  /// Index into args of last argument resembling an option/flag
  int get lastOptionIndex => _lastOptionIndex;

  /// Inferred details of each arg
  List<ArgDetails> get argDetails => _argDetails;

  // custom <class CommandLineParser>

  CommandLineParser(this._commandLine) {
    _args = _commandLine.split(_anyWhiteSpace);
    _lastOptionIndex =
        enumerate(_args).lastWhere((iv) => _looksLikeOption(iv.value))?.index ??
            -1;
    String currentOption;
    for (int i = 0; i < _args.length; i++) {
      final arg = args[i];

      _logger.fine('processing arg($arg) with currentOption($currentOption)');

      if (_looksLikeOption(arg)) {
        if (currentOption != null) {
          /// We have an open currentOption - add that one
          _argDetails.add(new ArgDetails(i - 1,
              parsedOption: new ParsedOption(currentOption, null)));
        }

        currentOption = arg;

        if (_looksLikeLongFormOption(arg)) {
          if (arg.contains('=')) {
            final match = _optionWithEqualsRe.firstMatch(arg);
            assert(match != null);
            final optionName = match.group(1);
            final optionValue = match.group(2);

            _argDetails.add(new ArgDetails(i,
                parsedOption: new ParsedOption(optionName, optionValue)));

            _logger.fine('assigned long-name arg $optionName -> $optionValue');
            currentOption = null;
          }
        } else {
          _logger.fine('short-form arg $arg');

          if (arg.contains('=')) {
            final match = _optionWithEqualsRe.firstMatch(arg);
            assert(match != null);
            final optionName = match.group(1);
            final optionValue = match.group(2);

            _argDetails.add(new ArgDetails(i,
                parsedOption: new ParsedOption(optionName, optionValue)));

            _logger.fine('assigned short-name arg $optionName -> $optionValue');
            currentOption = null;
          } else if (i == _args.length - 1) {
            _argDetails.add(
                new ArgDetails(i, parsedOption: new ParsedOption(arg, null)));
            currentOption = null;
          }
          assert(_looksLikeShortFormOption(arg));
        }
      } else {
        /// This is not an option - so it is either an argument to the command
        /// line or the value of an option. Assume it is the value of an option
        /// only if *currentOption* is set. It may be incorrect, it may be a
        /// value for the program, for example if the *currentOption* is a flag
        /// option expecting no value.
        if (currentOption != null) {
          _argDetails.add(new ArgDetails(i - 1,
              parsedOption: new ParsedOption(currentOption, arg)));
        }
        _logger.fine('args[$i] -> ${args[i]} vs $_lastOptionIndex');
        currentOption = null;
      }
    }
  }

  toString() => brCompact([
        _argDetails.isNotEmpty ? '------ argDetails ------' : null,
        indentBlock(brCompact(_argDetails)),
      ]);

  // end <class CommandLineParser>

  String _commandLine;
  List<String> _args = [];
  int _lastOptionIndex = 0;
  List<ArgDetails> _argDetails = [];
}

// custom <part command_line_parser>

final _shortFormOptionRe = new RegExp(r'^-[^-]');

_looksLikeOption(s) => s.startsWith('-');
_looksLikeShortFormOption(s) => _shortFormOptionRe.hasMatch(s);
_looksLikeLongFormOption(s) => s.startsWith('--');

final _optionWithEqualsRe = new RegExp(r'([^=]+)=(.*)');

// end <part command_line_parser>
