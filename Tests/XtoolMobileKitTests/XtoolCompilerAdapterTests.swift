import Foundation
import Testing
@testable import XtoolMobileKit

private func testSDK() -> XtoolSDK {
    let hash = String(repeating: "a", count: 64)
    let manifest = XtoolSDKManifest(
        identifier: "test",
        displayName: "Test",
        swiftVersion: "6.2",
        sdkVersion: "27.0",
        minimumIOSVersion: "17.0",
        components: [
            .init(
                id: "swiftc",
                kind: .swiftCompiler,
                relativePath: "usr/bin/swift-frontend",
                sha256: hash,
                executable: true
            ),
            .init(
                id: "clang",
                kind: .clang,
                relativePath: "usr/bin/clang",
                sha256: hash,
                executable: true
            ),
            .init(
                id: "ld",
                kind: .linker,
                relativePath: "usr/bin/ld64.lld",
                sha256: hash,
                executable: true
            ),
            .init(
                id: "sdk",
                kind: .sdk,
                relativePath: "SDKs/iPhoneOS.sdk",
                sha256: hash
            )
        ]
    )

    return .init(
        rootURL: URL(fileURLWithPath: "/toolchain"),
        manifest: manifest
    )
}

@Test
func swiftCompilerCreatesIOSFrontendInvocation() throws {
    let adapter = XtoolSwiftCompilerAdapter(
        toolchain: .init(sdk: testSDK()),
        executor: UnavailableIOSToolExecutor()
    )

    let invocation = try adapter.makeInvocation(
        sources: [URL(fileURLWithPath: "/project/main.swift")],
        outputDirectory: URL(fileURLWithPath: "/build"),
        options: .init(
            moduleName: "Hello",
            minimumIOSVersion: "17.0"
        )
    )

    #expect(invocation.arguments.first == "-frontend")
    #expect(invocation.arguments.contains("-c"))
    #expect(invocation.arguments.contains("arm64-apple-ios17.0"))
    #expect(invocation.arguments.contains("/toolchain/SDKs/iPhoneOS.sdk"))
}

@Test
func linkerUsesIOSPlatformVersion() throws {
    let adapter = XtoolLinkerAdapter(
        toolchain: .init(sdk: testSDK()),
        executor: UnavailableIOSToolExecutor()
    )

    let invocation = try adapter.makeInvocation(
        objects: [URL(fileURLWithPath: "/build/Hello.o")],
        outputDirectory: URL(fileURLWithPath: "/build"),
        options: .init(outputName: "Hello")
    )

    #expect(invocation.arguments.contains("-platform_version"))
    #expect(invocation.arguments.contains("ios"))
    #expect(invocation.arguments.contains("-syslibroot"))
}
