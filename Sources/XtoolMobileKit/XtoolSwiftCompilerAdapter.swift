import Foundation

public struct XtoolSwiftCompilerAdapter: Sendable {
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
        sources: [URL],
        outputDirectory: URL,
        options: XtoolCompileOptions
    ) throws -> XtoolInvocation {
        guard !sources.isEmpty else {
            throw XtoolMobileError.invalidBuildPlan(
                "Swift compilation requires at least one source file."
            )
        }

        let swiftc = try toolchain.swiftCompilerURL
        let sdkRoot = try toolchain.sdkRootURL

        var arguments = [
            "-target", options.deploymentTargetTriple,
            "-sdk", sdkRoot.path,
            "-module-name", options.moduleName,
            "-emit-object",
            "-parse-as-library"
        ]

        switch options.optimization {
        case .debug:
            arguments += ["-Onone", "-g"]
        case .release:
            arguments += ["-O"]
        }

        arguments += options.additionalArguments
        arguments += sources.map(\.path)

        arguments += [
            "-o",
            outputDirectory
                .appendingPathComponent("\(options.moduleName).o")
                .path
        ]

        return .init(
            executableURL: swiftc,
            arguments: arguments,
            workingDirectory: outputDirectory
        )
    }

    public func compile(
        sources: [URL],
        outputDirectory: URL,
        options: XtoolCompileOptions
    ) async throws -> URL {
        let invocation = try makeInvocation(
            sources: sources,
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

        return outputDirectory
            .appendingPathComponent("\(options.moduleName).o")
    }
}
