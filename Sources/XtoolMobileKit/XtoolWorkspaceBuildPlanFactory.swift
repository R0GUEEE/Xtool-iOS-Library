import Foundation

public enum XtoolWorkspaceBuildPlanFactory {
    public static func makeSimpleApplicationPlan(
        workspace: XtoolWorkspace,
        productName: String,
        appName: String? = nil,
        minimumIOSVersion: String = "17.0",
        fileManager: FileManager = .default
    ) throws -> XtoolApplicationBuildPlan {
        let inspection = try XtoolWorkspaceInspector.inspect(workspace)

        guard let configuration = inspection.configuration else {
            throw XtoolMobileError.invalidConfiguration(
                "xtool.yml could not be loaded."
            )
        }

        let sourceDirectory = workspace.rootURL
            .appendingPathComponent("Sources", isDirectory: true)
            .appendingPathComponent(productName, isDirectory: true)

        guard fileManager.fileExists(atPath: sourceDirectory.path) else {
            throw XtoolMobileError.invalidBuildPlan(
                "Missing Sources/\(productName) directory."
            )
        }

        guard let enumerator = fileManager.enumerator(
            at: sourceDirectory,
            includingPropertiesForKeys: [.isRegularFileKey],
            options: [.skipsHiddenFiles]
        ) else {
            throw XtoolMobileError.invalidBuildPlan(
                "Could not enumerate Swift sources."
            )
        }

        var swiftSources: [URL] = []

        for case let url as URL in enumerator {
            guard url.pathExtension.lowercased() == "swift" else {
                continue
            }

            let values = try url.resourceValues(
                forKeys: [.isRegularFileKey]
            )

            if values.isRegularFile == true {
                swiftSources.append(url)
            }
        }

        swiftSources.sort { $0.path < $1.path }

        guard !swiftSources.isEmpty else {
            throw XtoolMobileError.invalidBuildPlan(
                "No Swift source files found for product \(productName)."
            )
        }

        let resolvedBundleID = try configuration
            .resolvedBundleID(productName: productName)

        let resources = (configuration.resources ?? []).map {
            workspace.rootURL.appendingPathComponent($0)
        }

        return .init(
            compilePlan: .init(
                swiftModule: .init(
                    name: productName,
                    sources: swiftSources
                ),
                frameworks: ["Foundation", "UIKit"],
                outputName: productName,
                minimumIOSVersion: minimumIOSVersion
            ),
            bundleIdentifier: resolvedBundleID,
            appName: appName ?? productName,
            resources: resources,
            appIconName: nil,
            infoPlistURL: configuration.infoPath.map {
                workspace.rootURL.appendingPathComponent($0)
            },
            entitlementsURL: configuration.entitlementsPath.map {
                workspace.rootURL.appendingPathComponent($0)
            }
        )
    }
}
