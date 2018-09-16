// swift-tools-version:4.2

import PackageDescription

let package = Package(
    name: "SpacyClient",
    products: [
        .library(
            name: "SpacyClient",
            targets: ["SpacyClient"]),
    ],
    dependencies: [
        .package(url: "https://github.com/antitypical/Result.git", .exact("4.0.0")),
    ],
    targets: [
        .target(
            name: "SpacyClient",
            dependencies: ["Result"]),
        .testTarget(
            name: "SpacyClientTests",
            dependencies: ["SpacyClient"]),
    ]
)
