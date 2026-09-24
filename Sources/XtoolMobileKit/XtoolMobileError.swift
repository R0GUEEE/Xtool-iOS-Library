import Foundation

public enum XtoolMobileError: LocalizedError, Sendable {
    case onDeviceCompilerBackendNotInstalled
    case unsupportedRuntime
    case missingWorkspace(URL)
    case invalidConfiguration(String)
    case invalidSDK(String)
    case sdkAlreadyInstalled(String)
    case missingSDKComponent(String)
    case invalidBuildPlan(String)
    case toolExecutionUnavailable(String)
    case toolFailed(tool: String, exitCode: Int32, output: String)
    case invalidBundlePlan(String)
    case invalidSigningIdentity(String)
    case signingUnavailable
    case archiveExportUnavailable

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
        case .invalidSDK(let message):
            return "Invalid embedded SDK: \(message)"
        case .sdkAlreadyInstalled(let identifier):
            return "An SDK with identifier '\(identifier)' is already installed."
        case .missingSDKComponent(let component):
            return "The embedded SDK is missing required component '\(component)'."
        case .invalidBuildPlan(let message):
            return "Invalid build plan: \(message)"
        case .toolExecutionUnavailable(let tool):
            return "No in-process executor is registered for '\(tool)'."
        case .toolFailed(let tool, let exitCode, let output):
            let detail = output.isEmpty ? "" : " \(output)"
            return "\(tool) failed with exit code \(exitCode).\(detail)"
        case .invalidBundlePlan(let message):
            return "Invalid app bundle plan: \(message)"
        case .invalidSigningIdentity(let message):
            return "Invalid signing identity: \(message)"
        case .signingUnavailable:
            return "No signing backend is available."
        case .archiveExportUnavailable:
            return "No IPA archive exporter is available."
        }
    }
}
