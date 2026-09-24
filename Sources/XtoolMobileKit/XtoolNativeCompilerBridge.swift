import CXtoolCompilerBridge
import Foundation

public struct XtoolNativeCompilerBridge: XtoolEmbeddedToolBridge {
    public let identifier = "native.c-abi"

    public init() {}

    public static func registerSwiftFrontend(
        _ entrypoint: xtool_compiler_entrypoint_t?
    ) {
        xtool_register_swift_frontend(entrypoint)
    }

    public static func registerClang(
        _ entrypoint: xtool_compiler_entrypoint_t?
    ) {
        xtool_register_clang(entrypoint)
    }

    public static func registerLLDMachO(
        _ entrypoint: xtool_compiler_entrypoint_t?
    ) {
        xtool_register_lld_macho(entrypoint)
    }

    public static var currentCapabilities: XtoolNativeCompilerCapabilities {
        XtoolNativeCompilerBridge().capabilities
    }

    public var capabilities: XtoolNativeCompilerCapabilities {
        .init(
            hasSwiftFrontend: xtool_has_swift_frontend() != 0,
            hasClang: xtool_has_clang() != 0,
            hasLLDMachO: xtool_has_lld_macho() != 0
        )
    }

    public func runSwiftFrontend(
        arguments: [String],
        environment: [String: String],
        workingDirectory: URL?
    ) async throws -> XtoolInvocationResult {
        guard xtool_has_swift_frontend() != 0 else {
            throw XtoolMobileError.toolExecutionUnavailable(
                "swift-frontend"
            )
        }

        let code = run(
            arguments: arguments,
            workingDirectory: workingDirectory,
            body: xtool_run_swift_frontend
        )

        return .init(exitCode: code)
    }

    public func runClang(
        arguments: [String],
        environment: [String: String],
        workingDirectory: URL?
    ) async throws -> XtoolInvocationResult {
        guard xtool_has_clang() != 0 else {
            throw XtoolMobileError.toolExecutionUnavailable(
                "clang"
            )
        }

        let code = run(
            arguments: arguments,
            workingDirectory: workingDirectory,
            body: xtool_run_clang
        )

        return .init(exitCode: code)
    }

    public func runLLD(
        flavor: XtoolLLDFlavor,
        arguments: [String],
        environment: [String: String],
        workingDirectory: URL?
    ) async throws -> XtoolInvocationResult {
        guard flavor == .macho else {
            throw XtoolMobileError.toolExecutionUnavailable(
                "lld-\(flavor.rawValue)"
            )
        }

        guard xtool_has_lld_macho() != 0 else {
            throw XtoolMobileError.toolExecutionUnavailable(
                "ld64.lld"
            )
        }

        let code = run(
            arguments: arguments,
            workingDirectory: workingDirectory,
            body: xtool_run_lld_macho
        )

        return .init(exitCode: code)
    }

    private func run(
        arguments: [String],
        workingDirectory: URL?,
        body: (
            Int32,
            UnsafePointer<UnsafePointer<CChar>?>?,
            UnsafePointer<CChar>?
        ) -> Int32
    ) -> Int32 {
        let argv = arguments.map { strdup($0) }
        defer {
            for pointer in argv {
                free(pointer)
            }
        }

        var pointers = argv.map {
            UnsafePointer<CChar>($0)
        }
        pointers.append(nil)

        let cwd = workingDirectory?.path

        return cwd?.withCString { cwdPointer in
            pointers.withUnsafeBufferPointer { buffer in
                body(
                    Int32(arguments.count),
                    buffer.baseAddress,
                    cwdPointer
                )
            }
        } ?? pointers.withUnsafeBufferPointer { buffer in
            body(
                Int32(arguments.count),
                buffer.baseAddress,
                nil
            )
        }
    }
}

public struct XtoolNativeCompilerCapabilities:
    Sendable,
    Equatable
{
    public let hasSwiftFrontend: Bool
    public let hasClang: Bool
    public let hasLLDMachO: Bool

    public var canCompileAndLink: Bool {
        hasSwiftFrontend && hasClang && hasLLDMachO
    }

    public init(
        hasSwiftFrontend: Bool,
        hasClang: Bool,
        hasLLDMachO: Bool
    ) {
        self.hasSwiftFrontend = hasSwiftFrontend
        self.hasClang = hasClang
        self.hasLLDMachO = hasLLDMachO
    }
}
