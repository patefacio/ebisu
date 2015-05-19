import 'package:ebisu/ebisu_dart_meta.dart';
import 'package:id/id.dart';

main() {
  final colorEnum = enum_('rgb')
    ..doc = 'Colors'
    ..owner = null
    ..values = [
      'red',
      'green',
      'blue'
    ];
  print(colorEnum.define());
}