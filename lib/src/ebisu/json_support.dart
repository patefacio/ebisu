/// Code pulled in when generated Dart needs to serialize json
part of ebisu.ebisu;

// custom <part json_support>

/// A function that really is designed to single out those objects whose type is
/// not known and therefore assumed to be serialized with a corresponding
/// [toJson] call
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

/// Scheme for converting an object [toJson] under the assumptions:
///
///  - If the type is a map the keys are unique strings and the values can be
///    converted to json with a recursive call
///
///  - If the type is a list the values can be converted to json with a
///    recursive call
///
///  - If the type is [DateTime] serializing date.toString() suffices
///
///  - If the type is bool or String the value suffices
///
///  - If the type is none of those it is assumed to be an object with its own
///    [toJson] member function.
///
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

// end <part json_support>
