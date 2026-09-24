import Foundation

public struct XtoolSDKStore: Sendable {
    public let rootURL: URL

    public init(rootURL: URL) {
        self.rootURL = rootURL.standardizedFileURL
    }

    public static func applicationSupport(
        fileManager: FileManager = .default
    ) throws -> Self {
        let base = try fileManager.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )

        return .init(
            rootURL: base.appendingPathComponent(
                "XtoolMobileKit/SDKs",
                isDirectory: true
            )
        )
    }

    public func sdkURL(identifier: String) -> URL {
        rootURL.appendingPathComponent(identifier, isDirectory: true)
    }

    public func installedSDKs(
        fileManager: FileManager = .default
    ) throws -> [XtoolSDK] {
        guard fileManager.fileExists(atPath: rootURL.path) else {
            return []
        }

        let children = try fileManager.contentsOfDirectory(
            at: rootURL,
            includingPropertiesForKeys: [.isDirectoryKey],
            options: [.skipsHiddenFiles]
        )

        return try children.compactMap { url in
            let manifestURL = url.appendingPathComponent("manifest.json")
            guard fileManager.fileExists(atPath: manifestURL.path) else {
                return nil
            }

            let data = try Data(contentsOf: manifestURL)
            let manifest = try JSONDecoder().decode(
                XtoolSDKManifest.self,
                from: data
            )
            try manifest.validate()

            return XtoolSDK(rootURL: url, manifest: manifest)
        }
    }
}
