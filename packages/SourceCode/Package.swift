// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SourceCode",
    platforms: [.macOS(.v10_13)],
    products: [
        .plugin(name: "SourceCodeCleaner", targets: ["SourceCodeCleaner"]),
        .plugin(name: "SourceCodeLinter", targets: ["SourceCodeLinter"]),
    ],
    targets: [
        .plugin(
            name: "SourceCodeLinter",
            capability: .buildTool(),
            dependencies: [
                "SwiftLintBinary",
            ]),
        .plugin(
            name: "SourceCodeCleaner",
            capability: .command(
                intent: .sourceCodeFormatting(),
                permissions: [
                    .writeToPackageDirectory(reason: "Format Swift source files"),
                ]),
            dependencies: [
                "SwiftFormat",
                "SwiftLintBinary",
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
