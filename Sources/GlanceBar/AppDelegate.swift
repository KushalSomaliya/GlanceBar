import AppKit
import SwiftUI
import WebKit

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusBarController: StatusBarController!
    private var panelController: PanelController!
    private var fileWatcher: FileWatcher?
    private var hotCornerMonitor: HotCornerMonitor!
    private var globalShortcutManager: GlobalShortcutManager!
    private var preferencesManager: PreferencesManager!
    private var preferencesWindowController: NSWindowController?
    private var updateChecker: UpdateChecker!

    func applicationDidFinishLaunching(_ notification: Notification) {
        preferencesManager = PreferencesManager()
        ensureWidgetDirectory()

        panelController = PanelController(preferencesManager: preferencesManager)
        panelController.setOnPreferencesShortcut { [weak self] in self?.showPreferences() }

        statusBarController = StatusBarController(
            onToggle: { [weak self] in self?.togglePanel() },
            onPreferences: { [weak self] in self?.showPreferences() },
            onEditWidget: { [weak self] in self?.editWidget() },
            onOpenFolder: { [weak self] in self?.openWidgetFolder() },
            onToggleDesktopPin: { [weak self] in self?.toggleDesktopPin() },
            preferencesManager: preferencesManager
        )

        hotCornerMonitor = HotCornerMonitor(
            preferencesManager: preferencesManager,
            onTrigger: { [weak self] in self?.togglePanel() }
        )
        hotCornerMonitor.start()

        globalShortcutManager = GlobalShortcutManager(
            onToggle: { [weak self] in self?.togglePanel() },
            preferencesManager: preferencesManager
        )
        globalShortcutManager.start()

        startFileWatcher()

        // Check for updates
        updateChecker = UpdateChecker()
        updateChecker.onUpdateAvailable = { [weak self] version in
            self?.panelController.showUpdateBanner(version: version)
        }
        updateChecker.checkForUpdates()
        panelController.setOnPanelShow { [weak self] in self?.updateChecker.checkForUpdates() }

        // Re-apply theme when macOS appearance changes (light/dark schedule)
        DistributedNotificationCenter.default().addObserver(
            forName: NSNotification.Name("AppleInterfaceThemeChangedNotification"),
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.panelController.applyTheme()
        }

        // Auto-close panel on desktop/space switch
        NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.activeSpaceDidChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.panelController.dismissIfVisible()
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        fileWatcher?.stop()
        hotCornerMonitor.stop()
        globalShortcutManager.stop()
    }

    private func togglePanel() {
        panelController.toggle()
    }

    private func showPreferences() {
        if let existing = preferencesWindowController {
            existing.showWindow(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let prefsView = PreferencesView(
            preferences: preferencesManager,
            onThemeChanged: { [weak self] in self?.panelController.applyTheme() },
            onShortcutChanged: { [weak self] in self?.globalShortcutManager.restart() }
        )
        let hostingController = NSHostingController(rootView: prefsView)
        let window = NSWindow(contentViewController: hostingController)
        window.title = "GlanceBar Preferences"
        window.styleMask = NSWindow.StyleMask([.titled, .closable])
        window.setContentSize(NSSize(width: 420, height: 400))
        window.center()

        let controller = NSWindowController(window: window)
        controller.showWindow(nil as AnyObject?)
        NSApp.activate(ignoringOtherApps: true)
        preferencesWindowController = controller
    }

    private func editWidget() {
        let path = preferencesManager.widgetFilePath
        let url = URL(fileURLWithPath: path)
        NSWorkspace.shared.open(url)
    }

    private func openWidgetFolder() {
        let path = preferencesManager.widgetFilePath
        let url = URL(fileURLWithPath: path)
        NSWorkspace.shared.activateFileViewerSelecting([url])
    }

    private func toggleDesktopPin() {
        panelController.toggleDesktopPin()
        statusBarController.updatePinState(panelController.isPinnedToDesktop)
    }

    private func ensureWidgetDirectory() {
        let dir = AppConstants.defaultWidgetDirectory
        let file = URL(fileURLWithPath: preferencesManager.widgetFilePath)

        if !FileManager.default.fileExists(atPath: dir.path) {
            try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        }

        if !FileManager.default.fileExists(atPath: file.path) {
            copyDefaultWidget(to: file)
        }
    }

    private func copyDefaultWidget(to destination: URL) {
        let defaultHTML = DefaultWidget.html
        try? defaultHTML.write(to: destination, atomically: true, encoding: .utf8)
    }

    private func startFileWatcher() {
        let path = preferencesManager.widgetFilePath
        fileWatcher = FileWatcher(filePath: path) { [weak self] in
            self?.panelController.reloadWebView()
        }
        fileWatcher?.start()
    }
}
