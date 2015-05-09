library ebisu.expect_basic_class;

import 'package:args/args.dart';
import 'package:logging/logging.dart';
import 'package:test/test.dart';
import 'scratch_remove_me/lib/basic_class.dart';

// custom <additional imports>
// end <additional imports>

final _logger = new Logger('expect_basic_class');

// custom <library expect_basic_class>
// end <library expect_basic_class>

main([List<String> args]) {
  Logger.root.onRecord.listen(
      (LogRecord r) => print("${r.loggerName} [${r.level}]:\t${r.message}"));
  Logger.root.level = Level.OFF;
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
      test('mString can not assign int',
          () => expect(() => classNoInit.mString = 3, throws));

      test('mInt is null', () => expect(classNoInit.mInt == null, true));
      test('mInt can assign int',
          () => expect((classNoInit.mInt = 42) == 42, true));
      test('mInt can not assign String',
          () => expect(() => classNoInit.mInt = 'foo', throws));

      test('mDouble is null', () => expect(classNoInit.mDouble == null, true));
      test('mDouble can not assign int',
          () => expect(() => classNoInit.mDouble = 42, throws));
      test('mDouble can assign double',
          () => expect((classNoInit.mDouble = 42.5) == 42.5, true));
      test('mDouble can not assign String',
          () => expect(() => classNoInit.mDouble = 'foo', throws));

      test('mBool is null', () => expect(classNoInit.mBool == null, true));
      test('mBool can not assign int',
          () => expect(() => classNoInit.mBool = 42, throws));
      test('mBool can assign bool',
          () => expect((classNoInit.mBool = true) == true, true));
      test('mBool can not assign String',
          () => expect(() => classNoInit.mBool = 'foo', throws));

      test(
          'mListInt is null', () => expect(classNoInit.mListInt == null, true));
      test('mListInt can not assign int',
          () => expect(() => classNoInit.mListInt = 42, throws));
      test('mListInt can not assign String',
          () => expect(() => classNoInit.mListInt = 'foo', throws));
      test('mListInt can assign empty list', () => expect(
          (classNoInit.mListInt = []).toString() == [].toString(), true));
      test('mListInt can assign [1,2,3]', () => expect(
          (classNoInit.mListInt = [1, 2, 3]).toString() == [1, 2, 3].toString(),
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
        expect(() => classReadOnly.mString = "goo", throws);
      });
      test('mInt is int', () => expect(classReadOnly.mInt, 3));
      test('mDouble is double', () => expect(classReadOnly.mDouble, 3.14));
      test('mBool is bool', () => expect(classReadOnly.mBool, false));
      test('mListInt is List',
          () => expect(classReadOnly.mList.toString(), [1, 2, 3].toString()));
      test('mListInt is Map',
          () => expect(classReadOnly.mMap.toString(), {1: 2}.toString()));
    });

    group('class with inaccessible members', () {
      test('mString is foo', () {
        expect(() => classInaccessible.mString, throws);
        expect(() => classInaccessible.mString = "goo", throws);
      });
      test('mInt is int', () {
        expect(() => classInaccessible.mInt, throws);
        expect(() => classInaccessible.mInt = 5, throws);
      });
      test('mDouble is double', () {
        expect(() => classInaccessible.mDouble, throws);
        expect(() => classInaccessible.mDouble = 4.0, throws);
      });
      test('mBool is bool', () {
        expect(() => classInaccessible.mBool, throws);
        expect(() => classInaccessible.mBool = true, throws);
      });
      test('mListInt is List', () {
        expect(() => classInaccessible.mList, throws);
        expect(() => classInaccessible.mList = [], throws);
      });
      test('mMap is Map', () {
        expect(() => classInaccessible.mMap, throws);
        expect(() => classInaccessible.mMap = {}, throws);
      });
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
