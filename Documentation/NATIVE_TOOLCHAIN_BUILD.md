# Building Native LLVM/Clang/LLD for iOS

The repository includes a reproducible first-stage native toolchain build for
arm64 iPhoneOS.

## Local macOS build

Requirements:

- Xcode with an iPhoneOS SDK
- CMake
- Ninja
- Git

Run:

```sh
chmod +x Scripts/build-llvm-ios.sh
Scripts/build-llvm-ios.sh
```

The default configuration builds LLVM 21.1.2 for:

- platform: iPhoneOS
- architecture: arm64
- minimum deployment target: iOS 17
- static libraries only

The install tree is written to:

```
.native-toolchain/install-llvm-ios
```

## GitHub Actions

Run the **Native Toolchain** workflow manually. It packages the install tree as
an artifact named:

```
XtoolNativeLLVM-ios-arm64
```

Normal CI does not run this workflow because LLVM builds are large.

## Why an install tree is produced

Clang and LLD depend on multiple LLVM libraries. Producing the complete install
tree is more robust than guessing a tiny static-library subset too early.

The host application's native compiler target can then select and link the
libraries required by:

- `Support/ClangAdapter.cpp`
- `Support/LLDMachOAdapter.cpp`

## Swift frontend

The Swift frontend requires a separate compiler build and depends on LLVM plus
large parts of the Swift compiler implementation. It is intentionally not mixed
into the LLVM stage. Once the LLVM artifact is validated, the Swift compiler
stage can consume a compatible LLVM build and produce the libraries required by
`Support/SwiftFrontendAdapter.cpp`.
