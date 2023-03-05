import Foundation
import PackagePlugin

@main
struct usefulLintPlugin {
    private func createBuildCommands(
        inputFiles: [Path],
        packageDirectory: Path,
        workingDirectory: Path,
        tool: PluginContext.Tool,
        linter: PluginContext.Tool
    ) -> [Command] {
        if inputFiles.isEmpty {
            // Don't lint anything if there are no Swift source files in this target
            return []
        }

        var arguments = [
            "--lint",
            "--swift-lint-path",
            linter.path.string,
            "--swift-lint-cache-path",
            "\(workingDirectory.string)/workingDirectory.string"
        ]

        arguments += inputFiles.map(\.string)

        // We are not producing output files and this is needed only to not include cache files into bundle
        let outputFilesDirectory = workingDirectory.appending("Output")

        return [
            .prebuildCommand(
                displayName: "SwiftLint",
                executable: tool.path,
                arguments: arguments,
                outputFilesDirectory: outputFilesDirectory
            )
        ]
    }
}

extension usefulLintPlugin: BuildToolPlugin {
    /// This entry point is called when operating on a Swift package.
    func createBuildCommands(context: PluginContext, target: Target) throws -> [Command] {
        guard let sourceTarget = target as? SourceModuleTarget else {
            return []
        }
        return createBuildCommands(
            inputFiles: sourceTarget.sourceFiles(withSuffix: "swift").map(\.path),
            packageDirectory: context.package.directory,
            workingDirectory: context.pluginWorkDirectory,
            tool: try context.tool(named: "CodeFormatterTool"),
            linter: try context.tool(named: "swiftlint")
        )
    }
}

#if canImport(XcodeProjectPlugin)
import XcodeProjectPlugin

extension usefulLintPlugin: XcodeBuildToolPlugin {

    /// This entry point is called when operating on an Xcode project.
    func createBuildCommands(context: XcodePluginContext, target: XcodeTarget) throws -> [Command] {

        let inputFilePaths = target.inputFiles
            .filter { $0.type == .source && $0.path.extension == "swift" }
            .map(\.path)
        return createBuildCommands(
            inputFiles: inputFilePaths,
            packageDirectory: context.xcodeProject.directory,
            workingDirectory: context.pluginWorkDirectory,
            tool: try context.tool(named: "CodeFormatterTool"),
            linter: try context.tool(named: "swiftlint")
        )
    }
}
#endif
