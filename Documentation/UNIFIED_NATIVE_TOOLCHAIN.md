# Unified Native Toolchain

The preferred on-device compiler artifact is built from one synchronized Swift
source checkout.

## Why unified

Swift compiler libraries depend on a specific LLVM/Clang revision. Combining a
Swift frontend built from one revision with an independently selected LLVM
release can introduce C++ ABI and internal API mismatches.

The unified build uses Swift's own `update-checkout` scheme to obtain:

- Swift
- LLVM
- Clang
- LLD
- related Swift dependencies

from one compatible revision set.

## Artifact

The workflow emits:

```
XtoolUnifiedCompiler-ios-arm64.tar.gz
```

containing:

```
libXtoolUnifiedCompiler.a
XtoolUnifiedCompiler.libraries.txt
xtool-unified-toolchain.json
include/
lib/
```

## Embedded entry points

The merged archive is validated for the library APIs used by XtoolMobileKit:

- `swift::performFrontend`
- Clang `CompilerInvocation` / `ExecuteCompilerInvocation`
- `lld::lldMain`

## Preferred integration

The host application should link the unified archive rather than mixing the
older standalone LLVM and Swift artifacts.

Those older workflows remain useful for diagnostics and experimenting with
individual compiler layers, but the unified artifact is the canonical path for
the complete on-device compiler.
