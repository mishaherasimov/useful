import Foundation
import PackagePlugin

extension Package {

    /// Retrieves the list of paths that should be formatted / linted
    ///
    /// By default this tool runs on all subdirectories of the package's root directory,
    /// plus any Swift files directly contained in the root directory. This is a
    /// workaround for two interesting issues:
    ///  - If we lint `content.package.directory`, then SwiftLint lints the `.build` subdirectory,
    ///    which includes checkouts for any SPM dependencies, even if we add `.build` to the
    ///    `excluded` configuration in our `swiftlint.yml`.
    ///  - We could lint `context.package.targets.map { $0.directory }`, but that excludes
    ///    plugin targets, which include Swift code that we want to lint.
    func inputPaths() throws -> [String] {
        let packageDirectoryContents = try FileManager.default.contentsOfDirectory(
            at: URL(fileURLWithPath: directory.string),
            includingPropertiesForKeys: nil,
            options: [.skipsHiddenFiles])

        let subdirectories = packageDirectoryContents.filter(\.hasDirectoryPath)
        let rootSwiftFiles = packageDirectoryContents.filter { $0.pathExtension.hasSuffix(swiftExtension) }
        return subdirectories.appending(rootSwiftFiles).map(\.path)
    }
}
