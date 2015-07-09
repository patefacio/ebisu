import 'package:logging/logging.dart';
import 'test_it.dart' as test_it;

main() {
  Logger.root.level = Level.OFF;
  Logger.root.onRecord.listen((LogRecord rec) {
    print('${rec.level.name}: ${rec.time}: ${rec.message}');
  });

  test_it.main();
}

