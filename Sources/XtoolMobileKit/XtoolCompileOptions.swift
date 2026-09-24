import Foundation

public struct XtoolCompileOptions: Sendable, Equatable {
    public let moduleName: String
    public let targetTriple: String
    public let minimumIOSVersion: String
    public let optimization: Optimization
    public let additionalArguments: [String]

    public enum Optimization: String, Sendable {
        case debug
        case release
    }

    public init(
        moduleName: String,
        targetTriple: String = "arm64-apple-ios",
        minimumIOSVersion: String = "17.0",
        optimization: Optimization = .debug,
        additionalArguments: [String] = []
    ) {
        self.moduleName = moduleName
        self.targetTriple = targetTriple
        self.minimumIOSVersion = minimumIOSVersion
        self.optimization = optimization
        self.additionalArguments = additionalArguments
    }

    public var deploymentTargetTriple: String {
        guard targetTriple == "arm64-apple-ios" else {
            return targetTriple
        }

        return "arm64-apple-ios\(minimumIOSVersion)"
    }
}
