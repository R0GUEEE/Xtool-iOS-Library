import Testing
@testable import XtoolMobileKit

@Test
func nativeToolchainSupportInitializes() {
    let capabilities = XtoolNativeToolchainSupport.initialize()

    #expect(
        capabilities.hasSwiftFrontend
            == XtoolNativeToolchainSupport.hasEmbeddedSwiftFrontend
    )
    #expect(
        capabilities.hasClang
            == XtoolNativeToolchainSupport.hasEmbeddedClang
    )
    #expect(
        capabilities.hasLLDMachO
            == XtoolNativeToolchainSupport.hasEmbeddedLLDMachO
    )
}
