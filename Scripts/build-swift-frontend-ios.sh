#!/usr/bin/env bash
set -euo pipefail

SWIFT_SCHEME="${SWIFT_SCHEME:-release/6.2}"
IOS_DEPLOYMENT_TARGET="${IOS_DEPLOYMENT_TARGET:-17.0}"
BUILD_TYPE="${BUILD_TYPE:-Release}"
ROOT="${ROOT:-$PWD/.native-swift}"
SOURCE_ROOT="$ROOT/source"
SWIFT_SRC="$SOURCE_ROOT/swift"
LLVM_SRC="$SOURCE_ROOT/llvm-project/llvm"
BUILD_NATIVE="$ROOT/build-native-tools"
BUILD_IOS="$ROOT/build-swift-ios"
PACKAGE_ROOT="$ROOT/install-swift-ios"

command -v git >/dev/null
command -v cmake >/dev/null
command -v ninja >/dev/null
command -v python3 >/dev/null
command -v xcrun >/dev/null

SDK_PATH="$(xcrun --sdk iphoneos --show-sdk-path)"
HOST_SDK_PATH="$(xcrun --sdk macosx --show-sdk-path)"
HOST_SWIFTC="$(xcrun --find swiftc)"
HOST_BIN="$(dirname "$HOST_SWIFTC")"
HOST_ARCH="$(uname -m)"
TARGET_TRIPLE="arm64-apple-ios${IOS_DEPLOYMENT_TARGET}"

mkdir -p "$SOURCE_ROOT"

if [ ! -d "$SWIFT_SRC/.git" ]; then
  git clone --filter=blob:none     https://github.com/swiftlang/swift.git     "$SWIFT_SRC"
fi

(
  cd "$SOURCE_ROOT"
  "$SWIFT_SRC/utils/update-checkout"     --clone     --scheme "$SWIFT_SCHEME"
)

rm -rf "$BUILD_NATIVE" "$BUILD_IOS" "$PACKAGE_ROOT"
mkdir -p "$BUILD_NATIVE" "$BUILD_IOS" "$PACKAGE_ROOT"

# Native tablegen tools are required while cross-compiling LLVM/Clang/Swift.
cmake -S "$LLVM_SRC" -B "$BUILD_NATIVE" -G Ninja   -DCMAKE_BUILD_TYPE="$BUILD_TYPE"   -DCMAKE_OSX_SYSROOT="$HOST_SDK_PATH"   -DLLVM_ENABLE_PROJECTS="clang"   -DLLVM_TARGETS_TO_BUILD=AArch64   -DLLVM_INCLUDE_TESTS=OFF   -DCLANG_INCLUDE_TESTS=OFF

cmake --build "$BUILD_NATIVE" --target   llvm-tblgen   clang-tblgen

LLVM_TBLGEN="$BUILD_NATIVE/bin/llvm-tblgen"
CLANG_TBLGEN="$BUILD_NATIVE/bin/clang-tblgen"

C_FLAGS="-arch arm64 -target $TARGET_TRIPLE"

