import Foundation

public struct XtoolBuildPlan: Sendable, Equatable {
    public struct SwiftModule: Sendable, Equatable {
        public let name: String
        public let sources: [URL]

        public init(name: String, sources: [URL]) {
            self.name = name
            self.sources = sources
        }
    }

    public struct ClangSource: Sendable, Equatable {
        public let source: URL
        public let language: XtoolClangCompileOptions.Language

        public init(
            source: URL,
            language: XtoolClangCompileOptions.Language
        ) {
            self.source = source
            self.language = language
        }
    }

    public let swiftModule: SwiftModule?
    public let clangSources: [ClangSource]
    public let frameworks: [String]
    public let outputName: String
    public let minimumIOSVersion: String

    public init(
        swiftModule: SwiftModule? = nil,
        clangSources: [ClangSource] = [],
        frameworks: [String] = ["Foundation", "UIKit"],
        outputName: String,
        minimumIOSVersion: String = "17.0"
    ) {
        self.swiftModule = swiftModule
        self.clangSources = clangSources
        self.frameworks = frameworks
        self.outputName = outputName
        self.minimumIOSVersion = minimumIOSVersion
    }

    public func validate() throws {
        guard swiftModule != nil || !clangSources.isEmpty else {
            throw XtoolMobileError.invalidBuildPlan(
                "Build plan contains no source files."
            )
        }

        if let swiftModule, swiftModule.sources.isEmpty {
            throw XtoolMobileError.invalidBuildPlan(
                "Swift module contains no source files."
            )
        }

        guard !outputName.isEmpty else {
            throw XtoolMobileError.invalidBuildPlan(
                "Output executable name cannot be empty."
            )
        }
    }
}
