import Foundation

public struct XtoolClangCompileOptions: Sendable, Equatable {
    public enum Language: String, Sendable {
        case c
        case objectiveC = "objective-c"
        case cxx = "c++"
        case objectiveCxx = "objective-c++"
    }

    public let language: Language
    public let targetTriple: String
    public let minimumIOSVersion: String
    public let includeSearchPaths: [URL]
    public let defines: [String]
    public let additionalArguments: [String]

    public init(
        language: Language = .c,
        targetTriple: String = "arm64-apple-ios",
        minimumIOSVersion: String = "17.0",
        includeSearchPaths: [URL] = [],
        defines: [String] = [],
        additionalArguments: [String] = []
    ) {
        self.language = language
        self.targetTriple = targetTriple
        self.minimumIOSVersion = minimumIOSVersion
        self.includeSearchPaths = includeSearchPaths
        self.defines = defines
        self.additionalArguments = additionalArguments
    }

    public var deploymentTargetTriple: String {
        guard targetTriple == "arm64-apple-ios" else {
            return targetTriple
        }
        return "arm64-apple-ios\(minimumIOSVersion)"
    }
}

public struct XtoolClangCompilerAdapter: Sendable {
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
        source: URL,
        output: URL,
        options: XtoolClangCompileOptions
    ) throws -> XtoolInvocation {
        let clang = try toolchain.clangURL
        let sdkRoot = try toolchain.sdkRootURL

        var arguments = [
            "-x", options.language.rawValue,
            "-target", options.deploymentTargetTriple,
            "-isysroot", sdkRoot.path,
            "-c", source.path,
            "-o", output.path
        ]

        for relative in toolchain.sdk.manifest.includeSearchPaths {
            arguments += [
                "-I",
                toolchain.sdk.rootURL.appendingPathComponent(relative).path
            ]
        }

        for relative in toolchain.sdk.manifest.frameworkSearchPaths {
            arguments += [
                "-F",
                toolchain.sdk.rootURL.appendingPathComponent(relative).path
            ]
        }

        for include in options.includeSearchPaths {
            arguments += ["-I", include.path]
        }

        for define in options.defines {
            arguments.append("-D\(define)")
        }

        arguments += options.additionalArguments

        return .init(
            executableURL: clang,
            arguments: arguments,
            workingDirectory: output.deletingLastPathComponent()
        )
    }

    public func compile(
        source: URL,
        output: URL,
        options: XtoolClangCompileOptions = .init()
    ) async throws -> URL {
        let invocation = try makeInvocation(
            source: source,
            output: output,
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

        return output
    }
}
