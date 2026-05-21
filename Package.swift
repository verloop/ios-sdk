// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "VerloopSDKiOS",
    platforms: [
        .iOS(.v12)
    ],
    products: [
        .library(
            name: "VerloopSDKiOS",
            targets: ["VerloopSDKiOS"]
        )
    ],
    targets: [
        .target(
            name: "VerloopSDKiOS",
            dependencies: [],
            path: "Sources/VerloopSDK",
            publicHeadersPath: "."
        )
    ]
)