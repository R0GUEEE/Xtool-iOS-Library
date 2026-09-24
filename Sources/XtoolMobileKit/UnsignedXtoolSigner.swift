import Foundation

/// No-op signer for workflows that intentionally export an unsigned IPA.
///
/// This is useful for on-device compilation when signing is handled as a
/// separate step by the host application.
public struct UnsignedXtoolSigner: XtoolSigner {
    public let identifier = "signer.unsigned"

    public init() {}

    public func sign(
        appBundleURL: URL,
        entitlementsURL: URL?,
        identity: XtoolSigningIdentity
    ) async throws {
        // Intentionally unsigned.
    }
}
