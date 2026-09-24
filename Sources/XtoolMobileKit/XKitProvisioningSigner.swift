import Foundation
import XKit

public struct XKitProvisioningSigner: XtoolProvisioningSigner {
    public let identifier = "xkit.auto-provisioning"

    public let context: SigningContext
    public let confirmRevocation:
        @Sendable ([DeveloperServicesCertificate]) async -> Bool

    public init(
        context: SigningContext,
        confirmRevocation:
            @escaping @Sendable ([DeveloperServicesCertificate]) async -> Bool
            = { _ in false }
    ) {
        self.context = context
        self.confirmRevocation = confirmRevocation
    }

    public func provisionAndSign(
        appBundleURL: URL,
        status: @escaping @Sendable (String) -> Void,
        progress: @escaping @Sendable (Double?) -> Void
    ) async throws -> String {
        let signer = AutoSigner(
            context: context,
            confirmRevocation: confirmRevocation
        )

        return try await signer.sign(
            app: appBundleURL,
            status: status,
            progress: progress
        )
    }
}
