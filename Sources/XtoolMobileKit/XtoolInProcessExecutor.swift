import Foundation

public typealias XtoolInProcessToolHandler =
    @Sendable (XtoolInvocation) async throws -> XtoolInvocationResult

public struct XtoolInProcessExecutor: XtoolToolExecutor {
    public let identifier: String

    private let handlers: [String: XtoolInProcessToolHandler]

    public init(
        identifier: String = "ios.in-process",
        handlers: [String: XtoolInProcessToolHandler]
    ) {
        self.identifier = identifier
        self.handlers = handlers
    }

    public func execute(
        _ invocation: XtoolInvocation
    ) async throws -> XtoolInvocationResult {
        let name = invocation.executableURL.lastPathComponent

        guard let handler = handlers[name] else {
            throw XtoolMobileError.toolExecutionUnavailable(name)
        }

        return try await handler(invocation)
    }
}
