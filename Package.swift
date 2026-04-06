// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "VerloopSDKiOS",
    platforms: [
        .iOS(.v11)
    ],
    products: [
        .library(
            name: "VerloopSDKiOS",
            targets: ["VerloopSDKiOS"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "VerloopSDKiOS",
            path: "VerloopSDK",
            publicHeadersPath: ".",
            resources: [
                .process("Info.plist"),
                .process("PrivacyInfo.xcprivacy")
            ],
            swiftSettings: [
                .define("SWIFT_PACKAGE")
            ]
        )
    ],
    swiftLanguageVersions: [.v5]
)