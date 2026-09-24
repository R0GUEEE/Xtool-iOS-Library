# Building the Swift Frontend for iOS

The repository now includes a separate heavyweight build pipeline for producing
the static libraries required by the in-process Swift frontend bridge.

## Source synchronization

The script uses Swift's own `utils/update-checkout` tool and defaults to:

```
release/6.2
```

This keeps the Swift compiler and its sibling repositories on a compatible
multi-repository revision set.

## Build stages

### 1. Native build tools

A macOS build directory first produces:

- `llvm-tblgen`
- `clang-tblgen`

Those executables run on the GitHub/macOS host while generating sources for the
cross-compiled compiler.

### 2. iPhoneOS compiler libraries

The second CMake configuration targets:

```
arm64-apple-ios17.0
```

by default and uses the iPhoneOS SDK from Xcode.

It configures Swift as an external LLVM project and builds:

```
swiftFrontendTool
```

which is the static library containing `swift::performFrontend(...)`.

The target pulls in the compiler subsystems needed by the frontend.

## Artifact

The script stages static libraries and headers under:

```
.native-swift/install-swift-ios
```

and the packaging script emits:

```
.native-swift/XtoolSwiftFrontend-ios-arm64.tar.gz
```

The manual **Swift Frontend Toolchain** GitHub Actions workflow uploads this
archive as an artifact.

## Why this is separate from normal CI

A Swift compiler build is large in CPU, storage, and wall-clock cost. Normal
XtoolMobileKit CI only verifies the bridge and package code.

## Next integration step

Once a successful artifact is produced, inspect the exact static-library set and
link requirements, then create a host integration target that links those
libraries with:

```
Support/SwiftFrontendAdapter.cpp
```

The adapter registers `swift::performFrontend` with
`CXtoolCompilerBridge`, enabling the existing on-device build pipeline.
