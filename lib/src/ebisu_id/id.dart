part of ebisu_id;

/// Given an id (all lower case string of words separated by '_')
/// provides consistent representations
class Id { 
  final String _id;
  /// String containing the lower case words separated by '_'
  String get id => _id;
  final List<String> _words;
  /// Words comprising the id
  List<String> get words => _words;

// custom <class Id>

  /// `id` must be a string in snake case (e.g. `how_now_brown_cow`)
  Id(String id) :
    _id = id,
    _words = id.split('_') 
  { 
    if(null != _hasUpperRe.firstMatch(id)) {
      throw new ArgumentError("Id must be lower case $id");
    }
    if(null == _validSnakeRe.firstMatch(id)) {
      throw new ArgumentError("Id has invalid characters $id");
    }
  }

  Id.fromCamels(String camelId) : this(splitByCaps(camelId));

  static Id idFromCamels(String camelId) => new Id.fromCamels(camelId);
  static bool isCamel(String text) => _camelRe.firstMatch(text) != null;
  static bool isCapCamel(String text) => _capCamelRe.firstMatch(text) != null;
  static bool isSnake(String text) => _snakeRe.firstMatch(text) != null;

  static RegExp _capCamelRe = new RegExp(r'^[A-Z][A-Za-z]*$');
  static RegExp _camelRe = new RegExp(r'^[A-Za-z]+$');
  static RegExp _snakeRe = new RegExp(r'^[a-z][a-z_]*$');
  static RegExp _capWordDelimiterRe = new RegExp('[A-Z]');
  static RegExp _leadingTrailingUnderbarRe = new RegExp(r'(?:^_)|(?:_$)');

  static String splitByCaps(String text) {
    var result = 
      text.splitMapJoin(_capWordDelimiterRe,
          onMatch: (Match match) => match.group(0).toLowerCase(),
          onNonMatch: (String nonMatch) => nonMatch + '_')
      .replaceAll(_leadingTrailingUnderbarRe, '');
    return result;
  }

  static final RegExp _hasUpperRe = new RegExp(r"[A-Z]");
  static final RegExp _validSnakeRe = new RegExp(r"^[a-z][a-z\d_]*$");

  /// Capitalize the string (i.e. make first character capital, leaving rest alone)
  static capitalize(String s) => "${s[0].toUpperCase()}${s.substring(1)}";

  /// Unapitalize the string (i.e. make first character lower, leaving rest alone)
  static uncapitalize(String s) => "${s[0].toLowerCase()}${s.substring(1)}";

  /// Return this id as snake case - (i.e. the case passed in for construction) (e.g. `how_now_brown_cow`)
  String get snake => _id;
  /// Return this id as hyphenated words (e.g. `how_now_brown_cow` => `how-now-brown-cow`)
  String get emacs => _words.join('-');
  /// Return as camel case, first character lower and each word capitalized (e.g. `how_now_brown_cow` => `howNowBrownCow`)
  String get camel => uncapitalize(_words.map((w) => capitalize(w)).join(''));
  /// Return as cap camel case, same as camel with first word capitalized (e.g. `how_now_brown_cow` => `HowNowBrownCow`)
  String get capCamel => _words.map((w) => capitalize(w)).join('');
  /// Return all caps with underscore separator (e.g. `how_now_brown_cow` => `HOW_NOW_BROWN_COW`)
  String get shout => _words.map((w) => w.toUpperCase()).join('_');
  /// Return each word capitalized with space `' '` separator (e.g. `how_now_brown_cow` => `How Now Brown Cow`)
  String get title => _words.map((w) => capitalize(w)).join(' ');  
  /// Return words squished together with no separator (e.g. `how_now_brown_cow` => `hownowbrowncow`)
  String get squish => _words.join('');
  /// Return first letter of each word joined together (e.g. `how_now_brown_cow` => `hnbc`)
  String get abbrev => _words.map((w) => w[0]).join();

  /// Return new id as the plural of the argument (`Id('dog')` => `Id('dogs')`)
  static Id pluralize(Id id, [ String suffix = 's' ]) => new Id(id._id + suffix);

  /// Return true if name is snake case
  static Id isValidSnakeId(String name) => _validSnakeRe.firstMatch(name) != null;

  static Id fromString(String id) {
    return new Id(id);
  }

  String toString() => camel;

  Map toJson() { 
    return { 
    "id": EBISU_UTILS.toJson(_id),
    "words": EBISU_UTILS.toJson(_words),
    };
  }

  static Id fromJson(String json) {
    Map jsonMap = JSON.parse(json);
    return fromJsonMap(jsonMap);
  }

  static Id fromJsonMap(Map jsonMap) {
    return new Id(jsonMap["id"]);
  }


// end <class Id>
}

// custom <part id>

/// Return a new Id instance from either snake case or camel case
Id IdFromEither(String text) {
  return 
    Id.isSnake(text)? 
    new Id(text) :
    (Id.isCamel(text)? new Id.fromCamels(text) :
        throw new ArgumentError("$text is neither snake or camel"));
}

// end <part id>

