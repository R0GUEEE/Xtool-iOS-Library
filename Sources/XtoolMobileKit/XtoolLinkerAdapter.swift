import Foundation

public struct XtoolLinkOptions: Sendable, Equatable {
    public let outputName: String
    public let targetTriple: String
    public let minimumIOSVersion: String
    public let frameworks: [String]
    public let librarySearchPaths: [URL]
    public let additionalArguments: [String]

    public init(
        outputName: String,
        targetTriple: String = "arm64-apple-ios",
        minimumIOSVersion: String = "17.0",
        frameworks: [String] = [
            "Foundation",
            "UIKit"
        ],
        librarySearchPaths: [URL] = [],
        additionalArguments: [String] = []
    ) {
        self.outputName = outputName
        self.targetTriple = targetTriple
        self.minimumIOSVersion = minimumIOSVersion
        self.frameworks = frameworks
        self.librarySearchPaths = librarySearchPaths
        self.additionalArguments = additionalArguments
    }
}

public struct XtoolLinkerAdapter: Sendable {
    public let toolchain: XtoolToolchainLayout
    public let executor: any XtoolToolExecutor

    public init(
        toolchain: XtoolToolchainLayout,
        executor: any XtoolToolExecutor
    ) {
        self.toolchain = toolchain
        self.executor = executor
    }

    public func makeInvocation(
        objects: [URL],
        outputDirectory: URL,
        options: XtoolLinkOptions
    ) throws -> XtoolInvocation {
        guard !objects.isEmpty else {
            throw XtoolMobileError.invalidBuildPlan(
                "Linking requires at least one object file."
            )
        }

        let linker = try toolchain.linkerURL
        let sdkRoot = try toolchain.sdkRootURL

        var arguments = [
            "-arch", "arm64",
            "-platform_version", "ios",
            options.minimumIOSVersion,
            options.minimumIOSVersion,
            "-syslibroot", sdkRoot.path,
            "-o", outputDirectory.appendingPathComponent(options.outputName).path
        ]

        for path in options.librarySearchPaths {
            arguments += ["-L", path.path]
        }

        for framework in options.frameworks {
            arguments += ["-framework", framework]
        }

        arguments += objects.map(\.path)
        arguments += options.additionalArguments

        return .init(
            executableURL: linker,
            arguments: arguments,
            workingDirectory: outputDirectory
        )
    }

    public func link(
        objects: [URL],
        outputDirectory: URL,
        options: XtoolLinkOptions
    ) async throws -> URL {
        let invocation = try makeInvocation(
            objects: objects,
            outputDirectory: outputDirectory,
            options: options
        )

        let result = try await executor.execute(invocation)

        guard result.exitCode == 0 else {
            throw XtoolMobileError.toolFailed(
                tool: invocation.executableURL.lastPathComponent,
                exitCode: result.exitCode,
                output: result.standardError
            )
        }

        return outputDirectory.appendingPathComponent(options.outputName)
    }
}
