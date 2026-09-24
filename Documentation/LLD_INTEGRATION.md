# Mach-O LLD Integration

XtoolMobileKit uses the native compiler bridge rather than launching
`ld64.lld` with `Process`.

## Current LLD library API

Current LLVM/LLD exposes `lld::lldMain` from
`lld/Common/Driver.h`. Library users provide the set of linked drivers.
For iOS output, the adapter registers the Darwin/Mach-O driver.

The bridge prepends `ld64.lld` as argv[0] because the higher-level
`XtoolInvocation` stores only tool arguments.

## NativeToolchainSupport

The Swift package contains a `NativeToolchainSupport` C++ target.

By default it builds in stub mode:

```
XTOOL_ENABLE_EMBEDDED_LLD=0
```

That keeps ordinary SwiftPM consumers and CI independent of LLVM libraries.

A host build that provides LLD headers and linked LLD/LLVM libraries can compile
the implementation with:

```
XTOOL_ENABLE_EMBEDDED_LLD=1
```

and then call:

```c
xtool_native_toolchain_register_available_backends();
```

This registers the Mach-O linker entry point with `CXtoolCompilerBridge`.

## Standalone reference adapter

`Support/LLDMachOAdapter.cpp` is a standalone reference implementation for
host applications that prefer to own the LLVM target themselves. Compile it in
the host target, link the required LLD/LLVM libraries, and call:

```c
xtool_register_host_lld_macho();
```

No subprocess is created.

## Required LLVM linkage

Exact libraries vary by the LLVM build configuration, but the host must include
the Mach-O LLD driver and its LLVM dependencies. Static linking is preferred for
an iOS host application.

The integration deliberately uses the public LLD library driver API rather than
private linker executable symbols.