cmake -S "$LLVM_SRC" -B "$BUILD_IOS" -G Ninja   -DCMAKE_BUILD_TYPE="$BUILD_TYPE"   -DCMAKE_SYSTEM_NAME=iOS   -DCMAKE_OSX_SYSROOT="$SDK_PATH"   -DCMAKE_OSX_ARCHITECTURES=arm64   -DCMAKE_OSX_DEPLOYMENT_TARGET="$IOS_DEPLOYMENT_TARGET"   -DCMAKE_C_FLAGS="$C_FLAGS"   -DCMAKE_CXX_FLAGS="$C_FLAGS"   -DCMAKE_Swift_COMPILER="$HOST_SWIFTC"   -DCMAKE_Swift_COMPILER_TARGET="$TARGET_TRIPLE"   -DLLVM_HOST_TRIPLE="$TARGET_TRIPLE"   -DLLVM_TARGET_ARCH=arm64   -DLLVM_TARGETS_TO_BUILD=AArch64   -DLLVM_TABLEGEN="$LLVM_TBLGEN"   -DCLANG_TABLEGEN="$CLANG_TBLGEN"   -DLLVM_NATIVE_BUILD="$BUILD_NATIVE"   -DLLVM_ENABLE_PROJECTS="clang"   -DLLVM_EXTERNAL_PROJECTS="swift"   -DLLVM_EXTERNAL_SWIFT_SOURCE_DIR="$SWIFT_SRC"   -DSWIFT_HOST_VARIANT=iphoneos   -DSWIFT_HOST_VARIANT_SDK=IOS   -DSWIFT_HOST_VARIANT_ARCH=arm64   -DSWIFT_DARWIN_DEPLOYMENT_VERSION_IOS="$IOS_DEPLOYMENT_TARGET"   -DSWIFT_NATIVE_LLVM_TOOLS_PATH="$BUILD_NATIVE/bin"   -DSWIFT_NATIVE_CLANG_TOOLS_PATH="$HOST_BIN"   -DSWIFT_NATIVE_SWIFT_TOOLS_PATH="$HOST_BIN"   -DSWIFT_BUILD_PERF_TESTSUITE=OFF   -DSWIFT_INCLUDE_DOCS=OFF   -DSWIFT_INCLUDE_TESTS=OFF   -DSWIFT_BUILD_REMOTE_MIRROR=OFF   -DSWIFT_BUILD_DYNAMIC_STDLIB=OFF   -DSWIFT_BUILD_STATIC_STDLIB=OFF   -DSWIFT_BUILD_DYNAMIC_SDK_OVERLAY=OFF   -DSWIFT_BUILD_STATIC_SDK_OVERLAY=OFF   -DSWIFT_BUILD_STDLIB_EXTRA_TOOLCHAIN_CONTENT=OFF   -DSWIFT_BUILD_SOURCEKIT=OFF   -DSWIFT_BUILD_IMMEDIATE_MODE=OFF   -DSWIFT_BUILD_SWIFT_SYNTAX=OFF   -DLLVM_ENABLE_LIBXML2=OFF   -DLLVM_ENABLE_LIBEDIT=OFF   -DLLVM_ENABLE_TERMINFO=OFF   -DLLVM_ENABLE_ZLIB=OFF   -DLLVM_ENABLE_ZSTD=OFF   -DLLVM_INCLUDE_TESTS=OFF   -DCLANG_INCLUDE_TESTS=OFF   -DBOOTSTRAPPING_MODE=HOSTTOOLS   -DCMARK_MAIN_INCLUDE_DIR="$SOURCE_ROOT/cmark/src"   -DCMARK_BUILD_INCLUDE_DIR="$BUILD_IOS/cmark"   -DSWIFT_PATH_TO_STRING_PROCESSING_SOURCE="$SOURCE_ROOT/swift-experimental-string-processing"   -DSWIFT_PATH_TO_SWIFT_SYNTAX_SOURCE="$SOURCE_ROOT/swift-syntax"   -DHAVE_POSIX_REGEX=TRUE   -DHAVE_STEADY_CLOCK=TRUE

cmake --build "$BUILD_IOS" --target swiftFrontendTool

mkdir -p   "$PACKAGE_ROOT/lib"   "$PACKAGE_ROOT/include/swift"   "$PACKAGE_ROOT/include/generated"

find "$BUILD_IOS/lib" -type f -name '*.a' -exec cp {} "$PACKAGE_ROOT/lib/" \;

cp -R "$SWIFT_SRC/include/swift/." "$PACKAGE_ROOT/include/swift/"
if [ -d "$BUILD_IOS/tools/swift/include" ]; then
  cp -R "$BUILD_IOS/tools/swift/include/." "$PACKAGE_ROOT/include/generated/"
fi
if [ -d "$BUILD_IOS/include" ]; then
  cp -R "$BUILD_IOS/include/." "$PACKAGE_ROOT/include/generated/"
fi

cat > "$PACKAGE_ROOT/xtool-swift-frontend.json" <<EOF
{
  "swiftScheme": "$SWIFT_SCHEME",
  "architecture": "arm64",
  "platform": "iphoneos",
  "minimumIOSVersion": "$IOS_DEPLOYMENT_TARGET",
  "targetTriple": "$TARGET_TRIPLE",
  "buildType": "$BUILD_TYPE",
  "frontendTarget": "swiftFrontendTool"
}
EOF

echo "Swift frontend iOS libraries staged at:"
echo "  $PACKAGE_ROOT"
