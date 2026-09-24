import Foundation

public struct XtoolAppBundlePlan: Sendable, Equatable {
    public let appName: String
    public let bundleIdentifier: String
    public let executableURL: URL
    public let minimumIOSVersion: String
    public let version: String
    public let buildNumber: String
    public let resources: [URL]
    public let infoPlistURL: URL?
    public let entitlementsURL: URL?

    public init(
        appName: String,
        bundleIdentifier: String,
        executableURL: URL,
        minimumIOSVersion: String = "17.0",
        version: String = "1.0",
        buildNumber: String = "1",
        resources: [URL] = [],
        infoPlistURL: URL? = nil,
        entitlementsURL: URL? = nil
    ) {
        self.appName = appName
        self.bundleIdentifier = bundleIdentifier
        self.executableURL = executableURL
        self.minimumIOSVersion = minimumIOSVersion
        self.version = version
        self.buildNumber = buildNumber
        self.resources = resources
        self.infoPlistURL = infoPlistURL
        self.entitlementsURL = entitlementsURL
    }

    public func validate() throws {
        guard !appName.isEmpty else {
            throw XtoolMobileError.invalidBundlePlan("App name cannot be empty.")
        }

        guard bundleIdentifier.contains(".") else {
            throw XtoolMobileError.invalidBundlePlan(
                "Bundle identifier must contain at least one period."
            )
        }

        guard FileManager.default.fileExists(atPath: executableURL.path) else {
            throw XtoolMobileError.invalidBundlePlan(
                "Executable does not exist at \(executableURL.path)."
            )
        }
    }
}
