# Native Compiler Bridge ABI

`CXtoolCompilerBridge` is the stable C boundary between
`XtoolMobileKit` and compiler implementations linked by a consuming app.

## Registration

The host can register three entry points:

- Swift frontend
- Clang
- Mach-O LLD

Each entry point receives:

- `argc`
- `argv`
- an optional working-directory path

and returns an integer exit status.

## Why registration is used

The package does not assume private Swift compiler symbols or specific LLVM
library symbol names. A host app can adapt the exact compiler build it ships to
this ABI.

This also avoids requiring `Process`, shell execution, or runtime executable
discovery.

## Expected host adapters

A future native support target can register wrappers around:

- a custom Swift frontend or Swift Driver executor,
- Clang's in-process driver,
- LLD's Mach-O library entry point.

## Capability detection

`XtoolNativeCompilerBridge.capabilities` reports which entry points have been
registered. Higher-level build UI can disable compilation until the required
compiler libraries are installed and registered.
