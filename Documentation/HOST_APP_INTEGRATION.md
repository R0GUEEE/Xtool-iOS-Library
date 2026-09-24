# Host App Integration

After the **Unified Native Toolchain** workflow produces
`XtoolUnifiedCompiler-ios-arm64.tar.gz`, the compiler can be linked into an
iOS host application.

## 1. Install the artifact

```sh
chmod +x Scripts/install-unified-toolchain-artifact.sh

Scripts/install-unified-toolchain-artifact.sh \
  XtoolUnifiedCompiler-ios-arm64.tar.gz
```

The default destination is:

```
Vendor/XtoolUnifiedCompiler
```

## 2. Apply the xcconfig

Attach:

```
Support/XtoolNativeCompilerHost.xcconfig
```

to the iOS application target.

It configures:

- C++17
- compiler header search paths (the generated root, then the source root)
- the merged static archive
- baseline Apple frameworks used by the compiler host

The post-build host-link validation workflow remains the authority for any
additional system-library requirements.

## 3. Compile the adapters into the host target

Add:

```
Support/SwiftFrontendAdapter.cpp
Support/ClangAdapter.cpp
Support/LLDMachOAdapter.cpp
```

to the application target.

The adapters use constructor functions and automatically register themselves
with `CXtoolCompilerBridge` when the app image loads. Explicit registration
functions remain available for diagnostics.

## 4. Add XtoolMobileKit

Add this repository as a Swift package dependency and import:

```swift
import XtoolMobileKit
```

## 5. Verify compiler readiness

```swift
let status = try XtoolNativeCompilerHost.requireReady()
```

This verifies that the running app contains all three native backends:

- Swift frontend
- Clang
- Mach-O LLD

## 6. Create the native builder

```swift
let builder = XtoolApplicationBuilder.native(
    sdk: installedSDK
)
```

At that point the existing XtoolMobileKit pipeline can compile sources, link a
Mach-O executable, assemble the app bundle, sign it through XKit, and export an
IPA.

## Runtime SDK versus compiler libraries

The native compiler archive is a **build-time dependency of the host app** and
must be linked into that app.

The iPhoneOS SDK, Swift resource directory, framework interfaces, and related
toolchain resources are **runtime data** managed through `XtoolSDKStore`.

These are deliberately separate because iOS cannot dynamically install new
native compiler code into an already-signed application.
