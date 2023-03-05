import Foundation
import PackagePlugin

// MARK: - usefulLintPlugin

extension Path {

    // MARK: Internal

    /// Scans the receiver, then all of its parents looking for a configuration file with the name ".swiftlint.yml".
    ///
    /// - returns: Path to the configuration file, or nil if one cannot be found.
    func firstConfigurationFileInParentDirectories() -> Path? {
        let defaultConfigurationFileName = ".swiftlint.yml"
        let proposedDirectory = sequence(
            first: self,
            next: { path in
                guard path.stem.count > 1 else {
                    // Check we're not at the root of this filesystem, as `removingLastComponent()`
                    // will continually return the root from itself.
                    return nil
                }

                return path.removingLastComponent()
            }).first { path in
            let potentialConfigurationFile = path.appending(subpath: defaultConfigurationFileName)
            return potentialConfigurationFile.isAccessible()
        }
        return proposedDirectory?.appending(subpath: defaultConfigurationFileName)
    }

    // MARK: Private

    /// Safe way to check if the file is accessible from within the current process sandbox.
    private func isAccessible() -> Bool {
        let result = string.withCString { pointer in
            access(pointer, R_OK)
        }

        return result == 0
    }
}

// MARK: - SwiftLintPlugin

@main
struct SwiftLintPlugin: BuildToolPlugin {

    // MARK: Internal

    func createBuildCommands(context: PluginContext, target: Target) async throws -> [Command] {
        guard let sourceTarget = target as? SourceModuleTarget else {
            return []
        }
        return createBuildCommands(
            inputFiles: sourceTarget.sourceFiles(withSuffix: "swift").map(\.path),
            packageDirectory: context.package.directory,
            workingDirectory: context.pluginWorkDirectory,
            tool: try context.tool(named: "swiftlint"))
    }

    // MARK: Private

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

        

        var arguments = [
            "lint",
            "--quiet",
            // We always pass all of the Swift source files in the target to the tool,
            // so we need to ensure that any exclusion rules in the configuration are
            // respected.
            "--force-exclude",
            "--cache-path", "\(workingDirectory)",
        ]

        // Manually look for configuration files, to avoid issues when the plugin does not execute our tool from the
        // package source directory.
        if let configuration = packageDirectory.firstConfigurationFileInParentDirectories() {
            arguments.append(contentsOf: ["--config", "\(configuration.string)"])
        }
        arguments += inputFiles.map(\.string)

        // We are not producing output files and this is needed only to not include cache files into bundle
        let outputFilesDirectory = workingDirectory.appending("Output")

        return [
            .prebuildCommand(
                displayName: "SwiftLint",
                executable: tool.path,
                arguments: arguments,
                outputFilesDirectory: outputFilesDirectory),
        ]
    }
}

#if canImport(XcodeProjectPlugin)
import XcodeProjectPlugin

extension SwiftLintPlugin: XcodeBuildToolPlugin {
    func createBuildCommands(context: XcodePluginContext, target: XcodeTarget) throws -> [Command] {
        let inputFilePaths = target.inputFiles
            .filter { $0.type == .source && $0.path.extension == "swift" }
            .map(\.path)
        return createBuildCommands(
            inputFiles: inputFilePaths,
            packageDirectory: context.xcodeProject.directory,
            workingDirectory: context.pluginWorkDirectory,
            tool: try context.tool(named: "swiftlint"))
    }
}
#endif

//
// @main
// struct usefulLintPlugin {
//    private func createBuildCommands(
//        inputFiles: [Path],
//        packageDirectory _: Path,
//        workingDirectory: Path,
//        tool: PluginContext.Tool,
//        linter: PluginContext.Tool) -> [Command]
//    {
//        if inputFiles.isEmpty {
//            // Don't lint anything if there are no Swift source files in this target
//            return []
//        }
//
//        var arguments = [
//            "--lint",
//            "--swift-lint-path",
//            linter.path.string,
//            "--swift-lint-cache-path",
//            "\(workingDirectory.string)/workingDirectory.string",
//        ]
//
//        arguments += inputFiles.map(\.string)
//
//        // We are not producing output files and this is needed only to not include cache files into bundle
//        let outputFilesDirectory = workingDirectory.appending("Output")
//
//        return [
//            .prebuildCommand(
//                displayName: "SwiftLint",
//                executable: tool.path,
//                arguments: arguments,
//                outputFilesDirectory: outputFilesDirectory),
//        ]
//    }
// }
//
// // MARK: BuildToolPlugin
//
// extension usefulLintPlugin: BuildToolPlugin {
//    /// This entry point is called when operating on a Swift package.
//    func createBuildCommands(context: PluginContext, target: Target) throws -> [Command] {
//        guard let sourceTarget = target as? SourceModuleTarget else {
//            return []
//        }
//        return createBuildCommands(
//            inputFiles: sourceTarget.sourceFiles(withSuffix: "swift").map(\.path),
//            packageDirectory: context.package.directory,
//            workingDirectory: context.pluginWorkDirectory,
//            tool: try context.tool(named: "CodeFormatterTool"),
//            linter: try context.tool(named: "swiftlint"))
//    }
// }
//
// #if canImport(XcodeProjectPlugin)
// import XcodeProjectPlugin
//
// extension usefulLintPlugin: XcodeBuildToolPlugin {
//
//    /// This entry point is called when operating on an Xcode project.
//    func createBuildCommands(context: XcodePluginContext, target: XcodeTarget) throws -> [Command] {
//        let inputFilePaths = target.inputFiles
//            .filter { $0.type == .source && $0.path.extension == "swift" }
//            .map(\.path)
//        return createBuildCommands(
//            inputFiles: inputFilePaths,
//            packageDirectory: context.xcodeProject.directory,
//            workingDirectory: context.pluginWorkDirectory,
//            tool: try context.tool(named: "CodeFormatterTool"),
//            linter: try context.tool(named: "swiftlint"))
//    }
// }
// #endif
