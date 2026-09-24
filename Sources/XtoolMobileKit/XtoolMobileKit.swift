import Foundation
import XKit

/// Entry point for embedding Xtool's reusable library components in a native app.
///
/// This package intentionally depends on `XKit`, not the `xtool` executable.
/// The CLI contains host-oriented functionality that should not be treated as
/// an in-process iOS API.
public enum XtoolMobileKit {
    public static let version = "0.1.0"

    /// Indicates that the package was built with XKit linked successfully.
    public static var isXKitLinked: Bool {
        true
    }

    public static var runtime: XtoolRuntimeCapabilities {
        .current
    }
}
