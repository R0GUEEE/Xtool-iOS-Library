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
Scripts/merge-static-archives.sh   "$INSTALL/lib"   "$MERGED"   "$MANIFEST"

mkdir -p "$(dirname "$OUTPUT")"
tar -C "$INSTALL" -czf "$OUTPUT" .

echo "$OUTPUT"
