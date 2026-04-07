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
    targets: [
        .binaryTarget(
            name: "VerloopSDKiOS",
            path: "VerloopSDK.xcframework"
        )
    ],
    swiftLanguageVersions: [.v5]
)