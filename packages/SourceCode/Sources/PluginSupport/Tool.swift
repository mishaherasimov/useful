import Foundation

public enum Tool: String {
    case formatter = "SwiftFormat"
    case linter = "SwiftLint"

    public var exitError: SupportExitCode {
        switch self {
        case .formatter: return .formatFailure
        case .linter: return .lintFailure
        }
    }
}
