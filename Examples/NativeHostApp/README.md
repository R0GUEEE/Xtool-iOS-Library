# Native Host App

This sample application verifies that the unified Swift/Clang/LLD compiler can
be linked directly into an iOS application together with XtoolMobileKit.

## Generated project

The project uses XcodeGen so the repository does not need to store a generated
`.xcodeproj`.

From this directory:

```sh
xcodegen generate
```

## Unified compiler artifact

Install the validated toolchain before generating/building:

```sh
../../Scripts/install-unified-toolchain-artifact.sh \
  XtoolUnifiedCompiler-ios-arm64.tar.gz \
  Vendor/XtoolUnifiedCompiler
```

## What the app verifies

At launch the three native adapter translation units automatically register:

- Swift frontend
- Clang
- Mach-O LLD

The UI reads:

```swift
XtoolNativeCompilerHost.status
```

and displays whether all native compiler backends are present.

This sample is the first host target intended to evolve into an on-device
Xcode/Xtool-style development application.
