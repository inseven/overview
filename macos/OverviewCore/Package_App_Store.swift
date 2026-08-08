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
        .package(url: "https://github.com/inseven/diligence.git", from: "2.0.1"),
        .package(url: "https://github.com/inseven/glitter.git", from: "0.1.2"),
        .package(url: "https://github.com/inseven/interact.git", from: "3.10.5"),
        .package(url: "https://github.com/sparkle-project/Sparkle", from: "2.7.1"),
    ],
    targets: [
        .target(
            name: "OverviewCore",
            dependencies: [
                .product(name: "Diligence", package: "diligence"),
                .product(name: "Interact", package: "interact"),
            ]
        ),

    ]
)
