import Foundation

// MARK: - SwiftFormatOption

public enum SwiftFormatOption: OptionConfigurable {
    case config(String?)
    case lint
    case version(String?)

    /// The process we spawn doesn't have read/write access to the default
    /// cache file locations, so we pass in our own cache paths from the plugin's work directory.
    case cachePath(String?)

    // MARK: Public

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
