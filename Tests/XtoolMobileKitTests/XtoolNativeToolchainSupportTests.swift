import Testing
@testable import XtoolMobileKit

@Test
func nativeToolchainSupportInitializes() {
    let capabilities = XtoolNativeToolchainSupport.initialize()

    #expect(
        capabilities.hasLLDMachO
            == XtoolNativeToolchainSupport.hasEmbeddedLLDMachO
    )
}
