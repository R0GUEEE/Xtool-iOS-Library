#!/usr/bin/env bash
set -euo pipefail

ROOT="${ROOT:-$PWD/.native-swift}"
INSTALL="${INSTALL:-$ROOT/install-swift-ios}"
OUTPUT="${OUTPUT:-$ROOT/XtoolSwiftFrontend-ios-arm64.tar.gz}"

if [ ! -d "$INSTALL/lib" ]; then
  echo "Missing Swift frontend install tree: $INSTALL" >&2
  exit 1
fi

LIB_COUNT="$(find "$INSTALL/lib" -type f -name '*.a' | wc -l | tr -d ' ')"

if [ "$LIB_COUNT" = "0" ]; then
  echo "No static libraries were produced." >&2
  exit 1
fi

mkdir -p "$(dirname "$OUTPUT")"
tar -C "$INSTALL" -czf "$OUTPUT" .

echo "Packaged $LIB_COUNT static libraries:"
echo "  $OUTPUT"
