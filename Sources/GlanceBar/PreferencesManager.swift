import AppKit
import Carbon.HIToolbox

class PreferencesManager {
    static let widgetFilePathDidChange = Notification.Name("widgetFilePathDidChange")

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
        static let shortcutKeyCode = "shortcutKeyCode"
        static let shortcutModifiers = "shortcutModifiers"
        static let dismissedUpdateCommit = "dismissedUpdateCommit"
        static let dismissedDuplicateInstall = "dismissedDuplicateInstall"
        static let dismissedHiddenIconBuild = "dismissedHiddenIconBuild"
        static let legacyPreferencesMigrated = "legacyPreferencesMigrated"
        static let accessibilityPromptedBuild = "accessibilityPromptedBuild"
    }

    /// Every user-facing setting, so a bundle ID rotation can carry them over.
    private static let migratedKeys: [String] = [
        Keys.hotCorner, Keys.panelWidth, Keys.widgetFilePath, Keys.launchAtLogin,
        Keys.isPinnedToDesktop, Keys.desktopPanelX, Keys.desktopPanelY, Keys.theme,
        Keys.shortcutKey, Keys.shortcutKeyCode, Keys.shortcutModifiers,
        Keys.dismissedUpdateCommit, Keys.dismissedDuplicateInstall,
    ]

    /// True when this launch copied settings over from a previous bundle ID's
    /// defaults domain (set only on the first launch after a rotation).
    private(set) var didMigrateLegacyPreferences = false

    init() {
        migrateLegacyPreferencesIfNeeded()
    }

    /// UserDefaults are keyed by bundle ID, so rotating the ID (the fix for
    /// Tahoe's hidden-icon state) would otherwise reset every setting. On the
    /// first launch under a new ID, copy the newest previous domain's values
    /// for keys not already set here. Runs once; the marker records the ID.
    private func migrateLegacyPreferencesIfNeeded() {
        guard defaults.object(forKey: Keys.legacyPreferencesMigrated) == nil else { return }
        for legacyID in AppConstants.legacyBundleIdentifiers {
            guard let legacy = defaults.persistentDomain(forName: legacyID), !legacy.isEmpty else { continue }
            for key in Self.migratedKeys where defaults.object(forKey: key) == nil {
                if let value = legacy[key] {
                    defaults.set(value, forKey: key)
                }
            }
            didMigrateLegacyPreferences = true
            break
        }
        defaults.set(AppConstants.bundleIdentifier, forKey: Keys.legacyPreferencesMigrated)
    }

    /// Remote commit the user dismissed the update banner for — that exact
    /// update won't be offered again, but a newer one will.
    var dismissedUpdateCommit: String? {
        get { defaults.string(forKey: Keys.dismissedUpdateCommit) }
        set { defaults.set(newValue, forKey: Keys.dismissedUpdateCommit) }
    }

    /// Identity ("path|build") of a duplicate GlanceBar.app the user chose to
    /// ignore — that exact copy isn't flagged again, but a different one is.
    var dismissedDuplicateInstall: String? {
        get { defaults.string(forKey: Keys.dismissedDuplicateInstall) }
        set { defaults.set(newValue, forKey: Keys.dismissedDuplicateInstall) }
    }

    /// Build (commit or version) for which the "menu bar icon hidden by macOS"
    /// notice was dismissed — it returns after the next rebuild if still hidden.
    var dismissedHiddenIconBuild: String? {
        get { defaults.string(forKey: Keys.dismissedHiddenIconBuild) }
        set { defaults.set(newValue, forKey: Keys.dismissedHiddenIconBuild) }
    }

    /// Build for which the system Accessibility prompt was already shown, so
    /// an ungranted hot corner asks once per build rather than on every launch.
    var accessibilityPromptedBuild: String? {
        get { defaults.string(forKey: Keys.accessibilityPromptedBuild) }
        set { defaults.set(newValue, forKey: Keys.accessibilityPromptedBuild) }
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
        set {
            guard newValue != widgetFilePath else { return }
            defaults.set(newValue, forKey: Keys.widgetFilePath)
            NotificationCenter.default.post(name: Self.widgetFilePathDidChange, object: self)
        }
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

    var shortcutKeyCode: Int? {
        get {
            if defaults.object(forKey: Keys.shortcutKeyCode) != nil {
                let keyCode = defaults.integer(forKey: Keys.shortcutKeyCode)
                return (0...Int(UInt16.max)).contains(keyCode) ? keyCode : nil
            }
            guard let keyCode = Self.ansiKeyCode(for: shortcutKey) else { return nil }
            defaults.set(keyCode, forKey: Keys.shortcutKeyCode)
            return keyCode
        }
        set {
            if let newValue {
                defaults.set(newValue, forKey: Keys.shortcutKeyCode)
            } else {
                defaults.removeObject(forKey: Keys.shortcutKeyCode)
            }
        }
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
        let storedKey = shortcutKey
        let key: String
        if let keyCode = shortcutKeyCode {
            key = Self.currentLayoutCharacter(for: keyCode)
                ?? (storedKey.isEmpty ? "Key \(keyCode)" : storedKey)
        } else {
            key = storedKey
        }
        if key.isEmpty { return "None" }
        var parts: [String] = []
        let mods: NSEvent.ModifierFlags = shortcutModifiers
        if mods.contains(NSEvent.ModifierFlags.control) { parts.append("\u{2303}") }
        if mods.contains(NSEvent.ModifierFlags.option) { parts.append("\u{2325}") }
        if mods.contains(NSEvent.ModifierFlags.shift) { parts.append("\u{21E7}") }
        if mods.contains(NSEvent.ModifierFlags.command) { parts.append("\u{2318}") }
        parts.append(key.uppercased())
        return parts.joined()
    }

    private static func ansiKeyCode(for key: String) -> Int? {
        let keyMap: [String: Int] = [
            "a": kVK_ANSI_A, "b": kVK_ANSI_B, "c": kVK_ANSI_C, "d": kVK_ANSI_D,
            "e": kVK_ANSI_E, "f": kVK_ANSI_F, "g": kVK_ANSI_G, "h": kVK_ANSI_H,
            "i": kVK_ANSI_I, "j": kVK_ANSI_J, "k": kVK_ANSI_K, "l": kVK_ANSI_L,
            "m": kVK_ANSI_M, "n": kVK_ANSI_N, "o": kVK_ANSI_O, "p": kVK_ANSI_P,
            "q": kVK_ANSI_Q, "r": kVK_ANSI_R, "s": kVK_ANSI_S, "t": kVK_ANSI_T,
            "u": kVK_ANSI_U, "v": kVK_ANSI_V, "w": kVK_ANSI_W, "x": kVK_ANSI_X,
            "y": kVK_ANSI_Y, "z": kVK_ANSI_Z,
            "0": kVK_ANSI_0, "1": kVK_ANSI_1, "2": kVK_ANSI_2, "3": kVK_ANSI_3,
            "4": kVK_ANSI_4, "5": kVK_ANSI_5, "6": kVK_ANSI_6, "7": kVK_ANSI_7,
            "8": kVK_ANSI_8, "9": kVK_ANSI_9,
            "-": kVK_ANSI_Minus, "=": kVK_ANSI_Equal,
            "[": kVK_ANSI_LeftBracket, "]": kVK_ANSI_RightBracket,
            ";": kVK_ANSI_Semicolon, "'": kVK_ANSI_Quote,
            ",": kVK_ANSI_Comma, ".": kVK_ANSI_Period,
            "/": kVK_ANSI_Slash, "\\": kVK_ANSI_Backslash,
            "`": kVK_ANSI_Grave,
            " ": kVK_Space,
        ]
        return keyMap[key.lowercased()]
    }

    private static func currentLayoutCharacter(for keyCode: Int) -> String? {
        guard let keyCode = UInt16(exactly: keyCode) else { return nil }
        guard let inputSource = TISCopyCurrentKeyboardLayoutInputSource()?.takeRetainedValue() else { return nil }
        guard let rawLayoutData = TISGetInputSourceProperty(inputSource, kTISPropertyUnicodeKeyLayoutData) else {
            return nil
        }
        let layoutData = unsafeBitCast(rawLayoutData, to: CFData.self)
        guard let layoutBytes = CFDataGetBytePtr(layoutData) else { return nil }
        let keyboardLayout = UnsafeRawPointer(layoutBytes).assumingMemoryBound(to: UCKeyboardLayout.self)
        var deadKeyState: UInt32 = 0
        var characters = [UniChar](repeating: 0, count: 4)
        var actualLength = 0
        let status = UCKeyTranslate(
            keyboardLayout,
            keyCode,
            UInt16(kUCKeyActionDisplay),
            0,
            UInt32(LMGetKbdType()),
            OptionBits(kUCKeyTranslateNoDeadKeysMask),
            &deadKeyState,
            characters.count,
            &actualLength,
            &characters
        )
        guard status == noErr, actualLength > 0 else { return nil }
        return String(utf16CodeUnits: characters, count: Int(actualLength))
    }
}
