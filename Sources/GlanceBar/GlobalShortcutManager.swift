import AppKit
import Carbon.HIToolbox

// Uses Carbon RegisterEventHotKey — works globally WITHOUT Accessibility permissions.
// This is what Alfred, Raycast, and most macOS hotkey apps use.

private var globalShortcutManagerInstance: GlobalShortcutManager?

class GlobalShortcutManager {
    private let onToggle: () -> Void
    private let preferencesManager: PreferencesManager
    private var hotKeyRef: EventHotKeyRef?
    private var eventHandlerRef: EventHandlerRef?

    init(onToggle: @escaping () -> Void, preferencesManager: PreferencesManager) {
        self.onToggle = onToggle
        self.preferencesManager = preferencesManager
        globalShortcutManagerInstance = self
    }

    func start() {
        stop()
        let key = preferencesManager.shortcutKey
        if key.isEmpty { return }

        guard let keyCode = carbonKeyCode(for: key) else {
            print("GlanceBar: Unknown key '\(key)' for hotkey registration")
            return
        }

        let mods = preferencesManager.shortcutModifiers
        let carbonMods = carbonModifiers(from: mods)

        // Install event handler for hotkey events
        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))

        let handler: EventHandlerUPP = { _, event, _ -> OSStatus in
            globalShortcutManagerInstance?.onToggle()
            return noErr
        }

        InstallEventHandler(GetEventDispatcherTarget(), handler, 1, &eventType, nil, &eventHandlerRef)

        // Register the hotkey
        let hotKeyID = EventHotKeyID(signature: OSType(0x474C4E43), id: 1) // "GLNC"
        var hotKeyIDVar = hotKeyID
        let status = RegisterEventHotKey(
            UInt32(keyCode),
            carbonMods,
            hotKeyIDVar,
            GetEventDispatcherTarget(),
            0,
            &hotKeyRef
        )

        if status != noErr {
            print("GlanceBar: Failed to register hotkey (status: \(status))")
        }
    }

    func stop() {
        if let ref = hotKeyRef {
            UnregisterEventHotKey(ref)
            hotKeyRef = nil
        }
        if let ref = eventHandlerRef {
            RemoveEventHandler(ref)
            eventHandlerRef = nil
        }
    }

    func restart() { stop(); start() }

    // Convert NSEvent modifier flags to Carbon modifier mask
    private func carbonModifiers(from flags: NSEvent.ModifierFlags) -> UInt32 {
        var carbonMods: UInt32 = 0
        if flags.contains(NSEvent.ModifierFlags.command) { carbonMods |= UInt32(cmdKey) }
        if flags.contains(NSEvent.ModifierFlags.option) { carbonMods |= UInt32(optionKey) }
        if flags.contains(NSEvent.ModifierFlags.control) { carbonMods |= UInt32(controlKey) }
        if flags.contains(NSEvent.ModifierFlags.shift) { carbonMods |= UInt32(shiftKey) }
        return carbonMods
    }

    // Convert a character to a Carbon virtual key code
    private func carbonKeyCode(for key: String) -> Int? {
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
}
