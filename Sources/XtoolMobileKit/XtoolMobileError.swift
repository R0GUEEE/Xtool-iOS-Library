import Foundation

public enum XtoolMobileError: LocalizedError, Sendable {
    case onDeviceCompilerBackendNotInstalled
    case unsupportedRuntime
    case missingWorkspace(URL)
    case invalidConfiguration(String)

    public var errorDescription: String? {
        switch self {
        case .onDeviceCompilerBackendNotInstalled:
            return "The native on-device compiler backend has not been installed."
        case .unsupportedRuntime:
            return "This operation is not supported by the current runtime."
        case .missingWorkspace(let url):
            return "No Xtool workspace exists at or above \(url.path)."
        case .invalidConfiguration(let message):
            return message
        }
    }
}
