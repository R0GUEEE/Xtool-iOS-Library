import Foundation

public struct XtoolBuildResult: Sendable {
    public let artifactURL: URL?
    public let log: String

    public init(artifactURL: URL?, log: String) {
        self.artifactURL = artifactURL
        self.log = log
    }
}
