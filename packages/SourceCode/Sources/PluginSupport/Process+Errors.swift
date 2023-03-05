import Foundation

extension Process {

    // MARK: Lifecycle

    public convenience init(launchPath: String, directories: [String], arguments: [OptionConfigurable]) {
        self.init()
        self.launchPath = launchPath
        self.arguments = [directories, arguments.arguments].flatMap { $0 }
    }

    // MARK: Public

    /// Shell command that invokes the process
    public var command: String {
        var command = [launchPath].compactMap { $0 }
        command.append(contentsOf: arguments ?? [])
        return command.joined(separator: " ")
    }
}

// MARK: - SupportExitCode

public enum SupportExitCode: Int32 {
    /// Known exit codes used by SwiftFormat
    case formatFailure = 1

    /// Known exit codes used by SwiftLint
    case lintFailure = 2
}
