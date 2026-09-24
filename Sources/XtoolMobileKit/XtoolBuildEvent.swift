import Foundation

public enum XtoolBuildPhase: String, Sendable, Codable {
    case preparing
    case resolvingDependencies
    case compiling
    case linking
    case processingResources
    case assemblingBundle
    case signing
    case exportingIPA
    case finished
}

public struct XtoolBuildEvent: Sendable, Equatable {
    public let phase: XtoolBuildPhase
    public let message: String
    public let fractionCompleted: Double?

    public init(
        phase: XtoolBuildPhase,
        message: String,
        fractionCompleted: Double? = nil
    ) {
        self.phase = phase
        self.message = message
        self.fractionCompleted = fractionCompleted
    }
}
