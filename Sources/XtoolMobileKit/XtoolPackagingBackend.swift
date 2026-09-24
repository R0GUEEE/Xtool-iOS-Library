import Foundation

public protocol XtoolArchiveExecutor: Sendable {
    var identifier: String { get }

    func createZip(
        contentsOf directory: URL,
        outputURL: URL
    ) async throws
}

public struct UnavailableArchiveExecutor: XtoolArchiveExecutor {
    public let identifier = "archive.unavailable"

    public init() {}

    public func createZip(
        contentsOf directory: URL,
        outputURL: URL
    ) async throws {
        throw XtoolMobileError.archiveExportUnavailable
    }
}
