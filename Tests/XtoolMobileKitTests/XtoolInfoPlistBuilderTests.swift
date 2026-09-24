import Foundation
import Testing
@testable import XtoolMobileKit

@Test
func buildsDefaultInfoPlist() throws {
    let temp = URL(fileURLWithPath: NSTemporaryDirectory())
        .appendingPathComponent(UUID().uuidString)

    try Data().write(to: temp)

    defer {
        try? FileManager.default.removeItem(at: temp)
    }

    let plan = XtoolAppBundlePlan(
        appName: "Hello",
        bundleIdentifier: "com.example.Hello",
        executableURL: temp
    )

    let data = try XtoolInfoPlistBuilder.makePlist(for: plan)

    let plist = try PropertyListSerialization.propertyList(
        from: data,
        options: [],
        format: nil
    ) as? [String: Any]

    #expect(plist?["CFBundleIdentifier"] as? String == "com.example.Hello")
    #expect(plist?["CFBundleExecutable"] as? String == "Hello")
}
