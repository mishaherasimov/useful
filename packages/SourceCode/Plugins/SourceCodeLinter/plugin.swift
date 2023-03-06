import Foundation
import PackagePlugin

// MARK: - Context

private enum Context {
    static let configFileName = ".swiftlint.yml"
    static let toolName = "swiftlint"
    static let fileExtension = "swift"
}

// MARK: - LinterPlugin

@main
struct LinterPlugin {
    private func createBuildCommands(
        inputFiles: [Path],
        packageDirectory: Path,
        workingDirectory: Path,
        tool: PluginContext.Tool) -> [Command]
    {
        guard !inputFiles.isEmpty else {
            // Don't lint anything if there are no Swift source files in this target
            return []
        }

        let configFilePath = packageDirectory.firstConfigurationFileInParentDirectories(file: Context.configFileName)
        let args: [SwiftLintOption] = [
            .quiet,
            .forceExclude,
            .cachePath(workingDirectory.string),
            .config(configFilePath?.string),
        ]

        // We are not producing output files and this is needed only to not include cache files into bundle
        let outputFilesDirectory = workingDirectory.appending("Output")

        return [
            .prebuildCommand(
                displayName: "SwiftLint",
                executable: tool.path,
                arguments: (args as [OptionConfigurable]).arguments + inputFiles.map(\.string),
                outputFilesDirectory: outputFilesDirectory),
        ]
    }
}

// MARK: BuildToolPlugin

extension LinterPlugin: BuildToolPlugin {
    func createBuildCommands(context: PluginContext, target: Target) async throws -> [Command] {
        guard let sourceTarget = target as? SourceModuleTarget else {
            return []
        }

        return createBuildCommands(
            inputFiles: sourceTarget.sourceFiles(withSuffix: Context.fileExtension).map(\.path),
            packageDirectory: context.package.directory,
            workingDirectory: context.pluginWorkDirectory,
            tool: try context.tool(named: Context.toolName))
    }
}

#if canImport(XcodeProjectPlugin)
import XcodeProjectPlugin

extension LinterPlugin: XcodeBuildToolPlugin {
    func createBuildCommands(context: XcodePluginContext, target: XcodeTarget) throws -> [Command] {
        let inputFilePaths = target.inputFiles
            .filter { $0.type == .source && $0.path.extension == Context.fileExtension }
            .map(\.path)

        return createBuildCommands(
            inputFiles: inputFilePaths,
            packageDirectory: context.xcodeProject.directory,
            workingDirectory: context.pluginWorkDirectory,
            tool: try context.tool(named: Context.toolName))
    }
}
#endif
