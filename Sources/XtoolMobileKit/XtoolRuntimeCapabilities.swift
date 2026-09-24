import Foundation

public struct XtoolRuntimeCapabilities: Sendable, Equatable {
    public let canUseXKit: Bool
    public let canSpawnProcesses: Bool
    public let canAccessBundledToolchains: Bool
    public let canBuildOnDevice: Bool

    public static var current: Self {
        #if os(iOS)
        return .init(
            canUseXKit: true,
            canSpawnProcesses: false,
            canAccessBundledToolchains: true,
            canBuildOnDevice: false
        )
        #else
        return .init(
            canUseXKit: true,
            canSpawnProcesses: true,
            canAccessBundledToolchains: true,
            canBuildOnDevice: true
        )
        #endif
    }
}
