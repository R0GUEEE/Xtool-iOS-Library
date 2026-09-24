import SwiftUI
import XtoolMobileKit

struct ContentView: View {
    private let status = XtoolNativeCompilerHost.status

    var body: some View {
        NavigationStack {
            List {
                statusRow(
                    title: "Swift frontend",
                    available: status.swiftFrontendAvailable
                )

                statusRow(
                    title: "Clang",
                    available: status.clangAvailable
                )

                statusRow(
                    title: "Mach-O LLD",
                    available: status.lldMachOAvailable
                )
            }
            .navigationTitle("Xtool Compiler")
            .safeAreaInset(edge: .bottom) {
                Text(
                    status.isReady
                        ? "Native compiler bridge ready"
                        : "Native compiler bridge incomplete"
                )
                .font(.footnote)
                .padding()
            }
        }
    }

    private func statusRow(
        title: String,
        available: Bool
    ) -> some View {
        HStack {
            Text(title)
            Spacer()
            Image(
                systemName: available
                    ? "checkmark.circle.fill"
                    : "xmark.circle.fill"
            )
        }
    }
}
