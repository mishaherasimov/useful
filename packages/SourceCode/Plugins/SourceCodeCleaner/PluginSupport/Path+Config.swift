import Foundation
import PackagePlugin

extension Path {

    // MARK: Internal

    /// Scans the receiver, then all of its parents looking for a configuration file with the provided name.
    /// - Parameter file: Configuration file name
    /// - Returns: Path to the configuration file, or nil if one cannot be found.
    func firstConfigFileInParentDirectories(for tool: Tool) -> Path? {
        let proposedDirectory = sequence(
            first: self,
            next: { path in
                // Check if we're not at the root of this filesystem, as `removingLastComponent()`
                // will continually return the root from itself.
                path.stem.count > 1 ? path.removingLastComponent() : nil
            })
            // Check potential configuration file
            .first { $0.appending(subpath: tool.configFile).isAccessible() }

        return proposedDirectory?.appending(subpath: tool.configFile)
    }

    // MARK: Private

    /// Safe way to check if the file is accessible from within the current process sandbox.
    private func isAccessible() -> Bool {
        let result = string.withCString { pointer in
            access(pointer, R_OK)
        }

        return result == 0
    }
}
