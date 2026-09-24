#!/usr/bin/env bash
set -euo pipefail

SWIFT_SCHEME="${SWIFT_SCHEME:-release/6.2}"
IOS_DEPLOYMENT_TARGET="${IOS_DEPLOYMENT_TARGET:-17.0}"
BUILD_TYPE="${BUILD_TYPE:-Release}"
ROOT="${ROOT:-$PWD/.unified-toolchain}"

SOURCE_ROOT="$ROOT/source"
SWIFT_SRC="$SOURCE_ROOT/swift"
LLVM_SRC="$SOURCE_ROOT/llvm-project/llvm"
BUILD_NATIVE="$ROOT/build-native-tools"
BUILD_CMARK_NATIVE="$ROOT/build-native-cmark"
BUILD_IOS="$ROOT/build-ios"
INSTALL="$ROOT/install-ios"

command -v git >/dev/null
command -v cmake >/dev/null
command -v ninja >/dev/null
command -v python3 >/dev/null
command -v xcrun >/dev/null

IOS_SDK="$(xcrun --sdk iphoneos --show-sdk-path)"
MACOS_SDK="$(xcrun --sdk macosx --show-sdk-path)"
HOST_SWIFTC="$(xcrun --find swiftc)"
HOST_BIN="$(dirname "$HOST_SWIFTC")"
TARGET_TRIPLE="arm64-apple-ios${IOS_DEPLOYMENT_TARGET}"

mkdir -p "$SOURCE_ROOT"

if [ ! -d "$SWIFT_SRC/.git" ]; then
  git clone --filter=blob:none     https://github.com/swiftlang/swift.git     "$SWIFT_SRC"
fi

(
  cd "$SOURCE_ROOT"
  "$SWIFT_SRC/utils/update-checkout"     --clone     --scheme "$SWIFT_SCHEME"
)

rm -rf "$BUILD_NATIVE" "$BUILD_CMARK_NATIVE" "$BUILD_IOS" "$INSTALL"
mkdir -p "$BUILD_NATIVE" "$BUILD_CMARK_NATIVE" "$BUILD_IOS" "$INSTALL"

# Native generators required for cross-compiling the iOS libraries.
cmake -S "$LLVM_SRC" -B "$BUILD_NATIVE" -G Ninja   -DCMAKE_BUILD_TYPE="$BUILD_TYPE"   -DCMAKE_OSX_SYSROOT="$MACOS_SDK"   -DLLVM_ENABLE_PROJECTS="clang;lld"   -DLLVM_TARGETS_TO_BUILD=AArch64   -DLLVM_INCLUDE_TESTS=OFF   -DCLANG_INCLUDE_TESTS=OFF   -DLLD_INCLUDE_TESTS=OFF

cmake --build "$BUILD_NATIVE" --target   llvm-tblgen   clang-tblgen

# Swift's configure step executes cmark --version, so provide a native macOS
# cmark tool while the iOS external-project graph builds libcmark-gfm for iOS.
cmake -S "$SOURCE_ROOT/cmark" -B "$BUILD_CMARK_NATIVE" -G Ninja   -DCMAKE_BUILD_TYPE="$BUILD_TYPE"   -DCMAKE_OSX_SYSROOT="$MACOS_SDK"   -DCMARK_TESTS=OFF
cmake --build "$BUILD_CMARK_NATIVE" --target cmark-gfm
mkdir -p "$BUILD_CMARK_NATIVE/src"
ln -sf "$BUILD_CMARK_NATIVE/src/cmark-gfm" "$BUILD_CMARK_NATIVE/src/cmark"

LLVM_TBLGEN="$BUILD_NATIVE/bin/llvm-tblgen"
CLANG_TBLGEN="$BUILD_NATIVE/bin/clang-tblgen"
C_FLAGS="-arch arm64 -target $TARGET_TRIPLE"

