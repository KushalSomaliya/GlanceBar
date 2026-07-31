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
        guard let keyCode = preferencesManager.shortcutKeyCode else { return }

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
        let status = RegisterEventHotKey(
            UInt32(keyCode),
            carbonMods,
            hotKeyID,
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
}
