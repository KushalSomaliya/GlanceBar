import Foundation

enum AppConstants {
    static let appName = "GlanceBar"
    /// Must match CFBundleIdentifier in Resources/Info.plist. Rotated when macOS
    /// Tahoe's per-bundle-ID menu bar state goes bad (the icon stays hidden
    /// while the app runs); see docs/troubleshooting-invisible-icon.md.
    static let bundleIdentifier = "dev.kushal.glancebar2"
    /// Every previous bundle ID, newest first. Used to find and terminate
    /// stale copies and to migrate UserDefaults after a rotation.
    static let legacyBundleIdentifiers = [
        "dev.kushal.glancebar",  // Apr–Oct 2026
        "com.kushal.glancebar",  // original
    ]
    static var allBundleIdentifiers: [String] { [bundleIdentifier] + legacyBundleIdentifiers }
    static let version = "1.1.6"
    static let githubRepo = "KushalSomaliya/GlanceBar"

    /// Commit the running binary was built from, stamped into Info.plist by
    /// build.sh. Nil for raw `swift run` binaries that have no bundle.
    static var buildCommit: String? {
        guard let raw = Bundle.main.object(forInfoDictionaryKey: "GlanceBarBuildCommit") as? String else { return nil }
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        return (trimmed.isEmpty || trimmed == "unknown") ? nil : trimmed
    }

    static let defaultWidgetDirectory = FileManager.default.homeDirectoryForCurrentUser
        .appendingPathComponent(".glancebar")
    static let defaultWidgetFile = defaultWidgetDirectory.appendingPathComponent("index.html")

    static let defaultPanelWidth: CGFloat = 380
    static let cornerRegionSize: CGFloat = 5
    static let cornerActivationDelay: TimeInterval = 0.3
    static let slideAnimationDuration: TimeInterval = 0.25
    static let fileReloadDebounce: TimeInterval = 0.3
}

enum ScreenCorner: String, CaseIterable, Codable {
    case topLeft
    case topRight
    case bottomLeft
    case bottomRight
    case disabled

    var displayName: String {
        switch self {
        case .topLeft: return "Top Left"
        case .topRight: return "Top Right"
        case .bottomLeft: return "Bottom Left"
        case .bottomRight: return "Bottom Right"
        case .disabled: return "Disabled"
        }
    }
}
