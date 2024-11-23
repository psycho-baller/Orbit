// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "orbit-backend-functions",
    platforms: [
        .macOS(.v11)  // Set this to .v11 or later
    ],
    dependencies: [
        .package(
            url: "https://github.com/appwrite/sdk-for-swift.git", from: "6.1.0")
    ],
    targets: [
        .executableTarget(
            name: "sendPushNotification",
            dependencies: [
                .product(name: "Appwrite", package: "sdk-for-swift")
            ],
            path: "Sources",
            sources: ["sendPushNotification.swift"]
        )
    ]
)
