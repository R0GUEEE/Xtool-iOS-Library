import Foundation

public protocol XtoolProvisioningSigner: Sendable {
    var identifier: String { get }

    func provisionAndSign(
        appBundleURL: URL,
        status: @escaping @Sendable (String) -> Void,
        progress: @escaping @Sendable (Double?) -> Void
    ) async throws -> String
}
