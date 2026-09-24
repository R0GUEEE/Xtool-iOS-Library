import Foundation

public struct XtoolNativeCompilerHostStatus: Sendable, Equatable {
    public let swiftFrontendAvailable: Bool
    public let clangAvailable: Bool
    public let lldMachOAvailable: Bool

    public var isReady: Bool {
        swiftFrontendAvailable &&
        clangAvailable &&
        lldMachOAvailable
    }

    public var missingBackends: [String] {
        var result: [String] = []

        if !swiftFrontendAvailable {
            result.append("Swift frontend")
        }

        if !clangAvailable {
            result.append("Clang")
        }

        if !lldMachOAvailable {
            result.append("Mach-O LLD")
        }

        return result
    }

    public init(
        swiftFrontendAvailable: Bool,
        clangAvailable: Bool,
        lldMachOAvailable: Bool
    ) {
        self.swiftFrontendAvailable = swiftFrontendAvailable
        self.clangAvailable = clangAvailable
        self.lldMachOAvailable = lldMachOAvailable
    }
}

public enum XtoolNativeCompilerHost {
    public static var status: XtoolNativeCompilerHostStatus {
        let capabilities =
            XtoolNativeCompilerBridge.currentCapabilities

        return .init(
            swiftFrontendAvailable:
                capabilities.hasSwiftFrontend,
            clangAvailable:
                capabilities.hasClang,
            lldMachOAvailable:
                capabilities.hasLLDMachO
        )
    }

    @discardableResult
    public static func requireReady()
        throws -> XtoolNativeCompilerHostStatus
    {
        let current = status

        guard current.isReady else {
            throw XtoolMobileError.nativeCompilerHostNotReady(
                current.missingBackends
            )
        }

        return current
    }
}
