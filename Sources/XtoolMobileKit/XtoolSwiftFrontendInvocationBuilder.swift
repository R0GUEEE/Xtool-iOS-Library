import Foundation

public enum XtoolSwiftFrontendInvocationBuilder {
    public static func makeCompileArguments(
        sources: [URL],
        moduleName: String,
        sdkRoot: URL,
        targetTriple: String,
        outputObject: URL,
        optimization: XtoolCompileOptions.Optimization,
        additionalArguments: [String] = []
    ) throws -> [String] {
        guard !sources.isEmpty else {
            throw XtoolMobileError.invalidBuildPlan(
                "Swift frontend requires at least one source file."
            )
        }

        var arguments = [
            "-frontend",
            "-c",
            "-module-name", moduleName,
            "-target", targetTriple,
            "-sdk", sdkRoot.path,
            "-parse-as-library"
        ]

        switch optimization {
        case .debug:
            arguments += ["-Onone", "-g"]
        case .release:
            arguments += ["-O"]
        }

        arguments += additionalArguments
        arguments += sources.map(\.path)
        arguments += ["-o", outputObject.path]

        return arguments
    }
}
