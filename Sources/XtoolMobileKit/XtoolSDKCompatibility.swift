import Foundation

public struct XtoolSDKCompatibility: Sendable, Equatable {
    public let compatible: Bool
    public let reasons: [String]

    public init(compatible: Bool, reasons: [String]) {
        self.compatible = compatible
        self.reasons = reasons
    }
}

public enum XtoolSDKCompatibilityChecker {
    public static func check(
        _ sdk: XtoolSDK,
        requiredSwiftMajorMinor: String? = nil,
        requiredTargetPrefix: String = "arm64-apple-ios"
    ) -> XtoolSDKCompatibility {
        var reasons: [String] = []

        if !sdk.manifest.targetTriple.hasPrefix(requiredTargetPrefix) {
            reasons.append(
                "Unsupported target triple: \(sdk.manifest.targetTriple)."
            )
        }

        if let requiredSwiftMajorMinor,
           !sdk.manifest.swiftVersion.hasPrefix(requiredSwiftMajorMinor) {
            reasons.append(
                "Swift \(requiredSwiftMajorMinor) is required, but SDK provides \(sdk.manifest.swiftVersion)."
            )
        }

        return .init(
            compatible: reasons.isEmpty,
            reasons: reasons
        )
    }
}
