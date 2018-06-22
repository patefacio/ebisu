library test_code_generation.basic_class;

import 'dart:async';
import 'dart:convert' as convert;
import 'dart:io';
import 'package:ebisu/ebisu.dart' as ebisu;
import 'package:path/path.dart';

// custom <additional imports>
// end <additional imports>

class Color implements Comparable<Color> {
  static const Color RED = const Color._(0);

  static const Color GREEN = const Color._(1);

  static const Color BLUE = const Color._(2);

  static List<Color> get values => const <Color>[RED, GREEN, BLUE];

  final int value;

  int get hashCode => value;

  const Color._(this.value);

  Color copy() => this;

  int compareTo(Color other) => value.compareTo(other.value);

  String toString() {
    switch (this) {
      case RED:
        return "Red";
      case GREEN:
        return "Green";
      case BLUE:
        return "Blue";
    }
    return null;
  }

  static Color fromString(String s) {
    if (s == null) return null;
    switch (s) {
      case "Red":
        return RED;
      case "Green":
        return GREEN;
      case "Blue":
        return BLUE;
      default:
        return null;
    }
  }

  String toJson() => toString();

  static Color fromJson(dynamic v) {
    return (v is String) ? fromString(v) : (v is int) ? values[v] : v as Color;
  }
}

class ClassNoInit {
  String mString;
  int mInt;
  double mDouble;
  bool mBool;
  List<int> mListInt;
  Map<String, String> mStringString;

  // custom <class ClassNoInit>
  // end <class ClassNoInit>

  Future<bool> fooExists() async => (await new File("foo").exists());
  Stream<List<int>> get fooStream => new File(join('/', 'foo')).openRead();
}

class ClassWithInit {
  String mString = 'foo';
  int mInt = 0;
  double mDouble = 0.0;
  num mNum = 3.14;
  bool mBool = false;
  List<int> mListInt = [];
  Map<String, String> mStringString = {};

  // custom <class ClassWithInit>
  // end <class ClassWithInit>

}

class ClassWithInferredType {
  String mString = 'foo';
  int mInt = 0;
  double mDouble = 1.0;
  bool mBool = false;
  List<dynamic> mList = [];
  Map mMap = {};

  // custom <class ClassWithInferredType>
  // end <class ClassWithInferredType>

}

class ClassReadOnly {
  String get mString => _mString;
  int get mInt => _mInt;
  double get mDouble => _mDouble;
  bool get mBool => _mBool;
  List<int> get mList => _mList;
  Map get mMap => _mMap;

  // custom <class ClassReadOnly>
  // end <class ClassReadOnly>

  String _mString = 'foo';
  int _mInt = 3;
  double _mDouble = 3.14;
  bool _mBool = false;
  List<int> _mList = [1, 2, 3];
  Map _mMap = {1: 2};
}

class ClassInaccessible {
  // custom <class ClassInaccessible>
  // end <class ClassInaccessible>

  String _mString = 'foo';
  int _mInt = 3;
  double _mDouble = 3.14;
  bool _mBool = false;
  List<int> _mList = [1, 2, 3];
  Map _mMap = {1: 2};
}

class SimpleJson {
  SimpleJson();

  String mString = 'whoop';

  // custom <class SimpleJson>
  // end <class SimpleJson>

  Map toJson() => {
        "mString": ebisu.toJson(mString),
      };

  static SimpleJson fromJson(Object json) {
    if (json == null) return null;
    if (json is String) {
      json = convert.JSON.decode(json);
    }
    assert(json is Map);
    return new SimpleJson._fromJsonMapImpl(json);
  }

  SimpleJson._fromJsonMapImpl(Map jsonMap) : mString = jsonMap["mString"];
}

class CourtesyCtor {
  CourtesyCtor(this.mString, this.mSecret);

  String mString = 'whoop';
  int mSecret = 42;

  // custom <class CourtesyCtor>
  // end <class CourtesyCtor>

}

class ClassJson {
  ClassJson();

