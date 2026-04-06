import AppKit

class StatusBarController {
    private let statusItem: NSStatusItem
    private let onToggle: () -> Void
    private let onPreferences: () -> Void
    private let onEditWidget: () -> Void
    private let onOpenFolder: () -> Void
    private let onToggleDesktopPin: () -> Void
    private let preferencesManager: PreferencesManager
    private var pinMenuItem: NSMenuItem!

    init(
        onToggle: @escaping () -> Void,
        onPreferences: @escaping () -> Void,
        onEditWidget: @escaping () -> Void,
        onOpenFolder: @escaping () -> Void,
        onToggleDesktopPin: @escaping () -> Void,
        preferencesManager: PreferencesManager
    ) {
        self.onToggle = onToggle
        self.onPreferences = onPreferences
        self.onEditWidget = onEditWidget
        self.onOpenFolder = onOpenFolder
        self.onToggleDesktopPin = onToggleDesktopPin
        self.preferencesManager = preferencesManager

        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        if let button = statusItem.button {
            button.image = NSImage(
                systemSymbolName: "sidebar.right",
                accessibilityDescription: "GlanceBar"
            )
            button.action = #selector(statusBarButtonClicked(_:))
            button.target = self
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
    }

    @objc private func statusBarButtonClicked(_ sender: NSStatusBarButton) {
        guard let event = NSApp.currentEvent else { return }

        if event.type == .rightMouseUp {
            showMenu()
        } else {
            onToggle()
        }
    }

    private func showMenu() {
        let menu = NSMenu()

        menu.addItem(withTitle: "Toggle Panel", action: #selector(menuToggle), keyEquivalent: "")
            .target = self

        menu.addItem(.separator())

        pinMenuItem = menu.addItem(
            withTitle: "Pin to Desktop", action: #selector(menuTogglePin), keyEquivalent: ""
        )
        pinMenuItem.target = self
        pinMenuItem.state = preferencesManager.isPinnedToDesktop ? .on : .off

        menu.addItem(.separator())

        menu.addItem(withTitle: "Edit Widget...", action: #selector(menuEditWidget), keyEquivalent: "")
            .target = self
        menu.addItem(
            withTitle: "Open Widget Folder...", action: #selector(menuOpenFolder), keyEquivalent: ""
        ).target = self

        menu.addItem(.separator())

        menu.addItem(withTitle: "Preferences...", action: #selector(menuPreferences), keyEquivalent: ",")
            .target = self

        menu.addItem(.separator())

        menu.addItem(withTitle: "Quit GlanceBar", action: #selector(menuQuit), keyEquivalent: "q")
            .target = self

        statusItem.menu = menu
        statusItem.button?.performClick(nil)
        statusItem.menu = nil
    }

    func updatePinState(_ isPinned: Bool) {
        pinMenuItem?.state = isPinned ? .on : .off
    }

    @objc private func menuToggle() { onToggle() }
    @objc private func menuTogglePin() { onToggleDesktopPin() }
    @objc private func menuEditWidget() { onEditWidget() }
    @objc private func menuOpenFolder() { onOpenFolder() }
    @objc private func menuPreferences() { onPreferences() }
    @objc private func menuQuit() { NSApp.terminate(nil) }
}
