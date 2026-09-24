# Architecture

## Goal

Run as much of Xtool as possible directly inside a native iOS application without
embedding a Linux VM or shell environment.

## Layer 1: XKit integration

Xtool already exposes `XKit` as a SwiftPM library and declares iOS 16+ support.
This project links that library directly.

This layer should contain:

- Apple Developer Services integration
- signing-related reusable APIs exposed by XKit
- reusable device/service logic that is valid on iOS
- project metadata and configuration handling

## Layer 2: Native build engine

Do not invoke the `xtool` executable from iOS.

The build engine should instead expose Swift APIs for:

1. loading a SwiftPM project
2. locating an embedded Darwin SDK
3. invoking compiler/linker functionality through an iOS-compatible backend
4. processing resources
5. constructing an `.app`
6. signing the result
7. producing an `.ipa`

`XtoolBuilder` is the boundary for this layer.

## Layer 3: Toolchain payload

A future implementation can package toolchain resources separately from the core
library so the application can manage storage independently.

Potential components:

- Swift frontend/toolchain binaries that can execute in the chosen runtime
- clang/LLVM components
- ld64-compatible linker support
- Darwin SDK
- asset catalog compiler
- signing backend

## Important iOS constraint

A normal App Store iOS process cannot rely on macOS-style `Process` execution.
The project therefore treats process spawning as unavailable on iOS and keeps
the compiler backend abstract.

For sideloaded/development environments, the exact execution mechanism can be
implemented later without coupling the public library API to it.
