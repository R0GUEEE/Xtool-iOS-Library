# Prebuilt Compiler Releases

The embedded Swift/Clang/LLD compiler is treated as a versioned binary dependency.

Normal development no longer rebuilds Swift or LLVM.

## Release model

The heavy workflow is:

`.github/workflows/unified-native-toolchain.yml`

It runs only through `workflow_dispatch`.

Inputs:

- `release_tag` — release tag such as `compiler-v0.1.0`
- `swift_scheme` — defaults to `release/6.2`
- `deployment_target` — defaults to `17.0`

A successful run:

1. Builds the revision-locked compiler.
2. Packages `XtoolUnifiedCompiler-ios-arm64.tar.gz`.
3. Uploads it as a workflow artifact.
4. Publishes or replaces the same asset on the selected GitHub Release.

## Caching

The release workflow restores:

- the Swift update-checkout source tree
- an `sccache` cache

The build script automatically configures C and C++ compiler launchers to use
`sccache` when it is installed.

This means repeated compiler-release builds can reuse unchanged LLVM/Clang/Swift
object compilation instead of rebuilding everything from scratch.

## Consuming the binary

Use:

```sh
Scripts/fetch-prebuilt-compiler.sh compiler-v0.1.0 Vendor/XtoolUnifiedCompiler
```

Or download the latest compiler release:

```sh
Scripts/fetch-prebuilt-compiler.sh latest Vendor/XtoolUnifiedCompiler
```

The script downloads `XtoolUnifiedCompiler-ios-arm64.tar.gz` from GitHub
Releases and installs it using the existing artifact validator.

## CI

`Host Link Validation` and `Native Host App` now consume a compiler release.
They do not trigger the heavyweight compiler build.

The intended development loop is therefore:

```text
normal Swift / bridge / UI change
        ↓
download prebuilt compiler
        ↓
host-link validation
        ↓
build iOS app
```

The heavyweight compiler build is only needed when changing:

- Swift compiler revision
- LLVM/Clang/LLD revision
- compiler build configuration
- minimum deployment target
- embedded compiler ABI requirements
