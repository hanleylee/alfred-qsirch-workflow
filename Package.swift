// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "alfred-qsirch-workflow",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .executable(
            name: "alfred-qsirch",
            targets: ["AlfredQsirchCLI"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", .upToNextMajor(from: "1.5.0")),
        .package(url: "https://github.com/hanleylee/AlfredWorkflowScriptFilter", .upToNextMajor(from: "1.0.0")),
    ],
    targets: [
        .executableTarget(
            name: "AlfredQsirchCLI",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                "AlfredQsirchCore",
            ],
            path: "Sources/AlfredQsirchCLI"
        ),
        .target(
            name: "AlfredQsirchCore",
            dependencies: [
                "AlfredWorkflowScriptFilter",
            ],
            path: "Sources/AlfredQsirchCore"
        ),

        // MARK: - TEST -
        .testTarget(
            name: "AlfredQsirchTests",
            dependencies: [
                "AlfredQsirchCore",
            ],
            path: "Tests/AlfredQsirchTests"
        ),

    ]
)
