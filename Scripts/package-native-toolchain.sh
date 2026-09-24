#!/usr/bin/env bash
set -euo pipefail

ROOT="${ROOT:-$PWD/.native-toolchain}"
INSTALL="${INSTALL:-$ROOT/install-llvm-ios}"
OUTPUT="${OUTPUT:-$ROOT/XtoolNativeLLVM-ios-arm64.tar.gz}"
MERGED="$INSTALL/libXtoolLLVMCompilerSupport.a"
MANIFEST="$INSTALL/XtoolLLVMCompilerSupport.libraries.txt"

if [ ! -d "$INSTALL" ]; then
  echo "Missing install tree: $INSTALL" >&2
  exit 1
fi

chmod +x Scripts/merge-static-archives.sh
Scripts/merge-static-archives.sh "$INSTALL/lib" "$MERGED" "$MANIFEST"

chmod +x Scripts/validate-native-archive.sh
Scripts/validate-native-archive.sh "$MERGED" llvm

mkdir -p "$(dirname "$OUTPUT")"
tar -C "$INSTALL" -czf "$OUTPUT" .

echo "Native LLVM artifact:"
echo "  $OUTPUT"
echo "Merged compiler archive:"
echo "  $MERGED"
