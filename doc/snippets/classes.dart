import 'package:ebisu/ebisu.dart';
import 'package:ebisu/ebisu_dart_meta.dart';
import 'package:id/id.dart';

main() {
  print(dartFormat(
          (class_('pair')
              ..members = [
                member('a'),
                member('b'),
              ])
          .definition));

  print(dartFormat(
          (class_('pair')
              ..members = [
                member('a'),
                member('b'),
              ])
          .definition));

  print(dartFormat(
          (class_('a')..extend = 'B')
          .definition));

  print(dartFormat(
          (class_('a')..implement = [ 'B', 'C' ])
          .definition));

  print(dartFormat(
          (class_('a')
              ..extend = 'Base'
              ..mixins = [ 'B', 'C' ]
              ..implement = [ 'D', 'E' ]
           )
          .definition));

  print(dartFormat(
          (class_('a')..isAbstract = true)
          .definition));

}