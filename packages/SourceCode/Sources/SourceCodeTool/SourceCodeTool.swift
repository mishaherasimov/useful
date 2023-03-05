import ArgumentParser
import Foundation
import PluginSupport

/// A command line tool that formats the given directories using SwiftFormat and SwiftLint,
@main
struct SourceCodeTool: ParsableCommand {

    @Argument(help: "The directories to format")
    var directories: [String]

    @Option(help: "The project's minimum Swift version")
    var swiftVersion: String?

    @Flag(help: "When true, source files are not reformatted")
    var lint = false

    @Flag(help: "When true, log the invocation command and run the result status")
    var log = false

    // MARK: Formatter

    @Option(help: "The absolute path to a SwiftFormat binary")
    var swiftFormatPath: String

    @Option(help: "The absolute path to use for SwiftFormat's cache")
    var swiftFormatCachePath: String?

    @Option(help: "The absolute path to the SwiftFormat config file")
    var swiftFormatConfig: String

    private lazy var formatOptions: [SwiftFormatOption] = [
        .config(swiftFormatConfig),
        .cachePath(swiftFormatCachePath),
        .version(swiftVersion),
    ]
    .appending(.lint, condition: lint)

    // MARK: Linter

    @Option(help: "The absolute path to a SwiftLint binary")
    var swiftLintPath: String

    @Option(help: "The absolute path to use for SwiftLint's cache")
    var swiftLintCachePath: String?

    @Option(help: "The absolute path to the SwiftLint config file")
    var swiftLintConfig: String

    private lazy var lintOptions: [SwiftLintOption] = [
        .config(swiftLintConfig),
        .strict,
        .processSourceKit,
        .cachePath(swiftLintCachePath),
    ]
    .appending(.fix, condition: !lint)

    // MARK: Executions

    mutating func run() throws {
        let linter = Process(
            launchPath: swiftLintPath,
            directories: directories,
            arguments: lintOptions)

        let formatter = Process(
            launchPath: swiftFormatPath,
            directories: directories,
            arguments: formatOptions)

        try run(formatter, tool: .formatter)
        try run(linter, tool: .linter)
    }

    private mutating func run(_ process: Process, tool: Tool) throws {
        try process.run()
        process.waitUntilExit()

        if log {
            log(process.command)
            log("\(tool.rawValue) ended with exit code \(process.terminationStatus)")
        }

        if SupportExitCode(rawValue: process.terminationStatus) == tool.exitError {
            throw ExitCode.failure
        }

        // Any other non-success exit code is an unknown failure
        if process.terminationStatus != EXIT_SUCCESS {
            throw ExitCode(process.terminationStatus)
        }
    }

    private func log(_ value: String) {
        // swiftlint:disable:next no_direct_standard_out_logs
        print("[CodeFormatterTool]:", value)
    }
}
