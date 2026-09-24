import Foundation

public struct XtoolResourceCompileOptions: Sendable, Equatable {
    public let minimumIOSVersion: String
    public let appIconName: String?
    public let additionalArguments: [String]

    public init(
        minimumIOSVersion: String = "17.0",
        appIconName: String? = nil,
        additionalArguments: [String] = []
    ) {
        self.minimumIOSVersion = minimumIOSVersion
        self.appIconName = appIconName
        self.additionalArguments = additionalArguments
    }
}

public struct XtoolResourceCompilerAdapter: Sendable {
    public let toolchain: XtoolToolchainLayout
    public let executor: any XtoolToolExecutor

    public init(
        toolchain: XtoolToolchainLayout,
        executor: any XtoolToolExecutor
    ) {
        self.toolchain = toolchain
        self.executor = executor
    }

    public func process(
        resources: [URL],
        outputDirectory: URL,
        options: XtoolResourceCompileOptions = .init(),
        fileManager: FileManager = .default
    ) async throws {
        try fileManager.createDirectory(
            at: outputDirectory,
            withIntermediateDirectories: true
        )

        let assetCatalogs = resources.filter {
            $0.pathExtension.lowercased() == "xcassets"
        }

        let plainResources = resources.filter {
            $0.pathExtension.lowercased() != "xcassets"
        }

        for resource in plainResources {
            let destination = outputDirectory
                .appendingPathComponent(resource.lastPathComponent)

            if fileManager.fileExists(atPath: destination.path) {
                try fileManager.removeItem(at: destination)
            }

            try fileManager.copyItem(
                at: resource,
                to: destination
            )
        }

        guard !assetCatalogs.isEmpty else {
            return
        }

        guard let component = toolchain.sdk.component(kind: .resourceTool) else {
            throw XtoolMobileError.missingSDKComponent(
                XtoolSDKManifest.Component.Kind.resourceTool.rawValue
            )
        }

        var arguments = [
            "--compile", outputDirectory.path,
            "--platform", "iphoneos",
            "--minimum-deployment-target", options.minimumIOSVersion
        ]

        if let appIconName = options.appIconName {
            arguments += ["--app-icon", appIconName]
        }

        arguments += options.additionalArguments
        arguments += assetCatalogs.map(\.path)

        let invocation = XtoolInvocation(
            executableURL: toolchain.sdk.url(for: component),
            arguments: arguments,
            workingDirectory: outputDirectory
        )

        let result = try await executor.execute(invocation)

        guard result.exitCode == 0 else {
            throw XtoolMobileError.toolFailed(
                tool: invocation.executableURL.lastPathComponent,
                exitCode: result.exitCode,
                output: result.standardError
            )
        }
    }
}
