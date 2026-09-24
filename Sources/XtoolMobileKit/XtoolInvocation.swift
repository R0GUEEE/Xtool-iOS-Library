import Foundation

public struct XtoolInvocation: Sendable, Equatable {
    public let executableURL: URL
    public let arguments: [String]
    public let environment: [String: String]
    public let workingDirectory: URL?

    public init(
        executableURL: URL,
        arguments: [String],
        environment: [String: String] = [:],
        workingDirectory: URL? = nil
    ) {
        self.executableURL = executableURL
        self.arguments = arguments
        self.environment = environment
        self.workingDirectory = workingDirectory
    }
}

public struct XtoolInvocationResult: Sendable, Equatable {
    public let exitCode: Int32
    public let standardOutput: String
    public let standardError: String

    public init(
        exitCode: Int32,
        standardOutput: String = "",
        standardError: String = ""
    ) {
        self.exitCode = exitCode
        self.standardOutput = standardOutput
        self.standardError = standardError
    }
}
