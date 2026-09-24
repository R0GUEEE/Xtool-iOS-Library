import Foundation

public struct XtoolEmbeddedToolExecutor: XtoolToolExecutor {
    public let identifier: String
    public let bridge: any XtoolEmbeddedToolBridge

    public init(
        bridge: any XtoolEmbeddedToolBridge
    ) {
        self.bridge = bridge
        self.identifier = "embedded.\(bridge.identifier)"
    }

    public func execute(
        _ invocation: XtoolInvocation
    ) async throws -> XtoolInvocationResult {
        let tool = invocation.executableURL.lastPathComponent

        switch tool {
        case "swiftc", "swift-frontend", "swift-driver":
            return try await bridge.runSwiftFrontend(
                arguments: invocation.arguments,
                environment: invocation.environment,
                workingDirectory: invocation.workingDirectory
            )

        case "clang", "clang++":
            return try await bridge.runClang(
                arguments: invocation.arguments,
                environment: invocation.environment,
                workingDirectory: invocation.workingDirectory
            )

        case "ld", "ld64", "ld64.lld", "lld":
            return try await bridge.runLLD(
                flavor: .macho,
                arguments: invocation.arguments,
                environment: invocation.environment,
                workingDirectory: invocation.workingDirectory
            )

        default:
            throw XtoolMobileError.toolExecutionUnavailable(tool)
        }
    }
}
