import Foundation

public struct XtoolSDKValidationReport: Sendable, Equatable {
    public struct Issue: Sendable, Equatable {
        public let componentID: String
        public let message: String

        public init(componentID: String, message: String) {
            self.componentID = componentID
            self.message = message
        }
    }

    public let issues: [Issue]

    public var isValid: Bool {
        issues.isEmpty
    }

    public init(issues: [Issue]) {
        self.issues = issues
    }
}

public enum XtoolSDKValidator {
    public static func validate(
        _ sdk: XtoolSDK,
        fileManager: FileManager = .default
    ) throws -> XtoolSDKValidationReport {
        try sdk.manifest.validate()

        var issues: [XtoolSDKValidationReport.Issue] = []

        for component in sdk.manifest.components {
            let url = sdk.url(for: component)

            var isDirectory: ObjCBool = false
            guard fileManager.fileExists(
                atPath: url.path,
                isDirectory: &isDirectory
            ) else {
                issues.append(.init(
                    componentID: component.id,
                    message: "Missing component at \(component.relativePath)."
                ))
                continue
            }

            if isDirectory.boolValue {
                continue
            }

            let digest = try SHA256Digest.hex(of: url)

            if digest.caseInsensitiveCompare(component.sha256) != .orderedSame {
                issues.append(.init(
                    componentID: component.id,
                    message: "SHA-256 mismatch."
                ))
            }
        }

        return .init(issues: issues)
    }
}
