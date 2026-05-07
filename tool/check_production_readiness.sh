#!/usr/bin/env bash
set -euo pipefail

FLUTTER_BIN="${FLUTTER_BIN:-/usr/local/share/flutter/bin/flutter}"
DART_BIN="${DART_BIN:-/usr/local/share/flutter/bin/dart}"

"$FLUTTER_BIN" pub get
"$DART_BIN" format --set-exit-if-changed .
"$FLUTTER_BIN" analyze
"$FLUTTER_BIN" test
"$DART_BIN" --packages=.dart_tool/package_config.json tool/audit_user_facing_copy.dart
