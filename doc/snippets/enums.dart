import 'package:ebisu/ebisu_dart_meta.dart';

main() {
  final colorEnum = enum_('rgb')
    ..doc = 'Colors'
    ..setAsRoot()
    ..values = [
      'red',
      'green',
      'blue'
    ];
  print(colorEnum.define());
}