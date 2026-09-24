import Foundation

public enum XtoolInfoPlistBuilder {
    public static func makePlist(
        for plan: XtoolAppBundlePlan
    ) throws -> Data {
        if let custom = plan.infoPlistURL {
            return try Data(contentsOf: custom)
        }

        let dictionary: [String: Any] = [
            "CFBundleDevelopmentRegion": "en",
            "CFBundleDisplayName": plan.appName,
            "CFBundleExecutable": plan.appName,
            "CFBundleIdentifier": plan.bundleIdentifier,
            "CFBundleInfoDictionaryVersion": "6.0",
            "CFBundleName": plan.appName,
            "CFBundlePackageType": "APPL",
            "CFBundleShortVersionString": plan.version,
            "CFBundleVersion": plan.buildNumber,
            "MinimumOSVersion": plan.minimumIOSVersion,
            "UIDeviceFamily": [1, 2],
            "UILaunchScreen": [:]
        ]

        return try PropertyListSerialization.data(
            fromPropertyList: dictionary,
            format: .xml,
            options: 0
        )
    }
}
