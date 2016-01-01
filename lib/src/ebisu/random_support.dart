/// Some support for generating random data - sometimes useful for testing
part of ebisu.ebisu;

// custom <part random_support>

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
dynamic randJsonMap(
    [Random generator,
    dynamic valueBuilder,
    String tag = '',
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
                generator.nextInt(12) + 1, generator.nextInt(31) + 1)
            .toString();
      default:
        {
          return obj.randJson();
        }
    }
  }
}

// end <part random_support>
