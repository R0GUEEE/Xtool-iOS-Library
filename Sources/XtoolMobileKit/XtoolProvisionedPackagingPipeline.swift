import Foundation

public struct XtoolProvisionedPackagingPipeline: Sendable {
    public let assembler: XtoolAppBundleAssembler
    public let signer: any XtoolProvisioningSigner
    public let archiveExecutor: any XtoolArchiveExecutor

    public init(
        assembler: XtoolAppBundleAssembler = .init(),
        signer: any XtoolProvisioningSigner,
        archiveExecutor: any XtoolArchiveExecutor =
            XtoolStoredZIPArchiveExecutor()
    ) {
        self.assembler = assembler
        self.signer = signer
        self.archiveExecutor = archiveExecutor
    }

    public func package(
        plan: XtoolAppBundlePlan,
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
            message: "Provisioning and signing app bundle."
        ))

        _ = try await signer.provisionAndSign(
            appBundleURL: appURL,
            status: { message in
                events(.init(
                    phase: .signing,
                    message: message
                ))
            },
            progress: { value in
                events(.init(
                    phase: .signing,
                    message: "Signing app bundle.",
                    fractionCompleted: value
                ))
            }
        )

        events(.init(
            phase: .exportingIPA,
            message: "Exporting IPA."
        ))

        let staging = workingDirectory
            .appendingPathComponent("IPAStaging", isDirectory: true)

        _ = try XtoolIPAExporter().preparePayload(
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
