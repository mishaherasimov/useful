// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "sourceCode",
    platforms: [.macOS(.v10_13)],
    products: [
        .plugin(name: "usefulFormat", targets: ["usefulFormat"]),
        .plugin(name: "usefulLint", targets: ["usefulLint"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.2.2"),
    ],
    targets: [
        .plugin(
            name: "usefulLint",
            capability: .buildTool(),
            dependencies: [
                "SwiftLintBinary",
                "CodeFormatterTool"
            ]
        ),
        .plugin(
            name: "usefulFormat",
            capability: .command(
                intent: .sourceCodeFormatting(),
                permissions: [
                    .writeToPackageDirectory(reason: "Format Swift source files"),
                ]),
            dependencies: [
                "CodeFormatterTool",
                "SwiftFormat",
                "SwiftLintBinary",
            ]),
        .executableTarget(
            name: "CodeFormatterTool",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ],
            resources: [
                .process("Resources/useful.swiftformat"),
                .process("Resources/swiftlint.yml"),
            ]),
        .binaryTarget(
            name: "SwiftFormat",
            url: "https://github.com/calda/SwiftFormat/releases/download/0.51-beta-6/SwiftFormat.artifactbundle.zip",
            checksum: "8583456d892c99f970787b4ed756a7e0c83a0d9645e923bb4dae10d581c59bc3"),
        .binaryTarget(
            name: "SwiftLintBinary",
            url: "https://github.com/realm/SwiftLint/releases/download/0.48.0/SwiftLintBinary-macos.artifactbundle.zip",
            checksum: "9c255e797260054296f9e4e4cd7e1339a15093d75f7c4227b9568d63edddba50"),
    ])
