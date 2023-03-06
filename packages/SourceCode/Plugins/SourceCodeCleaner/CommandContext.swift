import PackagePlugin

// MARK: - CommandContext

/// Shared methods implemented by `PluginContext` and `XcodePluginContext`
protocol CommandContext {
    var pluginWorkDirectory: Path { get }
    func tool(named name: String) throws -> PluginContext.Tool
}

extension CommandContext {
    func path(for tool: Tool) throws -> Path {
        try self.tool(named: tool.name).path
    }
}

// MARK: - PluginContext + CommandContext

extension PluginContext: CommandContext { }

#if canImport(XcodeProjectPlugin)
import XcodeProjectPlugin

extension XcodePluginContext: CommandContext { }
#endif
