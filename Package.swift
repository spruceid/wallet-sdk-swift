// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "WalletSdk",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "WalletSdk",
            targets: ["WalletSdk"]),
    ],
    dependencies: [
        .package(url: "https://github.com/spruceid/wallet-sdk-rs.git", from: "0.0.2"),
        // .package(path: "../wallet-sdk-rs")
    ],
    targets: [
        .target(
            name: "WalletSdk",
            dependencies: [
                .product(name: "WalletSdkRs", package: "wallet-sdk-rs")
            ]
        ),
        .testTarget(
            name: "WalletSdkTests",
            dependencies: ["WalletSdk"]),
    ]
)
