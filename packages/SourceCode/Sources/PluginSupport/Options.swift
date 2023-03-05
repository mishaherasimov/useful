import Foundation

// MARK: - SwiftFormatOption

public enum SwiftFormatOption: OptionConfigurable {
    case config(String?)
    case lint
    case version(String?)
    case cachePath(String?)

    public var arguments: [String] {
        switch self {
        case .lint:
            return ["--lint"]
        case .config(let .some(path)):
            return ["--config", path]
        case .version(let .some(ver)):
            return ["--swiftversion", ver]
        case .cachePath(let .some(path)):
            return ["--cache", path]
        case .config(.none), .cachePath(.none), .version(.none):
            return []
        }
    }
}

// MARK: - SwiftLintOption

public enum SwiftLintOption: OptionConfigurable {
    case config(String?)
    case strict
    case processSourceKit
    case cachePath(String?)
    case forceExclude
    case fix
    case quiet

    // MARK: Public

    public var arguments: [String] {
        switch self {
        case .fix:
            return ["--fix"]
        case .config(let .some(path)):
            return ["--config", path]
        case .strict:
            return ["--strict"]
        case .processSourceKit:
            return ["--in-process-sourcekit"]
        case .cachePath(let .some(path)):
            return ["--cache-path", path]
        case .cachePath(.none), .config(.none):
            return []
        case .forceExclude:
            return ["--force-exclude"]
        case .quiet:
            return ["--quiet"]
        }
    }
}

// MARK: - OptionConfigurable

public protocol OptionConfigurable {
    var arguments: [String] { get }
}

// MARK: OptionConfigurable

extension [OptionConfigurable]: OptionConfigurable {
    public var arguments: [String] {
        reduce([]) { $0 + $1.arguments }
    }
}

extension Array {
    public func appending(_ value: Element, condition: Bool) -> Self {
        var args = self
        if condition {
            args.append(value)
        }
        return args
    }
}
