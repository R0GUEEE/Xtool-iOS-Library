#!/usr/bin/env bash
set -euo pipefail

ROOT="${ROOT:-$PWD/.native-swift}"
INSTALL="${INSTALL:-$ROOT/install-swift-ios}"
OUTPUT="${OUTPUT:-$ROOT/XtoolSwiftFrontend-ios-arm64.tar.gz}"
MERGED="$INSTALL/libXtoolSwiftFrontend.a"
MANIFEST="$INSTALL/XtoolSwiftFrontend.libraries.txt"

if [ ! -d "$INSTALL/lib" ]; then
  echo "Missing Swift frontend install tree: $INSTALL" >&2
  exit 1
fi

LIB_COUNT="$(find "$INSTALL/lib" -type f -name '*.a' | wc -l | tr -d ' ')"

if [ "$LIB_COUNT" = "0" ]; then
  echo "No static libraries were produced." >&2
  exit 1
fi

chmod +x Scripts/merge-static-archives.sh
Scripts/merge-static-archives.sh "$INSTALL/lib" "$MERGED" "$MANIFEST"

chmod +x Scripts/validate-native-archive.sh
Scripts/validate-native-archive.sh "$MERGED" swift

mkdir -p "$(dirname "$OUTPUT")"
tar -C "$INSTALL" -czf "$OUTPUT" .

echo "Packaged $LIB_COUNT static libraries:"
echo "  $OUTPUT"
echo "Merged frontend archive:"
echo "  $MERGED"
