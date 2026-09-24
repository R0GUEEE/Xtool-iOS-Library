import Foundation

public protocol XtoolBuilder: Sendable {
    func build(_ request: XtoolBuildRequest) async throws -> XtoolBuildResult
}

/// Initial iOS implementation.
///
/// The reusable XKit layer is already linkable from iOS. The actual on-device
/// compiler/toolchain execution layer is intentionally separated behind this
/// protocol so it can later be implemented with native embedded toolchain
/// components instead of `Process`.
public struct NativeIOSXtoolBuilder: XtoolBuilder {
    public init() {}

    public func build(_ request: XtoolBuildRequest) async throws -> XtoolBuildResult {
        #if os(iOS)
        throw XtoolMobileError.onDeviceCompilerBackendNotInstalled
        #else
        throw XtoolMobileError.unsupportedRuntime
        #endif
    }
}
