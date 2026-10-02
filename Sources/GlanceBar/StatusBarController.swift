import AppKit

class StatusBarController {
    private let statusItem: NSStatusItem
    private let onToggle: () -> Void
    private let onPreferences: () -> Void
    private let onEditWidget: () -> Void
    private let onOpenFolder: () -> Void
    private let onToggleDesktopPin: () -> Void
    private let onCheckForUpdates: () -> Void
    private let onRestart: () -> Void
    private let preferencesManager: PreferencesManager
    private var pinMenuItem: NSMenuItem!

    init(
        onToggle: @escaping () -> Void,
        onPreferences: @escaping () -> Void,
        onEditWidget: @escaping () -> Void,
        onOpenFolder: @escaping () -> Void,
        onToggleDesktopPin: @escaping () -> Void,
        onCheckForUpdates: @escaping () -> Void,
        onRestart: @escaping () -> Void,
        preferencesManager: PreferencesManager
    ) {
        self.onToggle = onToggle
        self.onPreferences = onPreferences
        self.onEditWidget = onEditWidget
        self.onOpenFolder = onOpenFolder
        self.onToggleDesktopPin = onToggleDesktopPin
        self.onCheckForUpdates = onCheckForUpdates
        self.onRestart = onRestart
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

        let buildSuffix = AppConstants.buildCommit.map { " (\($0.prefix(7)))" } ?? ""
        let versionItem = menu.addItem(
            withTitle: "GlanceBar v\(AppConstants.version)\(buildSuffix)", action: nil, keyEquivalent: ""
        )
        versionItem.isEnabled = false

        // Which copy is running matters when several GlanceBar.app bundles
        // exist — Spotlight, Raycast and Login Items may launch a different
        // one than the `glancebar` alias. Clicking reveals it in Finder.
        let bundlePath = (Bundle.main.bundlePath as NSString).abbreviatingWithTildeInPath
        menu.addItem(withTitle: "Running from \(bundlePath)", action: #selector(menuRevealBundle), keyEquivalent: "")
            .target = self

        menu.addItem(withTitle: "Check for Updates...", action: #selector(menuCheckForUpdates), keyEquivalent: "")
            .target = self

        menu.addItem(.separator())

        menu.addItem(withTitle: "Restart GlanceBar", action: #selector(menuRestart), keyEquivalent: "")
            .target = self
        menu.addItem(withTitle: "Quit GlanceBar", action: #selector(menuQuit), keyEquivalent: "q")
            .target = self

        statusItem.menu = menu
        statusItem.button?.performClick(nil)
        statusItem.menu = nil
    }

    func updatePinState(_ isPinned: Bool) {
        pinMenuItem?.state = isPinned ? .on : .off
    }

    /// macOS Tahoe can keep a status item "allowed" yet park its window
    /// off-screen (docs/troubleshooting-invisible-icon.md shows frames like
    /// (0, -5, 38, 22)). A visible status item's window overlaps the menu bar
    /// strip at the top of some screen; a hidden one overlaps none. Returns
    /// false when the answer is unknown (no window yet, zero-size frame, user
    /// removed the item) so a transient state during launch or a menu bar
    /// restart never raises a false alarm on its own.
    func isIconLikelyHidden() -> Bool {
        guard statusItem.isVisible, let window = statusItem.button?.window else { return false }
        let frame = window.frame
        guard frame.width > 0, frame.height > 0 else { return false }
        let stripHeight: CGFloat = 60
        let overlapsAMenuBar = NSScreen.screens.contains { screen in
            let strip = NSRect(
                x: screen.frame.minX, y: screen.frame.maxY - stripHeight,
                width: screen.frame.width, height: stripHeight)
            return strip.intersects(frame)
        }
        return !overlapsAMenuBar
    }

    @objc private func menuToggle() { onToggle() }
    @objc private func menuTogglePin() { onToggleDesktopPin() }
    @objc private func menuEditWidget() { onEditWidget() }
    @objc private func menuOpenFolder() { onOpenFolder() }
    @objc private func menuPreferences() { onPreferences() }
    @objc private func menuCheckForUpdates() { onCheckForUpdates() }
    @objc private func menuRevealBundle() {
        NSWorkspace.shared.activateFileViewerSelecting([Bundle.main.bundleURL])
    }
    @objc private func menuRestart() { onRestart() }
    @objc private func menuQuit() { NSApp.terminate(nil) }
}