cmake -S "$LLVM_SRC" -B "$BUILD_IOS" -G Ninja   -DCMAKE_BUILD_TYPE="$BUILD_TYPE"   -DCMAKE_SYSTEM_NAME=iOS   -DCMAKE_OSX_SYSROOT="$IOS_SDK"   -DCMAKE_OSX_ARCHITECTURES=arm64   -DCMAKE_OSX_DEPLOYMENT_TARGET="$IOS_DEPLOYMENT_TARGET"   -DCMAKE_C_FLAGS="$C_FLAGS"   -DCMAKE_CXX_FLAGS="$C_FLAGS"   -DCMAKE_Swift_COMPILER="$HOST_SWIFTC"   -DCMAKE_Swift_COMPILER_TARGET="$TARGET_TRIPLE"   -DLLVM_HOST_TRIPLE="$TARGET_TRIPLE"   -DLLVM_TARGET_ARCH=arm64   -DLLVM_TARGETS_TO_BUILD=AArch64   -DLLVM_TABLEGEN="$LLVM_TBLGEN"   -DCLANG_TABLEGEN="$CLANG_TBLGEN"   -DLLVM_NATIVE_BUILD="$BUILD_NATIVE"   -DLLVM_ENABLE_PROJECTS="clang;lld"   -DLLVM_EXTERNAL_PROJECTS="swift;cmark"   -DLLVM_EXTERNAL_SWIFT_SOURCE_DIR="$SWIFT_SRC"   -DLLVM_EXTERNAL_CMARK_SOURCE_DIR="$SOURCE_ROOT/cmark"   -DSWIFT_PATH_TO_CMARK_BUILD="$BUILD_CMARK_NATIVE"   -DLLVM_INCLUDE_TOOLS=ON   -DLLVM_BUILD_TOOLS=OFF   -DLLVM_INCLUDE_UTILS=OFF   -DLLVM_BUILD_UTILS=OFF   -DLLVM_INCLUDE_EXAMPLES=OFF   -DLLVM_BUILD_EXAMPLES=OFF   -DLLVM_INCLUDE_BENCHMARKS=OFF   -DLLVM_BUILD_BENCHMARKS=OFF   -DLLVM_INSTALL_TOOLCHAIN_ONLY=ON   -DCLANG_BUILD_TOOLS=OFF   -DLLD_BUILD_TOOLS=OFF   -DSWIFT_HOST_VARIANT=iphoneos   -DSWIFT_HOST_VARIANT_SDK=IOS   -DSWIFT_HOST_VARIANT_ARCH=arm64   -DSWIFT_DARWIN_DEPLOYMENT_VERSION_IOS="$IOS_DEPLOYMENT_TARGET"   -DSWIFT_NATIVE_LLVM_TOOLS_PATH="$BUILD_NATIVE/bin"   -DSWIFT_NATIVE_CLANG_TOOLS_PATH="$HOST_BIN"   -DSWIFT_NATIVE_SWIFT_TOOLS_PATH="$HOST_BIN"   -DSWIFT_BUILD_PERF_TESTSUITE=OFF   -DSWIFT_INCLUDE_DOCS=OFF   -DSWIFT_INCLUDE_TESTS=OFF   -DSWIFT_BUILD_REMOTE_MIRROR=OFF   -DSWIFT_BUILD_DYNAMIC_STDLIB=OFF   -DSWIFT_BUILD_STATIC_STDLIB=OFF   -DSWIFT_BUILD_DYNAMIC_SDK_OVERLAY=OFF   -DSWIFT_BUILD_STATIC_SDK_OVERLAY=OFF   -DSWIFT_BUILD_STDLIB_EXTRA_TOOLCHAIN_CONTENT=OFF   -DSWIFT_BUILD_SOURCEKIT=OFF   -DSWIFT_BUILD_IMMEDIATE_MODE=OFF   -DSWIFT_BUILD_SWIFT_SYNTAX=OFF   -DLLVM_ENABLE_LIBXML2=OFF   -DLLVM_ENABLE_LIBEDIT=OFF   -DLLVM_ENABLE_TERMINFO=OFF   -DLLVM_ENABLE_ZLIB=OFF   -DLLVM_ENABLE_ZSTD=OFF   -DLLVM_INCLUDE_TESTS=OFF   -DCLANG_INCLUDE_TESTS=OFF   -DLLD_INCLUDE_TESTS=OFF   -DBOOTSTRAPPING_MODE=HOSTTOOLS   -DSWIFT_PATH_TO_STRING_PROCESSING_SOURCE="$SOURCE_ROOT/swift-experimental-string-processing"   -DSWIFT_PATH_TO_SWIFT_SYNTAX_SOURCE="$SOURCE_ROOT/swift-syntax"   -DHAVE_POSIX_REGEX=TRUE   -DHAVE_STEADY_CLOCK=TRUE

# Build only the library targets required by the embedded bridge.
cmake --build "$BUILD_IOS" --target   swiftFrontendTool   clangFrontendTool   clangDriver   lldCommon   lldMachO

mkdir -p   "$INSTALL/lib"   "$INSTALL/include"

# Keep all revision-matched static libraries from this build graph.
find "$BUILD_IOS/lib" -type f -name '*.a' -exec cp {} "$INSTALL/lib/" \;

# Preserve standard include layout.
cp -R "$SWIFT_SRC/include/." "$INSTALL/include/"
cp -R "$SOURCE_ROOT/llvm-project/llvm/include/." "$INSTALL/include/"
cp -R "$SOURCE_ROOT/llvm-project/clang/include/." "$INSTALL/include/"
cp -R "$SOURCE_ROOT/llvm-project/lld/include/." "$INSTALL/include/"

# Overlay generated headers.
for generated in   "$BUILD_IOS/include"   "$BUILD_IOS/tools/clang/include"   "$BUILD_IOS/tools/swift/include"
do
  if [ -d "$generated" ]; then
    cp -R "$generated/." "$INSTALL/include/"
  fi
done

cat > "$INSTALL/xtool-unified-toolchain.json" <<EOF
{
  "swiftScheme": "$SWIFT_SCHEME",
  "architecture": "arm64",
  "platform": "iphoneos",
  "minimumIOSVersion": "$IOS_DEPLOYMENT_TARGET",
  "targetTriple": "$TARGET_TRIPLE",
  "buildType": "$BUILD_TYPE",
  "components": [
    "swiftFrontendTool",
    "clangFrontendTool",
    "clangDriver",
    "lldCommon",
    "lldMachO"
  ]
}
EOF

echo "Unified compiler libraries staged at:"
echo "  $INSTALL"
