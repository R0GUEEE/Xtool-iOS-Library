import Foundation

public struct XtoolApplicationBuildPlan: Sendable, Equatable {
    public let compilePlan: XtoolBuildPlan
    public let bundleIdentifier: String
    public let appName: String
    public let version: String
    public let buildNumber: String
    public let resources: [URL]
    public let appIconName: String?
    public let infoPlistURL: URL?
    public let entitlementsURL: URL?

    public init(
        compilePlan: XtoolBuildPlan,
        bundleIdentifier: String,
        appName: String,
        version: String = "1.0",
        buildNumber: String = "1",
        resources: [URL] = [],
        appIconName: String? = nil,
        infoPlistURL: URL? = nil,
        entitlementsURL: URL? = nil
    ) {
        self.compilePlan = compilePlan
        self.bundleIdentifier = bundleIdentifier
        self.appName = appName
        self.version = version
        self.buildNumber = buildNumber
        self.resources = resources
        self.appIconName = appIconName
        self.infoPlistURL = infoPlistURL
        self.entitlementsURL = entitlementsURL
    }

    public func validate() throws {
        try compilePlan.validate()

        guard !appName.isEmpty else {
            throw XtoolMobileError.invalidBundlePlan(
                "App name cannot be empty."
            )
        }

        guard bundleIdentifier.contains(".") else {
            throw XtoolMobileError.invalidBundlePlan(
                "Bundle identifier must contain at least one period."
            )
        }
    }
}
