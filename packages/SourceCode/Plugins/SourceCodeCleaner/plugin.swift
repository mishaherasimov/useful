import Foundation
import PackagePlugin
#if canImport(XcodeProjectPlugin)
import XcodeProjectPlugin
#endif

let swiftExtension = "swift"

// MARK: - PluginArguments

struct PluginArguments {

    // MARK: Lifecycle

    init(_ args: [String], packageVersion: PackagePlugin.ToolsVersion? = nil) {
        var extractor = ArgumentExtractor(args)
        inputPaths = extractor.extractOption(named: "paths")
        targets = extractor.extractOption(named: "target")
        isLogEnabled = extractor.extractFlag(named: "log") > 0
        excludedPaths = extractor.extractOption(named: "exclude")
        isLintMode = extractor.extractFlag(named: "lint") > 0

        let version = packageVersion.map { "\($0.major).\($0.minor)" }
        swiftVersion = extractor.extractOption(named: "swift-version").last ?? version
        remainingArguments = extractor.remainingArguments
    }

    // MARK: Internal

    /// `--log` flag to log events in the plugin
    let isLogEnabled: Bool

    /// `--exclude` option with list of paths to exclude
    let excludedPaths: [String]

    /// `--lint` flag
    let isLintMode: Bool

    /// `--paths` option.
    /// If given, format only the paths passed to `--paths`
    var inputPaths: [String]

    /// `--target` option.
    /// When ran from Xcode, the plugin command is invoked with `--target` arguments,
    /// specifying the targets selected in the plugin dialog.
    let targets: [String]

    /// `--swift-version` option.
    /// When running on a SPM package we infer the minimum Swift version from the
    /// `swift-tools-version` in `Package.swift` by default if the user doesn't specify one manually
    let swiftVersion: String?

    /// Remaining arguments that were not processed by the initializer
    let remainingArguments: [String]

    mutating func updateInputPaths(_ values: [String]) {
        inputPaths = values
    }
}

// MARK: - SourceCodeCleaner

@main
final class SourceCodeCleaner {

    // MARK: Internal

    var pluginArgs: PluginArguments! = nil

    func performCommand(context: CommandContext) throws {
        let filteredPaths = pluginArgs.inputPaths.filter { path in
            !pluginArgs.excludedPaths.contains(where: { path.hasSuffix($0) })
        }

        pluginArgs.updateInputPaths(filteredPaths)

        let workDir = context.pluginWorkDirectory

        let formatOptions: [SwiftFormatOption] = [
            .config(workDir.firstConfigFileInParentDirectories(for: .formatter)?.string),
            .cachePath("\(workDir.string)/swiftformat.cache"),
            .version(pluginArgs.swiftVersion),
        ]
        .appending(.lint, condition: pluginArgs.isLintMode)

        let lintOptions: [SwiftLintOption] = [
            .config(workDir.firstConfigFileInParentDirectories(for: .linter)?.string),
            .strict,
            .processSourceKit,
            .cachePath("\(workDir.string)/swiftlint.cache"),
        ]
        .appending(.fix, condition: !pluginArgs.isLintMode)

        try run(
            execPath: try context.path(for: .formatter),
            tool: .formatter,
            options: formatOptions)

        try run(
            execPath: try context.path(for: .linter),
            tool: .linter,
            options: lintOptions)
    }

    // MARK: Private

    private func run(execPath: Path, tool: Tool, options: [OptionConfigurable]) throws {
        let process = Process(
            launchPath: execPath.string,
            directories: pluginArgs.inputPaths.appending(pluginArgs.remainingArguments),
            arguments: options)

        try process.run()
        process.waitUntilExit()

        if pluginArgs.isLogEnabled {
            log(process.command)
            log("\(tool.rawValue) ended with exit code \(process.terminationStatus)")
        }

        let exitCode = SupportExitCode(process.terminationStatus)
        if exitCode != .success {
            throw exitCode
        }
    }

    private func log(_ value: String) {
        // swiftlint:disable:next no_direct_standard_out_logs
        print("[SourceCodePlugin]:", value)
    }
}

// MARK: CommandPlugin

extension SourceCodeCleaner: CommandPlugin {

    func performCommand(context: PluginContext, arguments: [String]) async throws {
        pluginArgs = PluginArguments(arguments)

        if !pluginArgs.targets.isEmpty {
            // If a set of input targets were given, lint/format the directory for each of them

            let packageDirectories = try context.package
                .targets(named: pluginArgs.targets).map(\.directory.string)

            pluginArgs.updateInputPaths(pluginArgs.inputPaths.appending(packageDirectories))
        } else if pluginArgs.inputPaths.isEmpty {
            // If no targets or paths listed we default to linting/formatting
            // the entire package directory.

            pluginArgs.updateInputPaths(try context.package.inputPaths())
        }

        try performCommand(context: context)
    }
}

#if canImport(XcodeProjectPlugin)
extension SourceCodeCleaner: XcodeCommandPlugin {
    func performCommand(context: XcodePluginContext, arguments: [String]) throws {
        pluginArgs = PluginArguments(arguments)

        //  - Unlike SPM targets which are just directories, Xcode targets are
        //    an arbitrary collection of paths.
        let inputTargetNames = Set(pluginArgs.inputPaths)

        let inputPaths = context.xcodeProject.targets.lazy
            .filter { inputTargetNames.contains($0.displayName) }
            .flatMap(\.inputFiles)
            .compactMap(\.path.extension)
            .filter { $0 == swiftExtension }

        pluginArgs.updateInputPaths(Array(inputPaths))

        try performCommand(context: context)
    }
}
#endif
