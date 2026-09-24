#!/usr/bin/env bash
set -euo pipefail

ROOT="${ROOT:-$PWD/.unified-toolchain}"
INSTALL="${INSTALL:-$ROOT/install-ios}"
OUTPUT="${OUTPUT:-$ROOT/XtoolUnifiedCompiler-ios-arm64.tar.gz}"
MERGED="$INSTALL/libXtoolUnifiedCompiler.a"
MANIFEST="$INSTALL/XtoolUnifiedCompiler.libraries.txt"

if [ ! -d "$INSTALL/lib" ]; then
  echo "Missing unified compiler install tree: $INSTALL" >&2
  exit 1
fi

chmod +x Scripts/merge-static-archives.sh
Scripts/merge-static-archives.sh "$INSTALL/lib" "$MERGED" "$MANIFEST"

chmod +x Scripts/validate-unified-toolchain.sh
Scripts/validate-unified-toolchain.sh "$MERGED"

tar -C "$INSTALL" -czf "$OUTPUT" .

echo "Unified compiler artifact:"
echo "  $OUTPUT"
echo "Merged compiler archive:"
echo "  $MERGED"
