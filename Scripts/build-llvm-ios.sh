#!/usr/bin/env bash
set -euo pipefail

LLVM_REF="${LLVM_REF:-llvmorg-21.1.2}"
IOS_DEPLOYMENT_TARGET="${IOS_DEPLOYMENT_TARGET:-17.0}"
BUILD_TYPE="${BUILD_TYPE:-Release}"
ROOT="${ROOT:-$PWD/.native-toolchain}"
SRC="$ROOT/llvm-project"
BUILD="$ROOT/build-llvm-ios"
INSTALL="$ROOT/install-llvm-ios"

command -v git >/dev/null
command -v cmake >/dev/null
command -v ninja >/dev/null
command -v xcrun >/dev/null

SDK_PATH="$(xcrun --sdk iphoneos --show-sdk-path)"

mkdir -p "$ROOT"

if [ ! -d "$SRC/.git" ]; then
  git clone --filter=blob:none     https://github.com/llvm/llvm-project.git     "$SRC"
fi

git -C "$SRC" fetch --tags --force
git -C "$SRC" checkout --force "$LLVM_REF"

rm -rf "$BUILD" "$INSTALL"
mkdir -p "$BUILD" "$INSTALL"

cmake -S "$SRC/llvm" -B "$BUILD" -G Ninja   -DCMAKE_BUILD_TYPE="$BUILD_TYPE"   -DCMAKE_SYSTEM_NAME=iOS   -DCMAKE_OSX_SYSROOT="$SDK_PATH"   -DCMAKE_OSX_ARCHITECTURES=arm64   -DCMAKE_OSX_DEPLOYMENT_TARGET="$IOS_DEPLOYMENT_TARGET"   -DCMAKE_INSTALL_PREFIX="$INSTALL"   -DLLVM_ENABLE_PROJECTS="clang;lld"   -DLLVM_TARGETS_TO_BUILD=AArch64   -DLLVM_ENABLE_TERMINFO=OFF   -DLLVM_ENABLE_ZLIB=OFF   -DLLVM_ENABLE_ZSTD=OFF   -DLLVM_ENABLE_LIBXML2=OFF   -DLLVM_ENABLE_LIBEDIT=OFF   -DLLVM_ENABLE_ASSERTIONS=OFF   -DLLVM_BUILD_EXAMPLES=OFF   -DLLVM_INCLUDE_EXAMPLES=OFF   -DLLVM_INCLUDE_BENCHMARKS=OFF   -DLLVM_INCLUDE_TESTS=OFF   -DCLANG_INCLUDE_TESTS=OFF   -DLLD_INCLUDE_TESTS=OFF   -DBUILD_SHARED_LIBS=OFF   -DLLVM_BUILD_LLVM_DYLIB=OFF   -DLLVM_LINK_LLVM_DYLIB=OFF

cmake --build "$BUILD" --target   clangDriver   clangFrontend   clangFrontendTool   lldCommon   lldMachO

cmake --install "$BUILD"

cat > "$INSTALL/xtool-ios-toolchain.json" <<EOF
{
  "llvmRef": "$LLVM_REF",
  "architecture": "arm64",
  "platform": "iphoneos",
  "minimumIOSVersion": "$IOS_DEPLOYMENT_TARGET",
  "buildType": "$BUILD_TYPE",
  "sdkPath": "$SDK_PATH"
}
EOF

echo "LLVM/Clang/LLD iOS static libraries installed at:"
echo "  $INSTALL"
