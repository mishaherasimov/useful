import Foundation

extension Process {
    public convenience init(launchPath: String, directories: [String], arguments: [OptionConfigurable]) {
        self.init()
        self.launchPath = launchPath
        self.arguments = [directories, arguments.arguments].flatMap { $0 }
    }

    /// Shell command that invokes the process
    public var command: String {
        var command = [launchPath].compactMap { $0 }
        command.append(contentsOf: arguments ?? [])
        return command.joined(separator: " ")
    }
}

// MARK: - SupportExitCode

public enum SupportExitCode: Error, Equatable {
    /// Known exit codes used by SwiftFormat
    case formatFailure

    /// Known exit codes used by SwiftLint
    case lintFailure
    case unknownError(Int32)
    case success

    // MARK: Lifecycle

    public init(_ terminationStatus: Int32) {
        switch terminationStatus {
        case EXIT_SUCCESS:
            self = .success
        case 1:
            self = .formatFailure
        case 2:
            self = .lintFailure
        default:
            self = .unknownError(terminationStatus)
        }
    }
}
