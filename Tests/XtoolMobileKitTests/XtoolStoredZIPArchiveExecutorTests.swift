import Foundation
import Testing
@testable import XtoolMobileKit

@Test
func exportsZipWithPKHeader() async throws {
    let root = URL(fileURLWithPath: NSTemporaryDirectory())
        .appendingPathComponent(UUID().uuidString, isDirectory: true)

    let payload = root
        .appendingPathComponent("Payload", isDirectory: true)
        .appendingPathComponent("Hello.app", isDirectory: true)

    try FileManager.default.createDirectory(
        at: payload,
        withIntermediateDirectories: true
    )

    try Data("hello".utf8).write(
        to: payload.appendingPathComponent("Hello")
    )

    let output = root.appendingPathComponent("Hello.ipa")

    defer {
        try? FileManager.default.removeItem(at: root)
    }

    try await XtoolStoredZIPArchiveExecutor().createZip(
        contentsOf: root,
        outputURL: output
    )

    let bytes = try Data(contentsOf: output)
    #expect(bytes.prefix(4) == Data([0x50, 0x4b, 0x03, 0x04]))
}
