// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let isLocalDebug = true

let dependency_AlfredWorkflowUtils: Package.Dependency = isLocalDebug ?
    .package(path: "../alfred-workflow-utils") :
    .package(url: "https://github.com/hanleylee/alfred-workflow-utils.git", .upToNextMajor(from: "0.0.1"))

let package = Package(
    name: "alfred-qsirch-workflow",
    platforms: [
        .macOS(.v13),
    ],
    products: [
        .executable(name: "alfred-qsirch", targets: ["AlfredQsirchCLI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", .upToNextMajor(from: "1.5.0")),
        dependency_AlfredWorkflowUtils,
    ],
    targets: [
        .executableTarget(
            name: "AlfredQsirchCLI",
            dependencies: [
                "QsirchCore",
                .product(name: "AlfredWorkflowUpdater", package: "alfred-workflow-utils"),
                .product(name: "AlfredWorkflowScriptFilter", package: "alfred-workflow-utils"),
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
//                .target(name: "ArgumentParser"),
            ],
            path: "Sources/AlfredQsirchCLI"
        ),
        .target(
            name: "QsirchCore",
            dependencies: [
                .product(name: "AlfredWorkflowUpdater", package: "alfred-workflow-utils"),

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
