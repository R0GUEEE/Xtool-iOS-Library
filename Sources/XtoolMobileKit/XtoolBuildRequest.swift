import Foundation

public struct XtoolBuildRequest: Sendable {
    public enum Configuration: String, Sendable {
        case debug
        case release
    }

    public let workspace: XtoolWorkspace
    public let configuration: Configuration
    public let destination: String?

    public init(
        workspace: XtoolWorkspace,
        configuration: Configuration = .debug,
        destination: String? = nil
    ) {
        self.workspace = workspace
        self.configuration = configuration
        self.destination = destination
    }
}
