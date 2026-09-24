import Testing
@testable import XtoolMobileKit

@Test
func manifestAcceptsValidComponent() throws {
    let manifest = XtoolSDKManifest(
        identifier: "swift-6.2-ios-27",
        displayName: "Swift 6.2 / iOS 27",
        swiftVersion: "6.2",
        sdkVersion: "27.0",
        minimumIOSVersion: "17.0",
        components: [
            .init(
                id: "swiftc",
                kind: .swiftCompiler,
                relativePath: "usr/bin/swiftc",
                sha256: String(repeating: "a", count: 64),
                executable: true
            )
        ]
    )

    try manifest.validate()
}

@Test
func manifestRejectsTraversal() {
    let manifest = XtoolSDKManifest(
        identifier: "bad",
        displayName: "Bad",
        swiftVersion: "6.2",
        sdkVersion: "27.0",
        minimumIOSVersion: "17.0",
        components: [
            .init(
                id: "swiftc",
                kind: .swiftCompiler,
                relativePath: "../swiftc",
                sha256: String(repeating: "a", count: 64)
            )
        ]
    )

    #expect(throws: XtoolMobileError.self) {
        try manifest.validate()
    }
}
