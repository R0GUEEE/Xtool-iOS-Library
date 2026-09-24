import Foundation

public struct XtoolApplicationBuilder: Sendable {
    public let sdk: XtoolSDK
    public let toolExecutor: any XtoolToolExecutor
    public let packaging: XtoolPackagingPipeline

    public init(
        sdk: XtoolSDK,
        toolExecutor: any XtoolToolExecutor,
        packaging: XtoolPackagingPipeline = .init()
    ) {
        self.sdk = sdk
        self.toolExecutor = toolExecutor
        self.packaging = packaging
    }

    public func buildIPA(
        plan: XtoolApplicationBuildPlan,
        identity: XtoolSigningIdentity,
        workingDirectory: URL,
        outputURL: URL,
        configuration: XtoolBuildRequest.Configuration = .debug,
        events: @escaping @Sendable (XtoolBuildEvent) -> Void = { _ in }
    ) async throws -> URL {
        try plan.validate()

        let fileManager = FileManager.default

        try fileManager.createDirectory(
            at: workingDirectory,
            withIntermediateDirectories: true
        )

        let buildDirectory = workingDirectory
            .appendingPathComponent("Build", isDirectory: true)

        let resourceDirectory = workingDirectory
            .appendingPathComponent("ProcessedResources", isDirectory: true)

        let compiler = XtoolBuildPlanCompiler(
            sdk: sdk,
            executor: toolExecutor
        )

        let executable = try await compiler.build(
            plan.compilePlan,
            outputDirectory: buildDirectory,
            configuration: configuration,
            events: events
        )

        events(.init(
            phase: .processingResources,
            message: "Processing app resources."
        ))

        let resourceCompiler = XtoolResourceCompilerAdapter(
            toolchain: .init(sdk: sdk),
            executor: toolExecutor
        )

        try await resourceCompiler.process(
            resources: plan.resources,
            outputDirectory: resourceDirectory,
            options: .init(
                minimumIOSVersion: plan.compilePlan.minimumIOSVersion,
                appIconName: plan.appIconName
            )
        )

        let processedResources: [URL]
        if fileManager.fileExists(atPath: resourceDirectory.path) {
            processedResources = try fileManager.contentsOfDirectory(
                at: resourceDirectory,
                includingPropertiesForKeys: nil,
                options: [.skipsHiddenFiles]
            )
        } else {
            processedResources = []
        }

        let bundlePlan = XtoolAppBundlePlan(
            appName: plan.appName,
            bundleIdentifier: plan.bundleIdentifier,
            executableURL: executable,
            minimumIOSVersion: plan.compilePlan.minimumIOSVersion,
            version: plan.version,
            buildNumber: plan.buildNumber,
            resources: processedResources,
            infoPlistURL: plan.infoPlistURL,
            entitlementsURL: plan.entitlementsURL
        )

        let packageDirectory = workingDirectory
            .appendingPathComponent("Package", isDirectory: true)

        return try await packaging.package(
            plan: bundlePlan,
            identity: identity,
            workingDirectory: packageDirectory,
            ipaOutputURL: outputURL,
            events: events
        )
    }
}


public extension XtoolApplicationBuilder {
    static func native(
        sdk: XtoolSDK,
        packaging: XtoolPackagingPipeline = .init()
    ) -> Self {
        let bridge = XtoolNativeCompilerBridge()
        let executor = XtoolEmbeddedToolExecutor(
            bridge: bridge
        )

        return .init(
            sdk: sdk,
            toolExecutor: executor,
            packaging: packaging
        )
    }
}
