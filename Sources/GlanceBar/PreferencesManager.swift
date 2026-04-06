import Foundation

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
}
