library setup;

import 'dart:io';
import 'package:ebisu/ebisu_dart_meta.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart';
import 'package:unittest/unittest.dart';
// custom <additional imports>
// end <additional imports>


final _logger = new Logger("setup");

dynamic _scratchRemoveMeFolder;

// custom <library setup>

String get tempPath {
  if(_scratchRemoveMeFolder == null) {
    _scratchRemoveMeFolder = 
      join(dirname(absolute(new Options().script)), 
          'scratch_remove_me');
  }

  return _scratchRemoveMeFolder;
}

System tempSystem(String id) =>
  system(id)..rootPath = tempPath;


void destroyTempData() {
  _logger.info("Destroying test data $tempPath");
}

// end <library setup>

