import Foundation
import Testing
@testable import XtoolMobileKit

private struct RecordingBridge: XtoolEmbeddedToolBridge {
    let identifier = "test"

    func runSwiftFrontend(
        arguments: [String],
        environment: [String: String],
        workingDirectory: URL?
    ) async throws -> XtoolInvocationResult {
        .init(exitCode: 0, standardOutput: "swift")
    }

    func runClang(
        arguments: [String],
        environment: [String: String],
        workingDirectory: URL?
    ) async throws -> XtoolInvocationResult {
        .init(exitCode: 0, standardOutput: "clang")
    }

    func runLLD(
        flavor: XtoolLLDFlavor,
        arguments: [String],
        environment: [String: String],
        workingDirectory: URL?
    ) async throws -> XtoolInvocationResult {
        .init(exitCode: 0, standardOutput: "lld")
    }
}

@Test
func routesSwiftCompiler() async throws {
    let executor = XtoolEmbeddedToolExecutor(
        bridge: RecordingBridge()
    )

    let result = try await executor.execute(
        .init(
            executableURL: URL(fileURLWithPath: "/toolchain/swiftc"),
            arguments: []
        )
    )

    #expect(result.standardOutput == "swift")
}

@Test
func routesClang() async throws {
    let executor = XtoolEmbeddedToolExecutor(
        bridge: RecordingBridge()
    )

    let result = try await executor.execute(
        .init(
            executableURL: URL(fileURLWithPath: "/toolchain/clang"),
            arguments: []
        )
    )

    #expect(result.standardOutput == "clang")
}

@Test
func routesMachOLLD() async throws {
    let executor = XtoolEmbeddedToolExecutor(
        bridge: RecordingBridge()
    )

    let result = try await executor.execute(
        .init(
            executableURL: URL(fileURLWithPath: "/toolchain/ld64.lld"),
            arguments: []
        )
    )

    #expect(result.standardOutput == "lld")
}
