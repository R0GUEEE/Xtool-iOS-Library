# Native Swift Frontend Integration

Swift Driver is useful for planning compiler jobs, but it does not itself
replace the Swift compiler frontend. XtoolMobileKit therefore targets the
compiler frontend directly.

## Frontend API

The Swift compiler source exposes:

```cpp
swift::performFrontend(...)
```

through `swift/FrontendTool/FrontendTool.h`.

This is the same frontend path used by the Swift compiler driver when handling
an integrated `-frontend` invocation.

## Invocation model

XtoolMobileKit now emits direct frontend arguments:

```
-frontend
-c
-target arm64-apple-ios<deployment>
-sdk <iPhoneOS.sdk>
-module-name <name>
...
-o <module>.o
```

The native adapter removes the leading `-frontend` before calling
`swift::performFrontend`.

## Compiler initialization

The adapter calls `swift::initializeSwiftModules()` once before the first
frontend invocation. This mirrors the Swift driver's own integrated frontend
path.

## NativeToolchainSupport

The built-in support target contains an optional implementation guarded by:

```
XTOOL_ENABLE_EMBEDDED_SWIFT_FRONTEND=1
```

Default package builds leave it disabled so CI and ordinary users do not need a
full Swift compiler source build.

## Host-owned adapter

`Support/SwiftFrontendAdapter.cpp` can be compiled into the host application
alongside a custom iOS-compatible Swift compiler build. After linking the
required Swift compiler and LLVM libraries, call:

```c
xtool_register_host_swift_frontend();
```

The registered frontend immediately becomes available through
`XtoolNativeCompilerBridge`.

## Remaining work

The repository still needs a reproducible build recipe that produces
iOS-compatible static libraries for the Swift frontend and its required LLVM
components. That artifact is substantially larger and more complex than the
XtoolMobileKit API itself.
