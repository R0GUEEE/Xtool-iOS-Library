import Foundation

public struct XtoolIPAExporter: Sendable {
    public init() {}

    public func preparePayload(
        appBundleURL: URL,
        stagingDirectory: URL,
        fileManager: FileManager = .default
    ) throws -> URL {
        let payloadURL = stagingDirectory
            .appendingPathComponent("Payload", isDirectory: true)

        if fileManager.fileExists(atPath: stagingDirectory.path) {
            try fileManager.removeItem(at: stagingDirectory)
        }

        try fileManager.createDirectory(
            at: payloadURL,
            withIntermediateDirectories: true
        )

        let destination = payloadURL
            .appendingPathComponent(appBundleURL.lastPathComponent)

        try fileManager.copyItem(
            at: appBundleURL,
            to: destination
        )

        return payloadURL
    }
}
