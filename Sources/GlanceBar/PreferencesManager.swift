import AppKit

class PreferencesManager {
    private let defaults = UserDefaults.standard

    private enum Keys {
        static let hotCorner = "hotCorner"
        static let panelWidth = "panelWidth"
        static let widgetFilePath = "widgetFilePath"
        static let launchAtLogin = "launchAtLogin"
        static let isPinnedToDesktop = "isPinnedToDesktop"
        static let desktopPanelX = "desktopPanelX"
        static let desktopPanelY = "desktopPanelY"
        static let theme = "theme"
        static let shortcutKey = "shortcutKey"
        static let shortcutModifiers = "shortcutModifiers"
    }

    var hotCorner: ScreenCorner {
        get {
            guard let raw = defaults.string(forKey: Keys.hotCorner),
                let corner = ScreenCorner(rawValue: raw)
            else { return .bottomRight }
            return corner
        }
        set { defaults.set(newValue.rawValue, forKey: Keys.hotCorner) }
    }

    var panelWidth: CGFloat {
        get {
            let val = defaults.double(forKey: Keys.panelWidth)
            return val > 0 ? val : AppConstants.defaultPanelWidth
        }
        set { defaults.set(newValue, forKey: Keys.panelWidth) }
    }

    var widgetFilePath: String {
        get {
            let val = defaults.string(forKey: Keys.widgetFilePath)
            return val ?? AppConstants.defaultWidgetFile.path
        }
        set { defaults.set(newValue, forKey: Keys.widgetFilePath) }
    }

    var launchAtLogin: Bool {
        get { defaults.bool(forKey: Keys.launchAtLogin) }
        set {
            defaults.set(newValue, forKey: Keys.launchAtLogin)
            LaunchAtLoginManager.setEnabled(newValue)
        }
    }

    var isPinnedToDesktop: Bool {
        get { defaults.bool(forKey: Keys.isPinnedToDesktop) }
        set { defaults.set(newValue, forKey: Keys.isPinnedToDesktop) }
    }

    var desktopPanelX: CGFloat {
        get { defaults.double(forKey: Keys.desktopPanelX) }
        set { defaults.set(newValue, forKey: Keys.desktopPanelX) }
    }

    var desktopPanelY: CGFloat {
        get { defaults.double(forKey: Keys.desktopPanelY) }
        set { defaults.set(newValue, forKey: Keys.desktopPanelY) }
    }

    var theme: String {
        get { defaults.string(forKey: Keys.theme) ?? "auto" }
        set { defaults.set(newValue, forKey: Keys.theme) }
    }

    var shortcutKey: String {
        get { defaults.object(forKey: Keys.shortcutKey) == nil ? "]" : defaults.string(forKey: Keys.shortcutKey) ?? "" }
        set { defaults.set(newValue, forKey: Keys.shortcutKey) }
    }

    var shortcutModifiers: NSEvent.ModifierFlags {
        get {
            if defaults.object(forKey: Keys.shortcutModifiers) == nil { return .command }
            let raw = defaults.integer(forKey: Keys.shortcutModifiers)
            return NSEvent.ModifierFlags(rawValue: UInt(raw))
        }
        set { defaults.set(Int(newValue.rawValue), forKey: Keys.shortcutModifiers) }
    }

    var shortcutDisplayString: String {
        if shortcutKey.isEmpty { return "None" }
        var parts: [String] = []
        let mods: NSEvent.ModifierFlags = shortcutModifiers
        if mods.contains(NSEvent.ModifierFlags.control) { parts.append("\u{2303}") }
        if mods.contains(NSEvent.ModifierFlags.option) { parts.append("\u{2325}") }
        if mods.contains(NSEvent.ModifierFlags.shift) { parts.append("\u{21E7}") }
        if mods.contains(NSEvent.ModifierFlags.command) { parts.append("\u{2318}") }
        parts.append(shortcutKey.uppercased())
        return parts.joined()
    }
}
