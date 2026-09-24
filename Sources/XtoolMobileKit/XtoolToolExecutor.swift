import Foundation

public protocol XtoolToolExecutor: Sendable {
    var identifier: String { get }

    func execute(
        _ invocation: XtoolInvocation
    ) async throws -> XtoolInvocationResult
}

public struct UnavailableIOSToolExecutor: XtoolToolExecutor {
    public let identifier = "ios.unavailable"

    public init() {}

    public func execute(
        _ invocation: XtoolInvocation
    ) async throws -> XtoolInvocationResult {
        throw XtoolMobileError.toolExecutionUnavailable(
            invocation.executableURL.lastPathComponent
        )
    }
}
