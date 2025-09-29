// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "OverviewCore",
    platforms: [
        .macOS(.v13),
    ],
    products: [
        .library(
            name: "OverviewCore",
            targets: ["OverviewCore"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/sparkle-project/Sparkle", .upToNextMajor(from: "2.7.1")),
        .package(url: "https://github.com/inseven/glitter.git", .upToNextMajor(from: "0.1.1")),
    ],
    targets: [
        .target(
            name: "OverviewCore",
            dependencies: [
                .product(name: "Sparkle", package: "Sparkle"),
                .product(name: "Glitter", package: "glitter"),
            ]
        ),

    ]
)
