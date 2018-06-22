library ebisu.expect_basic_class;

import 'package:logging/logging.dart';
import 'package:test/test.dart';
import 'sample_generated_code/lib/basic_class.dart';

// custom <additional imports>
// end <additional imports>

final Logger _logger = new Logger('expect_basic_class');

// custom <library expect_basic_class>
// end <library expect_basic_class>

void main([List<String> args]) {
  if (args?.isEmpty ?? false) {
    Logger.root.onRecord.listen(
        (LogRecord r) => print("${r.loggerName} [${r.level}]:\t${r.message}"));
    Logger.root.level = Level.OFF;
  }
// custom <main>

  var classNoInit = new ClassNoInit();
  var classWithInit = new ClassWithInit();
  var classWithInferredType = new ClassWithInferredType();
  var classReadOnly = new ClassReadOnly();
  var classInaccessible = new ClassInaccessible();
  var classJson = new ClassJson();
  var classJsonOuter = new ClassJsonOuter();

  group('members typed/initialized correctly', () {
    group('class no init', () {
      test('mString is null', () => expect(classNoInit.mString == null, true));
      test('mString can assign string',
          () => expect((classNoInit.mString = 'foo') == 'foo', true));

      test('mInt is null', () => expect(classNoInit.mInt == null, true));
      test('mInt can assign int',
          () => expect((classNoInit.mInt = 42) == 42, true));

      test('mDouble is null', () => expect(classNoInit.mDouble == null, true));
      test('mDouble can assign double',
          () => expect((classNoInit.mDouble = 42.5) == 42.5, true));

      test('mBool is null', () => expect(classNoInit.mBool == null, true));
      test('mBool can assign bool',
          () => expect((classNoInit.mBool = true) == true, true));

      test(
          'mListInt is null', () => expect(classNoInit.mListInt == null, true));

      test(
          'mListInt can assign empty list',
          () => expect(
              (classNoInit.mListInt = []).toString() == [].toString(), true));
      test(
          'mListInt can assign [1,2,3]',
          () => expect(
              (classNoInit.mListInt = [1, 2, 3]).toString() ==
                  [1, 2, 3].toString(),
              true));

      //////////////////////////////////////////////////////////////////////
      // Following would be nice, but List<int> in checked mode does not
      // flag assignment from List<String>
      //
      //      test('mListInt can not assign ["foo"]', () =>
      //          expect(() => classNoInit.mListInt = ["foo"], throws));
    });

    group('class with init', () {
      test('mString is foo', () => expect(classWithInit.mString, "foo"));
      test('mNum is 3.14', () {
        expect(classWithInit.mNum, 3.14);
        expect(classWithInit.mNum is num, true);
      });
    });

    group('class with inferred type', () {
      test('mString is foo', () {
        expect(classWithInferredType.mString is String, true);
        expect(classWithInferredType.mString, "foo");
      });
      test(
          'mInt is int', () => expect(classWithInferredType.mInt is int, true));
      test('mDouble is double',
          () => expect(classWithInferredType.mDouble, 1.0));
      test('mBool is bool',
          () => expect(classWithInferredType.mBool is bool, true));
      test('mListInt is List',
          () => expect(classWithInferredType.mList is List, true));
      test('mListInt is Map',
          () => expect(classWithInferredType.mMap is Map, true));
    });

    group('class with read only members', () {
      test('mString is foo', () {
        expect(classReadOnly.mString, "foo");
      });
      test('mInt is int', () => expect(classReadOnly.mInt, 3));
      test('mDouble is double', () => expect(classReadOnly.mDouble, 3.14));
      test('mBool is bool', () => expect(classReadOnly.mBool, false));
      test('mListInt is List',
          () => expect(classReadOnly.mList.toString(), [1, 2, 3].toString()));
      test('mListInt is Map',
          () => expect(classReadOnly.mMap.toString(), {1: 2}.toString()));
    });

    group('class json support', () {
      test('round trip', () {
        var asJson = classJson.toJson();
        expect(asJson is Map, true);
        var avatar = ClassJson.fromJson(asJson);
        expect(avatar is ClassJson, true);
        expect(avatar.mString == 'foo', true);
        expect(avatar.mInt == 3, true);
        expect(avatar.mDouble == 3.14, true);
        expect(avatar.toJson().toString(), asJson.toString());
      });
    });

    group('class json outer support', () {
      test('round trip', () {
        var asJson = classJsonOuter.toJson();
        expect(asJson is Map, true);
        var avatar = ClassJsonOuter.fromJson(asJson);
        expect(avatar is ClassJsonOuter, true);
        expect(avatar.mNested.mString == 'foo', true);
        expect(avatar.mNested.mInt == 3, true);
        expect(avatar.mNested.mDouble == 3.14, true);
        expect(avatar.toJson().toString(), asJson.toString());
      });
    });
  });

// end <main>
}
