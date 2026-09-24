// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "XtoolMobileKit",
    platforms: [
        .iOS(.v16),
        .macOS(.v14)
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
            .upToNextMinor(from: "1.20.1")
        ),
        .package(
            url: "https://github.com/jpsim/Yams",
            from: "5.1.3"
        )
    ],
    targets: [
        .target(
            name: "CXtoolCompilerBridge",
            publicHeadersPath: "include"
        ),
        .target(
            name: "NativeToolchainSupport",
            dependencies: ["CXtoolCompilerBridge"],
            publicHeadersPath: "include"
        ),
        .target(
            name: "XtoolMobileKit",
            dependencies: [
                "CXtoolCompilerBridge",
                "NativeToolchainSupport",
                .product(name: "XKit", package: "xtool"),
                .product(name: "Yams", package: "Yams")
            ]
        ),
        .testTarget(
            name: "XtoolMobileKitTests",
            dependencies: ["XtoolMobileKit"]
        )
    ],
    cxxLanguageStandard: .cxx17
)
