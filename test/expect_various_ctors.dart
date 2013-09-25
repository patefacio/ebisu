library expect_various_ctors;

import 'package:logging/logging.dart';
import 'package:unittest/unittest.dart';
import 'scratch_remove_me/lib/various_ctors.dart';
// custom <additional imports>
// end <additional imports>


final _logger = new Logger("expect_various_ctors");

// custom <library expect_various_ctors>

main() {

  test('various ctors - default from 1 and optionally 2, 3', () {
    expect(new VariousCtors(7.5).one, 7.5);
    expect(new VariousCtors(7.5, '8').two, '8');
    expect(new VariousCtors(7.5, '8', 9).three, 9);
  });

  test('various ctors - fromFive single optional', () {
    expect(new VariousCtors.fromFive().five, 5);
    expect(new VariousCtors.fromFive(6).five, 6);
  });

  test('various ctors - fromThreeAndFour 4 is named', () {
    expect(new VariousCtors.fromThreeAndFour(5).three, 5);
    expect(new VariousCtors.fromThreeAndFour(5).four, 90);
    expect(new VariousCtors.fromThreeAndFour(-1, four : -2).three, -1);
    expect(new VariousCtors.fromThreeAndFour(-1, four : -2).four, -2);
  });

}

// end <library expect_various_ctors>

