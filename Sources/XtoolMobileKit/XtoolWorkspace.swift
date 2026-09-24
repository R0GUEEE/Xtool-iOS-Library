import Foundation

public struct XtoolWorkspace: Sendable, Hashable {
    public let rootURL: URL

    public init(rootURL: URL) {
        self.rootURL = rootURL.standardizedFileURL
    }

    public var packageManifestURL: URL {
        rootURL.appendingPathComponent("Package.swift")
    }

    public var xtoolConfigurationURL: URL {
        rootURL.appendingPathComponent("xtool.yml")
    }
}
