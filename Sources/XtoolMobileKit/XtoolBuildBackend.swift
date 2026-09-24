import Foundation

public protocol XtoolBuildBackend: Sendable {
    var identifier: String { get }

    func build(
        _ request: XtoolBuildRequest,
        events: @escaping @Sendable (XtoolBuildEvent) -> Void
    ) async throws -> XtoolBuildResult
}

public struct UnavailableIOSBuildBackend: XtoolBuildBackend {
    public let identifier = "ios.unavailable"

    public init() {}

    public func build(
        _ request: XtoolBuildRequest,
        events: @escaping @Sendable (XtoolBuildEvent) -> Void
    ) async throws -> XtoolBuildResult {
        events(.init(
            phase: .preparing,
            message: "Checking on-device compiler backend."
        ))

        throw XtoolMobileError.onDeviceCompilerBackendNotInstalled
    }
}
