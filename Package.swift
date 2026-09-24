// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "XtoolMobileKit",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "XtoolMobileKit",
            targets: ["XtoolMobileKit"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/xtool-org/xtool",
            .upToNextMinor(from: "1.20.0")
        )
    ],
    targets: [
        .target(
            name: "XtoolMobileKit",
            dependencies: [
                .product(name: "XKit", package: "xtool")
            ]
        ),
        .testTarget(
            name: "XtoolMobileKitTests",
            dependencies: ["XtoolMobileKit"]
        )
    ]
)
