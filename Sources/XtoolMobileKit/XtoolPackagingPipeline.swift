import Foundation

public struct XtoolPackagingPipeline: Sendable {
    public let assembler: XtoolAppBundleAssembler
    public let signer: any XtoolSigner
    public let archiveExecutor: any XtoolArchiveExecutor

    public init(
        assembler: XtoolAppBundleAssembler = .init(),
        signer: any XtoolSigner,
        archiveExecutor: any XtoolArchiveExecutor
    ) {
        self.assembler = assembler
        self.signer = signer
        self.archiveExecutor = archiveExecutor
    }

    public func package(
        plan: XtoolAppBundlePlan,
        identity: XtoolSigningIdentity,
        workingDirectory: URL,
        ipaOutputURL: URL,
        events: @escaping @Sendable (XtoolBuildEvent) -> Void = { _ in }
    ) async throws -> URL {
        events(.init(
            phase: .assemblingBundle,
            message: "Assembling app bundle."
        ))

        let appURL = try assembler.assemble(
            plan,
            outputDirectory: workingDirectory
        )

        events(.init(
            phase: .signing,
            message: "Signing app bundle."
        ))

        try await signer.sign(
            appBundleURL: appURL,
            entitlementsURL: plan.entitlementsURL,
            identity: identity
        )

        events(.init(
            phase: .exportingIPA,
            message: "Exporting IPA."
        ))

        let staging = workingDirectory
            .appendingPathComponent("IPAStaging", isDirectory: true)

        let exporter = XtoolIPAExporter()
        _ = try exporter.preparePayload(
            appBundleURL: appURL,
            stagingDirectory: staging
        )

        try await archiveExecutor.createZip(
            contentsOf: staging,
            outputURL: ipaOutputURL
        )

        events(.init(
            phase: .finished,
            message: "IPA export complete.",
            fractionCompleted: 1.0
        ))

        return ipaOutputURL
    }
}
