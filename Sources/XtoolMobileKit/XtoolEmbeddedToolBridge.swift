import Foundation

public protocol XtoolEmbeddedToolBridge: Sendable {
    var identifier: String { get }

    func runSwiftFrontend(
        arguments: [String],
        environment: [String: String],
        workingDirectory: URL?
    ) async throws -> XtoolInvocationResult

    func runClang(
        arguments: [String],
        environment: [String: String],
        workingDirectory: URL?
    ) async throws -> XtoolInvocationResult

    func runLLD(
        flavor: XtoolLLDFlavor,
        arguments: [String],
        environment: [String: String],
        workingDirectory: URL?
    ) async throws -> XtoolInvocationResult
}

public enum XtoolLLDFlavor: String, Sendable, Codable {
    case macho
}

public struct UnavailableEmbeddedToolBridge: XtoolEmbeddedToolBridge {
    public let identifier = "embedded.unavailable"

    public init() {}

    public func runSwiftFrontend(
        arguments: [String],
        environment: [String: String],
        workingDirectory: URL?
    ) async throws -> XtoolInvocationResult {
        throw XtoolMobileError.toolExecutionUnavailable("swift-frontend")
    }

    public func runClang(
        arguments: [String],
        environment: [String: String],
        workingDirectory: URL?
    ) async throws -> XtoolInvocationResult {
        throw XtoolMobileError.toolExecutionUnavailable("clang")
    }

    public func runLLD(
        flavor: XtoolLLDFlavor,
        arguments: [String],
        environment: [String: String],
        workingDirectory: URL?
    ) async throws -> XtoolInvocationResult {
        throw XtoolMobileError.toolExecutionUnavailable("ld64.lld")
    }
}
