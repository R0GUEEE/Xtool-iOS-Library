import Foundation

public struct XtoolWorkspaceInspection: Sendable, Equatable {
    public let workspace: XtoolWorkspace
    public let hasPackageManifest: Bool
    public let hasXtoolConfiguration: Bool
    public let configuration: XtoolProjectConfiguration?

    public var isReady: Bool {
        hasPackageManifest && hasXtoolConfiguration && configuration != nil
    }
}

public enum XtoolWorkspaceInspector {
    public static func inspect(
        _ workspace: XtoolWorkspace,
        fileManager: FileManager = .default
    ) throws -> XtoolWorkspaceInspection {
        var isDirectory: ObjCBool = false

        guard fileManager.fileExists(
            atPath: workspace.rootURL.path,
            isDirectory: &isDirectory
        ), isDirectory.boolValue else {
            throw XtoolMobileError.missingWorkspace(workspace.rootURL)
        }

        let hasPackage = fileManager.fileExists(
            atPath: workspace.packageManifestURL.path
        )
        let hasConfig = fileManager.fileExists(
            atPath: workspace.xtoolConfigurationURL.path
        )

        let configuration = hasConfig
            ? try XtoolProjectConfiguration.load(
                from: workspace.xtoolConfigurationURL
            )
            : nil

        return .init(
            workspace: workspace,
            hasPackageManifest: hasPackage,
            hasXtoolConfiguration: hasConfig,
            configuration: configuration
        )
    }

    public static func discover(
        startingAt url: URL,
        fileManager: FileManager = .default
    ) throws -> XtoolWorkspace {
        var current = url.standardizedFileURL

        var isDirectory: ObjCBool = false
        if fileManager.fileExists(atPath: current.path, isDirectory: &isDirectory),
           !isDirectory.boolValue {
            current.deleteLastPathComponent()
        }

        while true {
            let workspace = XtoolWorkspace(rootURL: current)

            if fileManager.fileExists(atPath: workspace.packageManifestURL.path),
               fileManager.fileExists(atPath: workspace.xtoolConfigurationURL.path) {
                return workspace
            }

            let parent = current.deletingLastPathComponent()
            if parent.path == current.path {
                break
            }

            current = parent
        }

        throw XtoolMobileError.missingWorkspace(url)
    }
}
