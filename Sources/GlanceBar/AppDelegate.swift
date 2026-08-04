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
    private var updateManager: UpdateManager!
    private var lastOfferedUpdateCommit: String?
    private var isUpdateOfferVisible = false
    private var widgetFilePathObserver: NSObjectProtocol?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // A stale copy left running (old install location, login item from a
        // previous bundle ID) would fight this one over the hotkey and show
        // an outdated widget bridge — kill it before doing anything else.
        terminateOlderInstances()

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
            onCheckForUpdates: { [weak self] in self?.checkForUpdatesManually() },
            onRestart: { [weak self] in self?.restart() },
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
        widgetFilePathObserver = NotificationCenter.default.addObserver(
            forName: PreferencesManager.widgetFilePathDidChange,
            object: preferencesManager,
            queue: .main
        ) { [weak self] _ in
            self?.applyWidgetFilePathChange()
        }

        setupUpdateSystem()

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
        if let widgetFilePathObserver {
            NotificationCenter.default.removeObserver(widgetFilePathObserver)
            self.widgetFilePathObserver = nil
        }
        fileWatcher?.stop()
        hotCornerMonitor.stop()
        globalShortcutManager.stop()
    }

    private func togglePanel() {
        panelController.toggle()
    }

    // MARK: - Updates

    private func setupUpdateSystem() {
        updateChecker = UpdateChecker()
        updateManager = UpdateManager()

        let banner = panelController.updateBanner
        banner.onUpdate = { [weak self] in
            self?.isUpdateOfferVisible = false
            banner.showProgress("Starting update...")
            self?.updateManager.runUpdate()
        }
        banner.onRestart = { [weak self] in self?.restart() }
        banner.onDismiss = { [weak self] in
            guard let self else { return }
            let dismissedUpdateOffer = self.isUpdateOfferVisible
            self.isUpdateOfferVisible = false
            guard dismissedUpdateOffer else { return }
            self.preferencesManager.dismissedUpdateCommit = self.lastOfferedUpdateCommit
        }
        updateManager.onEvent = { [weak self] event in
            guard let self else { return }
            self.isUpdateOfferVisible = false
            let banner = self.panelController.updateBanner
            switch event {
            case .status(let text): banner.showProgress(text)
            case .upToDate: banner.showRestart("Update complete — restart GlanceBar")
            case .failed(let error): banner.showError(error)
            }
        }
        // Legacy widget HTML can still post 'runUpdate' from its in-page banner.
        panelController.webViewController.onRunUpdate = { [weak self] in
            self?.isUpdateOfferVisible = false
            self?.updateManager.runUpdate()
        }

        autoCheckForUpdates()
        panelController.setOnPanelShow { [weak self] in self?.autoCheckForUpdates() }
    }

    private func autoCheckForUpdates() {
        guard !updateManager.isRunning else { return }
        updateChecker.checkForUpdates { [weak self] status in
            guard let self, !self.updateManager.isRunning else { return }
            guard case .updateAvailable(let commit, let summary) = status else { return }
            if let commit, commit == self.preferencesManager.dismissedUpdateCommit { return }
            self.lastOfferedUpdateCommit = commit
            self.isUpdateOfferVisible = true
            self.panelController.updateBanner.showUpdateAvailable(summary)
        }
    }

    private func checkForUpdatesManually() {
        panelController.show()
        guard !updateManager.isRunning else { return }
        preferencesManager.dismissedUpdateCommit = nil
        updateChecker.checkForUpdates(force: true) { [weak self] status in
            guard let self, !self.updateManager.isRunning else { return }
            let banner = self.panelController.updateBanner
            switch status {
            case .upToDate:
                self.isUpdateOfferVisible = false
                banner.showTransient("GlanceBar is up to date \u{2713}")
            case .updateAvailable(let commit, let summary):
                self.lastOfferedUpdateCommit = commit
                self.isUpdateOfferVisible = true
                banner.showUpdateAvailable(summary)
            case .checkFailed(let error):
                self.isUpdateOfferVisible = false
                banner.showTransient("Update check failed: \(error)")
            }
        }
    }

    /// Relaunches only after this process is gone so Launch Services cannot
    /// reactivate an instance that is already terminating.
    private func restart() {
        let helper = Process()
        helper.executableURL = URL(fileURLWithPath: "/usr/bin/nohup")
        helper.arguments = [
            "/bin/sh",
            "-c",
            """
            while /bin/kill -0 "$1" 2>/dev/null; do
                /bin/sleep 0.1
            done
            exec /usr/bin/open -n "$2"
            """,
            "GlanceBar restart helper",
            String(ProcessInfo.processInfo.processIdentifier),
            Bundle.main.bundlePath,
        ]
        helper.standardInput = FileHandle.nullDevice
        helper.standardOutput = FileHandle.nullDevice
        helper.standardError = FileHandle.nullDevice

        do {
            try helper.run()
        } catch {
            print("GlanceBar: Failed to start restart helper: \(error)")
            return
        }

        NSApp.terminate(nil)
    }

    /// Terminates other running GlanceBar instances (any bundle ID vintage)
    /// that launched before this one.
    private func terminateOlderInstances() {
        let myPID = ProcessInfo.processInfo.processIdentifier
        let myLaunchDate = NSRunningApplication.current.launchDate ?? Date()
        let bundleIDs = [AppConstants.bundleIdentifier, AppConstants.legacyBundleIdentifier]

        for app in NSWorkspace.shared.runningApplications {
            guard app.processIdentifier != myPID else { continue }
            let isGlanceBar = bundleIDs.contains(app.bundleIdentifier ?? "")
                || app.executableURL?.lastPathComponent == AppConstants.appName
            guard isGlanceBar else { continue }
            // Only kill peers positively confirmed to be older — an unknown
            // launchDate could be a just-registered newer instance. On an
            // exact tie, the lower PID yields so a simultaneous dual-launch
            // deterministically leaves one survivor.
            guard let theirLaunchDate = app.launchDate else { continue }
            if theirLaunchDate > myLaunchDate { continue }
            if theirLaunchDate == myLaunchDate && app.processIdentifier > myPID { continue }

            app.terminate()
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                if !app.isTerminated { app.forceTerminate() }
            }
        }
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

        if !FileManager.default.fileExists(atPath: dir.path) {
            try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        }

        // Creates the widget file on first launch, and refreshes it after app
        // updates when it's still an unmodified app-generated default.
        WidgetTemplate.ensureCurrent(at: preferencesManager.widgetFilePath)
    }

    private func startFileWatcher() {
        let path = preferencesManager.widgetFilePath
        fileWatcher = FileWatcher(filePath: path) { [weak self] in
            self?.panelController.reloadWebView()
        }
        fileWatcher?.start()
    }

    private func applyWidgetFilePathChange() {
        let previousFileWatcher = fileWatcher
        previousFileWatcher?.stop()
        fileWatcher = nil

        WidgetTemplate.ensureCurrent(at: preferencesManager.widgetFilePath)
        panelController.reloadWebView()
        startFileWatcher()

        // Keep the old watcher alive until its cancel handler closes the file descriptor.
        DispatchQueue.main.async {
            withExtendedLifetime(previousFileWatcher) {}
        }
    }
}
