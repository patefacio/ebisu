/// Library with common utilities for generating code.
///
/// The *ebisu* package has two primary libraries with following focus:
///
/// - *ebisu.dart* Assist in generating source text in code generation
/// - *ebisu_dart_meta.dart* Assist in generating *Dart* source code
///
///
library ebisu.ebisu;

import 'dart:convert' as convert;
import 'dart:io';
import 'dart:math';
import 'package:dart_style/dart_style.dart';
import 'package:id/id.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as path;
import 'package:quiver/iterables.dart';
// custom <additional imports>

// end <additional imports>

part 'src/ebisu/random_support.dart';
part 'src/ebisu/ebisu_variables.dart';
part 'src/ebisu/json_support.dart';
part 'src/ebisu/codegen_utils.dart';
part 'src/ebisu/code_block.dart';

final _logger = new Logger('ebisu');

// custom <library ebisu>

// end <library ebisu>
