import Foundation

public struct XtoolSDKInstaller: Sendable {
    public let store: XtoolSDKStore

    public init(store: XtoolSDKStore) {
        self.store = store
    }

    @discardableResult
    public func install(
        from sourceDirectory: URL,
        replacingExisting: Bool = false,
        fileManager: FileManager = .default
    ) throws -> XtoolSDK {
        let manifestURL = sourceDirectory.appendingPathComponent("manifest.json")

        guard fileManager.fileExists(atPath: manifestURL.path) else {
            throw XtoolMobileError.invalidSDK(
                "SDK directory does not contain manifest.json."
            )
        }

        let data = try Data(contentsOf: manifestURL)
        let manifest = try JSONDecoder().decode(
            XtoolSDKManifest.self,
            from: data
        )
        try manifest.validate()

        let sourceSDK = XtoolSDK(
            rootURL: sourceDirectory,
            manifest: manifest
        )

        let validation = try XtoolSDKValidator.validate(
            sourceSDK,
            fileManager: fileManager
        )

        guard validation.isValid else {
            let detail = validation.issues
                .map { "\($0.componentID): \($0.message)" }
                .joined(separator: "; ")

            throw XtoolMobileError.invalidSDK(detail)
        }

        try fileManager.createDirectory(
            at: store.rootURL,
            withIntermediateDirectories: true
        )

        let destination = store.sdkURL(identifier: manifest.identifier)

        if fileManager.fileExists(atPath: destination.path) {
            guard replacingExisting else {
                throw XtoolMobileError.sdkAlreadyInstalled(
                    manifest.identifier
                )
            }

            try fileManager.removeItem(at: destination)
        }

        let staging = store.rootURL.appendingPathComponent(
            ".install-\(UUID().uuidString)",
            isDirectory: true
        )

        do {
            try fileManager.copyItem(
                at: sourceDirectory,
                to: staging
            )

            try fileManager.moveItem(
                at: staging,
                to: destination
            )
        } catch {
            try? fileManager.removeItem(at: staging)
            throw error
        }

        return XtoolSDK(
            rootURL: destination,
            manifest: manifest
        )
    }

    public func uninstall(
        identifier: String,
        fileManager: FileManager = .default
    ) throws {
        let url = store.sdkURL(identifier: identifier)

        guard fileManager.fileExists(atPath: url.path) else {
            return
        }

        try fileManager.removeItem(at: url)
    }
}
