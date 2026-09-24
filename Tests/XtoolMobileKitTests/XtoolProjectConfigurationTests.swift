import Foundation
import Testing
@testable import XtoolMobileKit

@Test
func resolvesBundleIDFromOrgID() throws {
    let configuration = XtoolProjectConfiguration(
        orgID: "com.example"
    )

    #expect(
        try configuration.resolvedBundleID(productName: "Hello")
            == "com.example.Hello"
    )
}

@Test
func explicitBundleIDWins() throws {
    let configuration = XtoolProjectConfiguration(
        orgID: "com.example",
        bundleID: "dev.example.custom"
    )

    #expect(
        try configuration.resolvedBundleID(productName: "Hello")
            == "dev.example.custom"
    )
}

@Test
func rejectsConfigurationWithoutIdentifier() {
    let configuration = XtoolProjectConfiguration()

    #expect(throws: XtoolMobileError.self) {
        try configuration.validate()
    }
}

@Test
func rejectsNonPNGIcon() {
    let configuration = XtoolProjectConfiguration(
        orgID: "com.example",
        iconPath: "Icon.jpg"
    )

    #expect(throws: XtoolMobileError.self) {
        try configuration.validate()
    }
}
