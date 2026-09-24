import Foundation
import XtoolMobileKit

/// Example shape for the host application's native compiler bridge.
///
/// Replace each closure/body with calls into compiler libraries linked by the
/// consuming app target.
struct HostCompilerBridge: XtoolEmbeddedToolBridge {
    let identifier = "host.compiler"

    func runSwiftFrontend(
        arguments: [String],
        environment: [String: String],
        workingDirectory: URL?
    ) async throws -> XtoolInvocationResult {
        // Call the host app's embedded Swift frontend integration here.
        throw XtoolMobileError.toolExecutionUnavailable(
            "swift-frontend"
        )
    }

    func runClang(
        arguments: [String],
        environment: [String: String],
        workingDirectory: URL?
    ) async throws -> XtoolInvocationResult {
        // Call an embedded Clang driver/library integration here.
        throw XtoolMobileError.toolExecutionUnavailable(
            "clang"
        )
    }

    func runLLD(
        flavor: XtoolLLDFlavor,
        arguments: [String],
        environment: [String: String],
        workingDirectory: URL?
    ) async throws -> XtoolInvocationResult {
        // Call embedded LLD Mach-O linking here.
        throw XtoolMobileError.toolExecutionUnavailable(
            "ld64.lld"
        )
    }
}

func makeBuilder(
    sdk: XtoolSDK
) -> XtoolApplicationBuilder {
    let bridge = HostCompilerBridge()
    let executor = XtoolEmbeddedToolExecutor(bridge: bridge)

    return XtoolApplicationBuilder(
        sdk: sdk,
        toolExecutor: executor
    )
}
