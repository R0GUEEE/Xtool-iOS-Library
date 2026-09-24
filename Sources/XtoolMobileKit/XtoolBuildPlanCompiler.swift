import Foundation

public struct XtoolBuildPlanCompiler: Sendable {
    public let toolchain: XtoolToolchainLayout
    public let executor: any XtoolToolExecutor

    public init(
        sdk: XtoolSDK,
        executor: any XtoolToolExecutor
    ) {
        self.toolchain = .init(sdk: sdk)
        self.executor = executor
    }

    public func build(
        _ plan: XtoolBuildPlan,
        outputDirectory: URL,
        configuration: XtoolBuildRequest.Configuration = .debug,
        events: @escaping @Sendable (XtoolBuildEvent) -> Void = { _ in }
    ) async throws -> URL {
        try plan.validate()

        try FileManager.default.createDirectory(
            at: outputDirectory,
            withIntermediateDirectories: true
        )

        var objects: [URL] = []

        if let module = plan.swiftModule {
            events(.init(
                phase: .compiling,
                message: "Compiling Swift module \(module.name)."
            ))

            let adapter = XtoolSwiftCompilerAdapter(
                toolchain: toolchain,
                executor: executor
            )

            let object = try await adapter.compile(
                sources: module.sources,
                outputDirectory: outputDirectory,
                options: .init(
                    moduleName: module.name,
                    minimumIOSVersion: plan.minimumIOSVersion,
                    optimization: configuration == .release ? .release : .debug
                )
            )

            objects.append(object)
        }

        if !plan.clangSources.isEmpty {
            let adapter = XtoolClangCompilerAdapter(
                toolchain: toolchain,
                executor: executor
            )

            for (index, source) in plan.clangSources.enumerated() {
                events(.init(
                    phase: .compiling,
                    message: "Compiling \(source.source.lastPathComponent)."
                ))

                let object = outputDirectory
                    .appendingPathComponent("clang-\(index).o")

                _ = try await adapter.compile(
                    source: source.source,
                    output: object,
                    options: .init(
                        language: source.language,
                        minimumIOSVersion: plan.minimumIOSVersion
                    )
                )

                objects.append(object)
            }
        }

        events(.init(
            phase: .linking,
            message: "Linking \(plan.outputName)."
        ))

        let linker = XtoolLinkerAdapter(
            toolchain: toolchain,
            executor: executor
        )

        return try await linker.link(
            objects: objects,
            outputDirectory: outputDirectory,
            options: .init(
                outputName: plan.outputName,
                minimumIOSVersion: plan.minimumIOSVersion,
                frameworks: plan.frameworks
            )
        )
    }
}
