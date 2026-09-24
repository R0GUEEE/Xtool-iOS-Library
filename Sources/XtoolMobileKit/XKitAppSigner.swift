import Foundation
import XKit

public struct XKitAppSigner: XtoolSigner {
    public let identifier = "xkit.signer"

    public init() {}

    public func sign(
        appBundleURL: URL,
        entitlementsURL: URL?,
        identity: XtoolSigningIdentity
    ) async throws {
        guard let privateKeyData = identity.privateKeyData else {
            throw XtoolMobileError.invalidSigningIdentity(
                "A private key is required for XKit signing."
            )
        }

        let certificate = try Certificate(
            data: identity.certificateData
        )
        let privateKey = PrivateKey(
            data: privateKeyData
        )

        if let provisioningProfileData = identity.provisioningProfileData {
            try provisioningProfileData.write(
                to: appBundleURL
                    .appendingPathComponent("embedded.mobileprovision"),
                options: .atomic
            )
        }

        let entitlements: Entitlements
        if let entitlementsURL {
            let data = try Data(contentsOf: entitlementsURL)
            entitlements = try PropertyListDecoder().decode(
                Entitlements.self,
                from: data
            )
        } else {
            entitlements = try Entitlements(entitlements: [])
        }

        let signer = try Signer.first()

        try await signer.sign(
            app: appBundleURL,
            identity: .real(certificate, privateKey),
            entitlementMapping: [
                appBundleURL: entitlements
            ],
            progress: { _ in }
        )
    }
}
