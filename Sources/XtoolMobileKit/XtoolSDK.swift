import Foundation

public struct XtoolSDK: Sendable, Equatable {
    public let rootURL: URL
    public let manifest: XtoolSDKManifest

    public init(rootURL: URL, manifest: XtoolSDKManifest) {
        self.rootURL = rootURL.standardizedFileURL
        self.manifest = manifest
    }

    public func url(for component: XtoolSDKManifest.Component) -> URL {
        rootURL.appendingPathComponent(component.relativePath)
    }

    public func component(
        kind: XtoolSDKManifest.Component.Kind
    ) -> XtoolSDKManifest.Component? {
        manifest.components.first(where: { $0.kind == kind })
    }
}
