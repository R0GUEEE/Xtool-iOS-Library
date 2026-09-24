import Foundation

public protocol XtoolBuilder: Sendable {
    func build(_ request: XtoolBuildRequest) async throws -> XtoolBuildResult
}

public struct NativeIOSXtoolBuilder: XtoolBuilder {
    public let backend: any XtoolBuildBackend

    public init(
        backend: any XtoolBuildBackend = UnavailableIOSBuildBackend()
    ) {
        self.backend = backend
    }

    public func build(
        _ request: XtoolBuildRequest
    ) async throws -> XtoolBuildResult {
        try await build(request, events: { _ in })
    }

    public func build(
        _ request: XtoolBuildRequest,
        events: @escaping @Sendable (XtoolBuildEvent) -> Void
    ) async throws -> XtoolBuildResult {
        let inspection = try XtoolWorkspaceInspector.inspect(request.workspace)

        guard inspection.isReady else {
            throw XtoolMobileError.invalidConfiguration(
                "Workspace requires both Package.swift and a valid xtool.yml."
            )
        }

        return try await backend.build(request, events: events)
    }
}
