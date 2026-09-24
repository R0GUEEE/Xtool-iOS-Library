import Foundation

public struct XtoolSDKManifest: Codable, Sendable, Equatable {
    public struct Component: Codable, Sendable, Equatable, Identifiable {
        public enum Kind: String, Codable, Sendable {
            case swiftCompiler
            case clang
            case linker
            case dsymutil
            case sdk
            case resourceTool
            case signingTool
            case other
        }

        public let id: String
        public let kind: Kind
        public let relativePath: String
        public let sha256: String
        public let executable: Bool

        public init(
            id: String,
            kind: Kind,
            relativePath: String,
            sha256: String,
            executable: Bool = false
        ) {
            self.id = id
            self.kind = kind
            self.relativePath = relativePath
            self.sha256 = sha256.lowercased()
            self.executable = executable
        }
    }

    public let formatVersion: Int
    public let identifier: String
    public let displayName: String
    public let swiftVersion: String
    public let sdkVersion: String
    public let targetTriple: String
    public let minimumIOSVersion: String
    public let swiftResourcesPath: String?
    public let clangResourcesPath: String?
    public let includeSearchPaths: [String]
    public let librarySearchPaths: [String]
    public let frameworkSearchPaths: [String]
    public let components: [Component]

    public init(
        formatVersion: Int = 1,
        identifier: String,
        displayName: String,
        swiftVersion: String,
        sdkVersion: String,
        targetTriple: String = "arm64-apple-ios",
        minimumIOSVersion: String,
        swiftResourcesPath: String? = nil,
        clangResourcesPath: String? = nil,
        includeSearchPaths: [String] = [],
        librarySearchPaths: [String] = [],
        frameworkSearchPaths: [String] = [],
        components: [Component]
    ) {
        self.formatVersion = formatVersion
        self.identifier = identifier
        self.displayName = displayName
        self.swiftVersion = swiftVersion
        self.sdkVersion = sdkVersion
        self.targetTriple = targetTriple
        self.minimumIOSVersion = minimumIOSVersion
        self.swiftResourcesPath = swiftResourcesPath
        self.clangResourcesPath = clangResourcesPath
        self.includeSearchPaths = includeSearchPaths
        self.librarySearchPaths = librarySearchPaths
        self.frameworkSearchPaths = frameworkSearchPaths
        self.components = components
    }

    public func validate() throws {
        guard formatVersion == 1 else {
            throw XtoolMobileError.invalidSDK(
                "Unsupported SDK manifest version: \(formatVersion)."
            )
        }

        guard !identifier.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw XtoolMobileError.invalidSDK("SDK identifier cannot be empty.")
        }

        guard !components.isEmpty else {
            throw XtoolMobileError.invalidSDK("SDK manifest contains no components.")
        }

        let ids = components.map(\.id)
        guard Set(ids).count == ids.count else {
            throw XtoolMobileError.invalidSDK(
                "SDK manifest contains duplicate component identifiers."
            )
        }

        let declaredPaths =
            [swiftResourcesPath, clangResourcesPath].compactMap { $0 }
            + includeSearchPaths
            + librarySearchPaths
            + frameworkSearchPaths

        for path in declaredPaths {
            guard !path.isEmpty,
                  !path.hasPrefix("/"),
                  !path.contains("..") else {
                throw XtoolMobileError.invalidSDK(
                    "Invalid SDK search path: \(path)"
                )
            }
        }

        for component in components {
            guard !component.relativePath.isEmpty,
                  !component.relativePath.hasPrefix("/"),
                  !component.relativePath.contains("..") else {
                throw XtoolMobileError.invalidSDK(
                    "Invalid component path: \(component.relativePath)"
                )
            }

            guard component.sha256.count == 64,
                  component.sha256.allSatisfy({ $0.isHexDigit }) else {
                throw XtoolMobileError.invalidSDK(
                    "Invalid SHA-256 for component \(component.id)."
                )
            }
        }
    }
}
