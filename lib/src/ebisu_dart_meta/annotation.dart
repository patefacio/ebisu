part of ebisu.ebisu_dart_meta;

class Annotation {
  String get text => _text;

  // custom <class Annotation>

  Annotation(this._text);

  toString() => _text;

  // end <class Annotation>

  String _text;
}

// custom <part annotation>

Annotation annotation(text) => new Annotation(text);

// end <part annotation>
