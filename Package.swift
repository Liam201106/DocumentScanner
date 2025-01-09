// swift-tools-version: 5.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DocumentScanner",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "DocumentScanner",
            targets: ["DocumentScanner"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "DocumentScanner",
            dependencies: []
        ),
        .testTarget(
            name: "DocumentScannerTests",
            dependencies: ["DocumentScanner"]
        ),
    ]
)
