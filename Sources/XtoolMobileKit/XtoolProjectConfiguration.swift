import Foundation
import Yams

public struct XtoolProjectConfiguration: Codable, Sendable, Equatable {
    public enum Version: Int, Codable, Sendable {
        case v1 = 1
    }

    public struct AppExtension: Codable, Sendable, Equatable {
        public var product: String
        public var bundleID: String?
        public var infoPath: String
        public var resources: [String]?
        public var entitlementsPath: String?

        public init(
            product: String,
            bundleID: String? = nil,
            infoPath: String,
            resources: [String]? = nil,
            entitlementsPath: String? = nil
        ) {
            self.product = product
            self.bundleID = bundleID
            self.infoPath = infoPath
            self.resources = resources
            self.entitlementsPath = entitlementsPath
        }
    }

    public var version: Version
    public var orgID: String?
    public var bundleID: String?
    public var product: String?
    public var infoPath: String?
    public var entitlementsPath: String?
    public var iconPath: String?
    public var resources: [String]?
    public var extensions: [AppExtension]?
    public var skipLSP: Bool?

    public init(
        version: Version = .v1,
        orgID: String? = nil,
        bundleID: String? = nil,
        product: String? = nil,
        infoPath: String? = nil,
        entitlementsPath: String? = nil,
        iconPath: String? = nil,
        resources: [String]? = nil,
        extensions: [AppExtension]? = nil,
        skipLSP: Bool? = nil
    ) {
        self.version = version
        self.orgID = orgID
        self.bundleID = bundleID
        self.product = product
        self.infoPath = infoPath
        self.entitlementsPath = entitlementsPath
        self.iconPath = iconPath
        self.resources = resources
        self.extensions = extensions
        self.skipLSP = skipLSP
    }

    public static func load(from url: URL) throws -> Self {
        let data = try Data(contentsOf: url)
        let configuration = try YAMLDecoder().decode(Self.self, from: data)
        try configuration.validate()
        return configuration
    }

    public func validate() throws {
        guard orgID != nil || bundleID != nil else {
            throw XtoolMobileError.invalidConfiguration(
                "xtool.yml must specify either orgID or bundleID."
            )
        }

        if let iconPath {
            guard URL(fileURLWithPath: iconPath).pathExtension.lowercased() == "png" else {
                throw XtoolMobileError.invalidConfiguration(
                    "iconPath must point to a PNG file."
                )
            }
        }
    }

    public func resolvedBundleID(productName: String) throws -> String {
        if let bundleID {
            return bundleID
        }

        guard let orgID else {
            throw XtoolMobileError.invalidConfiguration(
                "Cannot resolve bundle identifier without orgID or bundleID."
            )
        }

        return "\(orgID).\(productName)"
    }
}
