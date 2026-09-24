import Foundation

public struct XtoolSigningIdentity: Sendable, Equatable {
    public let certificateData: Data
    public let privateKeyData: Data?
    public let provisioningProfileData: Data?

    public init(
        certificateData: Data,
        privateKeyData: Data? = nil,
        provisioningProfileData: Data? = nil
    ) {
        self.certificateData = certificateData
        self.privateKeyData = privateKeyData
        self.provisioningProfileData = provisioningProfileData
    }
}

public protocol XtoolSigner: Sendable {
    var identifier: String { get }

    func sign(
        appBundleURL: URL,
        entitlementsURL: URL?,
        identity: XtoolSigningIdentity
    ) async throws
}

public struct UnavailableXtoolSigner: XtoolSigner {
    public let identifier = "signer.unavailable"

    public init() {}

    public func sign(
        appBundleURL: URL,
        entitlementsURL: URL?,
        identity: XtoolSigningIdentity
    ) async throws {
        throw XtoolMobileError.signingUnavailable
    }
}
