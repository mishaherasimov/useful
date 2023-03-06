import Foundation

public enum Tool: String {
    case formatter = "SwiftFormat"
    case linter = "SwiftLint"

    public var configFile: String {
        switch self {
        case .linter: return ".swiftlint.yml"
        case .formatter: return ".swiftformat"
        }
    }

    var name: String {
        rawValue.lowercased()
    }
}
