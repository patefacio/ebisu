/// Library with common utilities for generating code.
///
/// The *ebisu* package has two primary libraries with following focus:
///
/// - *ebisu.dart* Assist in generating source text in code generation
/// - *ebisu_dart_meta.dart* Assist in generating *Dart* source code
library ebisu.ebisu;

import 'dart:convert' as convert;
import 'dart:io';
import 'dart:math';
import 'package:collection/collection.dart';
import 'package:dart_style/dart_style.dart';
import 'package:id/id.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as path;
import 'package:quiver/core.dart';
import 'package:quiver/iterables.dart';
import 'package:stack_trace/stack_trace.dart';

// custom <additional imports>

// end <additional imports>

part 'src/ebisu/code_block.dart';
part 'src/ebisu/codegen_utils.dart';
part 'src/ebisu/command_line_parser.dart';
part 'src/ebisu/ebisu_variables.dart';
part 'src/ebisu/entity.dart';
part 'src/ebisu/json_support.dart';
part 'src/ebisu/random_support.dart';

final Logger _logger = new Logger('ebisu');

// custom <library ebisu>

// end <library ebisu>
