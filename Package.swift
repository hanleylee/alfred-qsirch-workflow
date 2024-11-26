// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "alfred-qsirch-workflow",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "alfred-qsirch", targets: ["AlfredQsirchCLI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", .upToNextMajor(from: "1.5.0")),
        .package(url: "https://github.com/hanleylee/AlfredWorkflowScriptFilter", .upToNextMajor(from: "1.0.0")),
//        .package(path: "/Users/hanley/repo/alfred-workflow-updater"),
        .package(url: "https://github.com/hanleylee/alfred-workflow-updater", .upToNextMajor(from: "0.0.1")),
    ],
    targets: [
        .executableTarget(
            name: "AlfredQsirchCLI",
            dependencies: [
                "QsirchCore",
                "AlfredWorkflowScriptFilter",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ],
            path: "Sources/AlfredQsirchCLI"
        ),
        .target(
            name: "QsirchCore",
            dependencies: [
                .product(name: "AlfredWorkflowUpdater", package: "alfred-workflow-updater"),
            ],
            path: "Sources/QsirchCore"
        ),

        // MARK: - TEST -
        .testTarget(
            name: "AlfredQsirchTests",
            dependencies: [
                "QsirchCore",
            ],
            path: "Tests/AlfredQsirchTests"
        ),

    ]
)
