#!/usr/bin/env bash
set -euo pipefail

TOOLCHAIN_ROOT="${TOOLCHAIN_ROOT:?Set TOOLCHAIN_ROOT to extracted unified compiler artifact}"
OUTPUT="${OUTPUT:-$PWD/.host-link-probe/XtoolCompilerHostProbe}"
IOS_DEPLOYMENT_TARGET="${IOS_DEPLOYMENT_TARGET:-17.0}"

ARCHIVE="$TOOLCHAIN_ROOT/libXtoolUnifiedCompiler.a"
INCLUDES="$TOOLCHAIN_ROOT/include"
SDK="$(xcrun --sdk iphoneos --show-sdk-path)"
CLANG="$(xcrun --find clang++)"

if [ ! -f "$ARCHIVE" ]; then
  echo "Missing unified archive: $ARCHIVE" >&2
  exit 1
fi

if [ ! -d "$INCLUDES" ]; then
  echo "Missing unified headers: $INCLUDES" >&2
  exit 1
fi

BUILD_DIR="$(dirname "$OUTPUT")"
OBJ_DIR="$BUILD_DIR/objects"

rm -rf "$BUILD_DIR"
mkdir -p "$OBJ_DIR"

COMMON=(
  -target "arm64-apple-ios$IOS_DEPLOYMENT_TARGET"
  -isysroot "$SDK"
  -std=c++17
  -fexceptions
  -frtti
  -I "$INCLUDES"
  -I "$PWD/Sources/CXtoolCompilerBridge/include"
)

"$CLANG" "${COMMON[@]}"   -c Support/SwiftFrontendAdapter.cpp   -o "$OBJ_DIR/SwiftFrontendAdapter.o"

"$CLANG" "${COMMON[@]}"   -c Support/ClangAdapter.cpp   -o "$OBJ_DIR/ClangAdapter.o"

"$CLANG" "${COMMON[@]}"   -c Support/LLDMachOAdapter.cpp   -o "$OBJ_DIR/LLDMachOAdapter.o"

"$CLANG" "${COMMON[@]}"   -c Support/HostLinkProbe.cpp   -o "$OBJ_DIR/HostLinkProbe.o"

xcrun --sdk iphoneos clang   -target "arm64-apple-ios$IOS_DEPLOYMENT_TARGET"   -isysroot "$SDK"   -c Sources/CXtoolCompilerBridge/CXtoolCompilerBridge.c   -I Sources/CXtoolCompilerBridge/include   -o "$OBJ_DIR/CXtoolCompilerBridge.o"

set +e
"$CLANG"   -target "arm64-apple-ios$IOS_DEPLOYMENT_TARGET"   -isysroot "$SDK"   "$OBJ_DIR/SwiftFrontendAdapter.o"   "$OBJ_DIR/ClangAdapter.o"   "$OBJ_DIR/LLDMachOAdapter.o"   "$OBJ_DIR/HostLinkProbe.o"   "$OBJ_DIR/CXtoolCompilerBridge.o"   -Wl,-force_load,"$ARCHIVE"   -lc++   -framework Foundation   -framework CoreFoundation   -framework Security   -framework SystemConfiguration   -o "$OUTPUT"   2>"$BUILD_DIR/linker-errors.txt"
STATUS=$?
set -e

if [ "$STATUS" -ne 0 ]; then
  echo "Host-link probe failed." >&2
  echo "Unresolved/linker diagnostics:" >&2
  cat "$BUILD_DIR/linker-errors.txt" >&2
  exit "$STATUS"
fi

file "$OUTPUT"
xcrun vtool -show-build "$OUTPUT" || true

echo "Host-link probe succeeded:"
echo "  $OUTPUT"
