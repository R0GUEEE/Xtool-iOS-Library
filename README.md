# XtoolMobileKit

Native Swift library for embedding reusable Xtool functionality inside an iOS
application.

## Objective

The long-term objective is a native, self-contained iOS development stack:
project management, compilation, packaging, signing, and IPA export without a
Linux VM.

The project begins by integrating Xtool's reusable `XKit` library directly and
keeps the on-device compiler runtime behind a separate `XtoolBuilder` API.

## Requirements

- Swift 6.2+
- iOS 16+
- macOS 13+ for host-side development

## Installation

```swift
dependencies: [
    .package(
        url: "https://github.com/R0GUEEE/Xtool-iOS-Library",
        branch: "main"
    )
]
```

Then add:

```swift
.product(name: "XtoolMobileKit", package: "Xtool-iOS-Library")
```

## Basic usage

```swift
import XtoolMobileKit

print(XtoolMobileKit.isXKitLinked)

let workspace = XtoolWorkspace(
    rootURL: URL(fileURLWithPath: "/path/to/project")
)

let builder = NativeIOSXtoolBuilder()
let request = XtoolBuildRequest(workspace: workspace)

Task {
    do {
        let result = try await builder.build(request)
        print(result)
    } catch {
        print(error)
    }
}
```

## Why XKit instead of the xtool CLI?

Xtool publishes `XKit` as a library product. This is the appropriate integration
surface for an iOS application. The CLI is designed around host environments
and should not be treated as an in-process mobile API.

## Current status

This is an initial architecture scaffold. `XKit` is linked; the on-device
compiler backend is intentionally not implemented yet.

See:

- `Documentation/ARCHITECTURE.md`
- `Documentation/ROADMAP.md`

## Upstream

Xtool: https://github.com/xtool-org/xtool

This project is independent of the Xtool project unless/until upstream chooses
to collaborate.