  String get mString => _mString;
  int get mInt => _mInt;
  double get mDouble => _mDouble;
  bool get mBool => _mBool;
  List<int> get mList => _mList;
  Map get mMap => _mMap;
  Color get mEnum => _mEnum;
  Map<Color, String> get mColorMap => _mColorMap;
  Map<Color, Color> get mColorColorMap => _mColorColorMap;
  Map<String, SimpleJson> get mStringSimpleMap => _mStringSimpleMap;

  // custom <class ClassJson>
  // end <class ClassJson>

  Map toJson() => {
        "mString": ebisu.toJson(mString),
        "mInt": ebisu.toJson(mInt),
        "mDouble": ebisu.toJson(mDouble),
        "mBool": ebisu.toJson(mBool),
        "mList": ebisu.toJson(mList),
        "mMap": ebisu.toJson(mMap),
        "mEnum": ebisu.toJson(mEnum),
        "mColorMap": ebisu.toJson(mColorMap),
        "mColorColorMap": ebisu.toJson(mColorColorMap),
        "mStringSimpleMap": ebisu.toJson(mStringSimpleMap),
      };

  static ClassJson fromJson(Object json) {
    if (json == null) return null;
    if (json is String) {
      json = convert.JSON.decode(json);
    }
    assert(json is Map);
    return new ClassJson._fromJsonMapImpl(json);
  }

  ClassJson._fromJsonMapImpl(Map jsonMap)
      : _mString = jsonMap["mString"],
        _mInt = jsonMap["mInt"],
        _mDouble = jsonMap["mDouble"],
        _mBool = jsonMap["mBool"],
        // mList is List<int>
        _mList =
            ebisu.constructListFromJsonData<int>(jsonMap["mList"], (data) => data),
        // mMap is Map
        _mMap =
            ebisu.constructMapFromJsonData(jsonMap["mMap"], (value) => value),
        _mEnum = Color.fromJson(jsonMap["mEnum"]),
        // mColorMap is Map<Color,String>
        _mColorMap = ebisu.constructMapFromJsonData<Color, String>(jsonMap["mColorMap"],
            (value) => value, (key) => Color.fromString(key)),
        // mColorColorMap is Map<Color,Color>
        _mColorColorMap = ebisu.constructMapFromJsonData<Color, Color>(
            jsonMap["mColorColorMap"],
            (value) => Color.fromJson(value),
            (key) => Color.fromString(key)),
        // mStringSimpleMap is Map<String,SimpleJson>
        _mStringSimpleMap = ebisu.constructMapFromJsonData<String, SimpleJson>(
            jsonMap["mStringSimpleMap"], (value) => SimpleJson.fromJson(value));

  String _mString = 'foo';
  int _mInt = 3;
  double _mDouble = 3.14;
  bool _mBool = false;
  List<int> _mList = [1, 2, 3];
  Map _mMap = {1: 2};
  Color _mEnum = Color.GREEN;
  Map<Color, String> _mColorMap = {Color.GREEN: "olive"};
  Map<Color, Color> _mColorColorMap = {Color.GREEN: Color.RED};
  Map<String, SimpleJson> _mStringSimpleMap = {"foo": new SimpleJson()};
}

class ClassJsonOuter {
  ClassJsonOuter();

  ClassJson get mNested => _mNested;

  // custom <class ClassJsonOuter>
  // end <class ClassJsonOuter>

  Map toJson() => {
        "mNested": ebisu.toJson(mNested),
      };

  static ClassJsonOuter fromJson(Object json) {
    if (json == null) return null;
    if (json is String) {
      json = convert.JSON.decode(json);
    }
    assert(json is Map);
    return new ClassJsonOuter._fromJsonMapImpl(json);
  }

  ClassJsonOuter._fromJsonMapImpl(Map jsonMap)
      : _mNested = ClassJson.fromJson(jsonMap["mNested"]);

  ClassJson _mNested = new ClassJson();
}

// custom <library basic_class>
// end <library basic_class>
