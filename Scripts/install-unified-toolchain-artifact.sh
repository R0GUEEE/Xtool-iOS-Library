#!/usr/bin/env bash
set -euo pipefail

ARCHIVE="${1:?usage: install-unified-toolchain-artifact.sh <artifact.tar.gz> [destination]}"
DESTINATION="${2:-$PWD/Vendor/XtoolUnifiedCompiler}"

if [ ! -f "$ARCHIVE" ]; then
  echo "Missing artifact: $ARCHIVE" >&2
  exit 1
fi

rm -rf "$DESTINATION"
mkdir -p "$DESTINATION"

tar -xzf "$ARCHIVE" -C "$DESTINATION"

required=(
  "$DESTINATION/libXtoolUnifiedCompiler.a"
  "$DESTINATION/XtoolUnifiedCompiler.libraries.txt"
  "$DESTINATION/xtool-unified-toolchain.json"
  "$DESTINATION/include"
  "$DESTINATION/include-generated"
)

for path in "${required[@]}"; do
  if [ ! -e "$path" ]; then
    echo "Installed artifact is missing: $path" >&2
    exit 1
  fi
done

echo "Installed unified compiler toolchain:"
echo "  $DESTINATION"
echo
echo "Use Support/XtoolNativeCompilerHost.xcconfig in the host iOS target."
echo "Compile these adapter sources into the same target:"
echo "  Support/SwiftFrontendAdapter.cpp"
echo "  Support/ClangAdapter.cpp"
echo "  Support/LLDMachOAdapter.cpp"
