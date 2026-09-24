import Foundation

public struct XtoolNativeCompiler: Sendable {
    public let swiftCompiler: XtoolSwiftCompilerAdapter
    public let linker: XtoolLinkerAdapter

    public init(
        sdk: XtoolSDK,
        executor: any XtoolToolExecutor
    ) {
        let layout = XtoolToolchainLayout(sdk: sdk)
        self.swiftCompiler = .init(
            toolchain: layout,
            executor: executor
        )
        self.linker = .init(
            toolchain: layout,
            executor: executor
        )
    }

    public func buildExecutable(
        sources: [URL],
        moduleName: String,
        outputDirectory: URL,
        minimumIOSVersion: String = "17.0",
        configuration: XtoolBuildRequest.Configuration = .debug,
        frameworks: [String] = ["Foundation", "UIKit"],
        events: @escaping @Sendable (XtoolBuildEvent) -> Void = { _ in }
    ) async throws -> URL {
        try FileManager.default.createDirectory(
            at: outputDirectory,
            withIntermediateDirectories: true
        )

        events(.init(
            phase: .compiling,
            message: "Compiling Swift sources."
        ))

        let object = try await swiftCompiler.compile(
            sources: sources,
            outputDirectory: outputDirectory,
            options: .init(
                moduleName: moduleName,
                minimumIOSVersion: minimumIOSVersion,
                optimization: configuration == .release ? .release : .debug
            )
        )

        events(.init(
            phase: .linking,
            message: "Linking Mach-O executable."
        ))

        let executable = try await linker.link(
            objects: [object],
            outputDirectory: outputDirectory,
            options: .init(
                outputName: moduleName,
                minimumIOSVersion: minimumIOSVersion,
                frameworks: frameworks
            )
        )

        return executable
    }
}
