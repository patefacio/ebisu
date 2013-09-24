library expect_test_basic_class;

import 'package:logging/logging.dart';
import 'package:unittest/unittest.dart';
import 'scratch_remove_me/lib/test_basic_class.dart';
// custom <additional imports>
// end <additional imports>


final _logger = new Logger("expect_test_basic_class");

// custom <library expect_test_basic_class>

main() {
  
  var classNoInit = new ClassNoInit();
  print(classNoInit.mString);
  var classWithInit = new ClassWithInit();
  group('members typed correctly', () {
    group('class no init', () {

      test('mString is null', () =>
          expect(classNoInit.mString == null, true));
      test('mString can assign string', () =>
          expect((classNoInit.mString = 'foo') == 'foo', true));
      test('mString can not assign int', () =>
          expect(() => classNoInit.mString = 3, throws));

      test('mInt is null', () =>
          expect(classNoInit.mInt == null, true));
      test('mInt can assign int', () =>
          expect((classNoInit.mInt = 42) == 42, true));
      test('mInt can not assign String', () =>
          expect(() => classNoInit.mInt = 'foo', throws));

      test('mDouble is null', () =>
          expect(classNoInit.mDouble == null, true));
      test('mDouble can not assign int', () =>
          expect(() => classNoInit.mDouble = 42, throws));
      test('mDouble can assign double', () =>
          expect((classNoInit.mDouble = 42.5) == 42.5, true));
      test('mDouble can not assign String', () =>
          expect(() => classNoInit.mDouble = 'foo', throws));

      test('mListInt is null', () =>
          expect(classNoInit.mListInt == null, true));
      test('mListInt can not assign int', () =>
          expect(() => classNoInit.mListInt = 42, throws));
      test('mListInt can not assign String', () =>
          expect(() => classNoInit.mListInt = 'foo', throws));
      test('mListInt can assign empty list', () =>
          expect((classNoInit.mListInt = []).toString() == 
              [].toString(), true));
      test('mListInt can assign [1,2,3]', () =>
          expect((classNoInit.mListInt = [1,2,3]).toString() == 
              [1,2,3].toString(), true));

      //////////////////////////////////////////////////////////////////////
      // Following would be nice, but List<int> in checked mode does not
      // flag assignment from List<String>
      // 
      //      test('mListInt can not assign ["foo"]', () =>
      //          expect(() => classNoInit.mListInt = ["foo"], throws));
    });
  });
}

// end <library expect_test_basic_class>

