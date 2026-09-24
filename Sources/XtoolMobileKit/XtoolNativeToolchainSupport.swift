import Foundation
import NativeToolchainSupport

public enum XtoolNativeToolchainSupport {
    public static func registerAvailableBackends() {
        xtool_native_toolchain_register_available_backends()
    }

    public static var hasEmbeddedSwiftFrontend: Bool {
        xtool_native_toolchain_has_swift_frontend() != 0
    }

    public static var hasEmbeddedClang: Bool {
        xtool_native_toolchain_has_clang() != 0
    }

    public static var hasEmbeddedLLDMachO: Bool {
        xtool_native_toolchain_has_lld_macho() != 0
    }

    @discardableResult
    public static func initialize() -> XtoolNativeCompilerCapabilities {
        registerAvailableBackends()
        return XtoolNativeCompilerBridge.currentCapabilities
    }
}
