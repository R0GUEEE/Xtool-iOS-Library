import Foundation

public struct XtoolAppBundleAssembler: Sendable {
    public init() {}

    public func assemble(
        _ plan: XtoolAppBundlePlan,
        outputDirectory: URL,
        fileManager: FileManager = .default
    ) throws -> URL {
        try plan.validate()

        let appURL = outputDirectory
            .appendingPathComponent("\(plan.appName).app", isDirectory: true)

        if fileManager.fileExists(atPath: appURL.path) {
            try fileManager.removeItem(at: appURL)
        }

        try fileManager.createDirectory(
            at: appURL,
            withIntermediateDirectories: true
        )

        let executableDestination = appURL
            .appendingPathComponent(plan.appName)

        try fileManager.copyItem(
            at: plan.executableURL,
            to: executableDestination
        )

        try? fileManager.setAttributes(
            [.posixPermissions: 0o755],
            ofItemAtPath: executableDestination.path
        )

        let infoData = try XtoolInfoPlistBuilder.makePlist(for: plan)
        try infoData.write(
            to: appURL.appendingPathComponent("Info.plist"),
            options: .atomic
        )

        for resource in plan.resources {
            let destination = appURL
                .appendingPathComponent(resource.lastPathComponent)

            if fileManager.fileExists(atPath: destination.path) {
                try fileManager.removeItem(at: destination)
            }

            try fileManager.copyItem(
                at: resource,
                to: destination
            )
        }

        return appURL
    }
}
