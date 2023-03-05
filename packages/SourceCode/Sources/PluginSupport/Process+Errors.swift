import Foundation

public extension Process {
    convenience init(launchPath: String, directories: [String], arguments: [OptionConfigurable]) {
        self.init()
        self.launchPath = launchPath
        self.arguments = [directories, arguments.arguments].flatMap { $0 }
    }

    /// Shell command that invokes the process
    var command: String {
        var command = [launchPath].compactMap { $0 }
        command.append(contentsOf: arguments ?? [])
        return command.joined(separator: " ")
    }
}

public enum SupportExitCode: Int32 {
    /// Known exit codes used by SwiftFormat
    case formatFailure = 1

    /// Known exit codes used by SwiftLint
    case lintFailure = 2
}
