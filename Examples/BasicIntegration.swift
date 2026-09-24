import SwiftUI
import XtoolMobileKit

struct ContentView: View {
    var body: some View {
        List {
            LabeledContent(
                "XKit linked",
                value: XtoolMobileKit.isXKitLinked ? "Yes" : "No"
            )

            LabeledContent(
                "On-device builds",
                value: XtoolMobileKit.runtime.canBuildOnDevice ? "Available" : "Backend required"
            )
        }
        .navigationTitle("XtoolMobileKit")
    }
}
