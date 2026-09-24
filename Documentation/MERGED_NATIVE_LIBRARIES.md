# Merged Native Compiler Archives

The native-toolchain artifacts can contain a large number of static libraries.
Linking every archive manually in an application target is error-prone.

`Scripts/merge-static-archives.sh` creates a single aggregate archive using
Apple's `libtool -static`.

## LLVM/Clang/LLD

The LLVM packaging stage creates:

```
libXtoolLLVMCompilerSupport.a
```

alongside:

```
XtoolLLVMCompilerSupport.libraries.txt
```

The text manifest records every archive included in the aggregate.

## Swift frontend

The Swift frontend packaging stage creates:

```
libXtoolSwiftFrontend.a
```

and:

```
XtoolSwiftFrontend.libraries.txt
```

## Why retain the individual archives

The aggregate archive is intended to simplify host integration, but the
artifact also retains the original libraries. If the final application linker
reports duplicate symbols or requires a different dependency ordering, the
individual archives and manifest remain available for precise linkage.

## Host integration

A native host target will ultimately link:

- `libXtoolSwiftFrontend.a`
- `libXtoolLLVMCompilerSupport.a`
- the C/C++ adapters in `Support/`
- required Apple system frameworks/libraries

The exact final system-library set should be derived from the first successful
artifact link rather than hard-coded before the compiler artifacts exist.
