#!/bin/bash

# Fast fail the script on failures.
set -e

# Skipping this until at least we have a dev release that aligns with dart_style version
# $(dirname -- "$0")/ensure_dartfmt.sh

# Run the tests.
dart ../test/runner.dart

# Run the build.dart file - just to make sure it works
dart hop_runner.dart analyze_lib

