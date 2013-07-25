part of dart_meta;

String app([dynamic _]) {
  if(_ is Map) {
    _ = new Context(_);
  }
  List<String> _buf = new List<String>();


  _buf.add('''
import 'package:mdv/mdv.dart' as mdv;

void main() {
  mdv.initialize();
}
''');
  return _buf.join();
}