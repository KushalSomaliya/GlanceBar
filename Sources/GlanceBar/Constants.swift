import Foundation

enum AppConstants {
    static let appName = "GlanceBar"
    static let bundleIdentifier = "dev.kushal.glancebar"
    static let version = "1.1.1"
    static let githubRepo = "KushalSomaliya/GlanceBar"

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
