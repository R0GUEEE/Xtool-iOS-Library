import Foundation

public struct XtoolToolchainLayout: Sendable, Equatable {
    public let sdk: XtoolSDK

    public init(sdk: XtoolSDK) {
        self.sdk = sdk
    }

    public func componentURL(
        _ kind: XtoolSDKManifest.Component.Kind
    ) throws -> URL {
        guard let component = sdk.component(kind: kind) else {
            throw XtoolMobileError.missingSDKComponent(kind.rawValue)
        }

        return sdk.url(for: component)
    }

    public var swiftCompilerURL: URL {
        get throws { try componentURL(.swiftCompiler) }
    }

    public var clangURL: URL {
        get throws { try componentURL(.clang) }
    }

    public var linkerURL: URL {
        get throws { try componentURL(.linker) }
    }

    public var sdkRootURL: URL {
        get throws { try componentURL(.sdk) }
    }
}
