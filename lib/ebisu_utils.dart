/// Support code to be used by libraries generated with ebisu. Example (toJson)
library ebisu.ebisu_utils;

import 'dart:convert' as convert;
import 'dart:math';
import 'package:logging/logging.dart';
// custom <additional imports>
// end <additional imports>

final _logger = new Logger('ebisu_utils');

// custom <library ebisu_utils>


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
  if(_toJsonRequired(obj)) {
    return obj.toJson();
  } else {
    if(obj is Map) {
      Map result = {};
      obj.forEach((k,v) => result[k.toString()] = toJson(v));
      return result;
    } else if(obj is List) {
      List result = [];
      obj.forEach((e) => result.add(toJson(e)));
      return result;
    } else if(obj is DateTime) {
      return (obj == null)? null : '${obj.toString()}';
    } else {
      return obj;
    }
  }
}

final _sourceChars = r'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ~!@#$%^&*+;,';
final _randGenerator = new Random(0);
final _maxRandInt = 1<<31;

/// Creates a string of random length capped at _maxLen_
String randString([Random generator, int maxLen = 10 ]) {
  if(generator == null) generator = _randGenerator;
  int numChars = generator.nextInt(maxLen)+1;
  var chars = new List<int>(numChars);
  for(var i=0; i<numChars; i++) {
    chars[i] = _sourceChars.codeUnitAt(generator.nextInt(_sourceChars.length));
  }
  return new String.fromCharCodes(chars);
}

/// Creates a Map<String, dynamic> of random length capped at _maxLen_ where
/// keys are random strings, optionally prefixed with _tag_ and values are built
/// from the supplied _valueBuilder_.
dynamic randJsonMap([Random generator,
    dynamic valueBuilder, String tag = '', int maxLen = 10]) {
  Map result = {};
  if(generator == null) generator = _randGenerator;
  int numEntries = generator.nextInt(maxLen)+1;
  for(var i=0; i<numEntries; i++) {
    String key = (tag.length>0? "${tag} <${randString(generator)}>" :
        randString(generator));
    result[key] = valueBuilder();
  }
  return result;
}

dynamic randGeneralMap(keyGenerator(), [Random generator,
    dynamic valueBuilder, int maxLen = 10]) {
  Map result = {};
  if(generator == null) generator = _randGenerator;
  int numEntries = generator.nextInt(maxLen)+1;
  for(var i=0; i<numEntries; i++) {
    String key = keyGenerator();
    result[key] = valueBuilder();
  }
  return result;
}

dynamic randJson(Random generator, var obj, [ final dynamic type ]) {
  if(obj is List) {
    List result = [];
    new List(generator.nextInt(6)+1).forEach((i) {
      result.add(type());
    });
    return result;
  } else if(obj is Map) {
    Map result = {};
    new List(generator.nextInt(4)+1).forEach((i) {
      result[generator.nextInt(_maxRandInt).toString()] = type;
    });
    return result;
  } else if(obj is Function) {
    return obj();
  } else {
    if(obj == null) return null;
    switch(obj) {
      case num: return generator.nextInt(_maxRandInt);
      case double: return generator.nextInt(_maxRandInt) * generator.nextDouble();
      case int: return generator.nextInt(_maxRandInt);
      case String: return randString(generator);
      case bool: return 0==(generator.nextInt(_maxRandInt)%2);
      case DateTime:
        return new DateTime(1900+generator.nextInt(150),
            generator.nextInt(12)+1,
            generator.nextInt(31)+1).toString();
      default: {
        return obj.randJson();
      }
    }
  }
}

String prettyJsonMap(dynamic item, [String indent = "", bool showCount = false]) {
  List<String> result = new List<String>();
  if(item is Map) {
    result.add('{\n');
    var guts = new List<String>();
    var keys = new List<dynamic>.from(item.keys);
    keys.sort();
    int count = 0;
    keys.forEach((k) {
      String countTxt = showCount? "(${++count})-":"";
      guts.add('  ${indent}$countTxt"${k}": ${prettyJsonMap(item[k], "$indent  ", showCount)}');
    });
    result.add(guts.join(',\n'));
    result.add('\n$indent}');
  } else if(item is List) {
    result.add('[\n');
    List<String> guts = new List<String>();
    int count = 0;
    item.forEach((i) {
      String countTxt = showCount? "(${++count})-":"";
      guts.add('  ${indent}$countTxt${prettyJsonMap(i, "$indent  ", showCount)}');
    });
    result.add(guts.join(',\n'));
    result.add('\n${indent}]');
  } else {
    if(_toJsonRequired(item)) {
      Map map;
      try {
        map = item.toJson();
      } catch(e) {
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
constructMapFromJsonData(Map map, FromJsonConstructor ctor, [FromJsonConstructor keyCtor]) =>
  map == null? null :
  map.keys.fold({}, (newMap, key) =>
      newMap..[keyCtor == null? key : keyCtor(key)] = ctor(map[key]));

constructListFromJsonData(List list, FromJsonConstructor ctor) =>
  list == null? null :
  list.fold([], (newList, key) => newList..add(ctor(key)));


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

// end <library ebisu_utils>
