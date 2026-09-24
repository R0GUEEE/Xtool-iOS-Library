import Foundation

private final class XtoolBuildLogBox: @unchecked Sendable {
    private let lock = NSLock()
    private var lines: [String] = []

    func append(_ line: String) {
        lock.lock()
        lines.append(line)
        lock.unlock()
    }

    var value: String {
        lock.lock()
        defer { lock.unlock() }
        return lines.joined(separator: "\n")
    }
}

/// Native iOS build backend that compiles, links, bundles and exports an unsigned
/// IPA entirely in-process.
///
/// Signing is deliberately left to the host application so XtoolMobileKit can be
/// used by apps that have their own certificate/provisioning UI.
public struct NativeIOSApplicationBuildBackend: XtoolBuildBackend {
    public let identifier = "ios.native.application"

    public let sdk: XtoolSDK
    public let productName: String
    public let appName: String?
    public let minimumIOSVersion: String
    public let outputDirectory: URL

    public init(
        sdk: XtoolSDK,
        productName: String,
        appName: String? = nil,
        minimumIOSVersion: String = "17.0",
        outputDirectory: URL
    ) {
        self.sdk = sdk
        self.productName = productName
        self.appName = appName
        self.minimumIOSVersion = minimumIOSVersion
        self.outputDirectory = outputDirectory.standardizedFileURL
    }

    public func build(
        _ request: XtoolBuildRequest,
        events: @escaping @Sendable (XtoolBuildEvent) -> Void
    ) async throws -> XtoolBuildResult {
        XtoolNativeToolchainSupport.registerAvailableBackends()
        _ = try XtoolNativeCompilerHost.requireReady()

        let fileManager = FileManager.default
        try fileManager.createDirectory(
            at: outputDirectory,
            withIntermediateDirectories: true
        )

        let plan = try XtoolWorkspaceBuildPlanFactory.makeSimpleApplicationPlan(
            workspace: request.workspace,
            productName: productName,
            appName: appName,
            minimumIOSVersion: minimumIOSVersion
        )

        let workingDirectory = outputDirectory
            .appendingPathComponent(
                ".xmk-(UUID().uuidString)",
                isDirectory: true
            )
        defer {
            try? fileManager.removeItem(at: workingDirectory)
        }

        let artifactURL = outputDirectory.appendingPathComponent(
            "(productName).ipa"
        )
        if fileManager.fileExists(atPath: artifactURL.path) {
            try fileManager.removeItem(at: artifactURL)
        }

        let log = XtoolBuildLogBox()
        let forward: @Sendable (XtoolBuildEvent) -> Void = { event in
            log.append(event.message)
            events(event)
        }

        events(.init(
            phase: .preparing,
            message: "Preparing native on-device build."
        ))

        let packaging = XtoolPackagingPipeline(
            signer: UnsignedXtoolSigner()
        )
        let builder = XtoolApplicationBuilder.native(
            sdk: sdk,
            packaging: packaging
        )

        let url = try await builder.buildIPA(
            plan: plan,
            identity: XtoolSigningIdentity(certificateData: Data()),
            workingDirectory: workingDirectory,
            outputURL: artifactURL,
            configuration: request.configuration,
            events: forward
        )

        return XtoolBuildResult(
            artifactURL: url,
            log: log.value
        )
    }
}
