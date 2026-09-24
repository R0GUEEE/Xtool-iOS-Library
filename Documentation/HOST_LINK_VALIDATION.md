# Host Link Validation

A successful compiler cross-build is not sufficient by itself. The resulting
static libraries must also link together inside an arm64 iOS binary.

The **Host Link Validation** workflow runs automatically after a successful
**Unified Native Toolchain** workflow.

## What it validates

The workflow downloads the exact unified compiler artifact produced by the
triggering run and compiles:

- `Support/SwiftFrontendAdapter.cpp`
- `Support/ClangAdapter.cpp`
- `Support/LLDMachOAdapter.cpp`
- `Support/HostLinkProbe.cpp`
- `CXtoolCompilerBridge.c`

It then force-loads `libXtoolUnifiedCompiler.a` into a strict arm64 iOS link.

The probe registers all three compiler callbacks and ensures the final binary
contains a usable bridge path for:

- Swift frontend
- Clang
- Mach-O LLD

## Linker failures

If the link fails, the workflow uploads:

```
XtoolHostLinkDiagnostics
```

containing `linker-errors.txt`.

Those diagnostics are the authoritative source for the remaining Apple
frameworks, system libraries, missing compiler archives, or unsupported
host APIs.

## Why this is separate

This test validates the hardest native boundary without requiring a full UIKit
application project or code signing. Once it links, the same native objects and
archive can be placed into an iOS application target that uses
`XtoolMobileKit`.
