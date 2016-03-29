#!/bin/bash
# dart tool/hop_runner.dart analyze_lib
# use dartanalyzer directly instead of hop_runner
/usr/lib/dart/bin/dartanalyzer lib/*.dart test/*.dart
dart test/runner.dart
