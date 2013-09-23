import 'dart:io';
import 'package:path/path.dart' as path;

String get packageRootPath {
  var parts = path.split(path.absolute(new Options().script));
  int found = parts.lastIndexOf('ebisu');
  if(found >= 0) {
    return path.joinAll(parts.getRange(0, found+1));
  }
  throw new 
    StateError("Current directory must be within package 'ebisu'");
}

main() => print(packageRootPath);

