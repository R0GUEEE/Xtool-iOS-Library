# Embedded Toolchain Bridge

## Why this exists

iOS does not provide a general-purpose process-spawning API suitable for invoking
an embedded `swiftc`, `clang`, or `ld64.lld` binary the same way a desktop
host does.

The library therefore separates **build planning** from **tool execution**.

## Swift

Swift compilation is split into two layers:

1. Swift Driver-style orchestration
2. Swift frontend execution

The project does not assume that the `swiftc` executable itself is callable
inside an iOS process. A host application should supply an
`XtoolEmbeddedToolBridge` implementation that can execute compiler functionality
linked into the application.

`XtoolSwiftFrontendInvocationBuilder` emits frontend-oriented arguments.

## Clang

Clang has an in-process driver architecture. The bridge API maps Clang
invocations onto a native entry point supplied by the host application's
embedded LLVM/Clang build.

## LLD

LLVM LLD supports use as a library. The bridge exposes a Mach-O flavor so a
native implementation can route arguments into an embedded LLD library rather
than launching `ld64.lld` as a process.

## Host-side implementation

The Swift package intentionally does not ship LLVM/Swift compiler binaries or
static libraries. A consuming application can provide a bridge through one of:

- a native Swift/C/C++ target linked against a custom Swift compiler build,
- a Clang/LLVM static-library target,
- an LLD static-library target,
- another permitted execution mechanism in a sideloaded development build.

The public build pipeline remains independent of the exact implementation.

## Boundary

`XtoolEmbeddedToolExecutor` converts the existing
`XtoolInvocation` model into bridge calls. That allows the higher-level compiler,
resource, bundle, signing, and IPA APIs to remain unchanged when the low-level
execution mechanism evolves.
