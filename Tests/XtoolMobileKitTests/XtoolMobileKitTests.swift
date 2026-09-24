import Testing
@testable import XtoolMobileKit

@Test
func linksXKit() {
    #expect(XtoolMobileKit.isXKitLinked)
}

@Test
func exposesVersion() {
    #expect(!XtoolMobileKit.version.isEmpty)
}
