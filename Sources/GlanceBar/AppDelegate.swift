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
    private var visibleNotice: BannerNotice?
    private var widgetFilePathObserver: NSObjectProtocol?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // A stale copy left running (old install location, login item from a
        // previous bundle ID) would fight this one over the hotkey and show
        // an outdated widget bridge — kill it before doing anything else.
        terminateOlderInstances()

        preferencesManager = PreferencesManager()
        // Login items are registered per bundle ID: after a bundle ID rotation
        // the migrated preference says "on" but nothing is registered yet.
        if preferencesManager.didMigrateLegacyPreferences, preferencesManager.launchAtLogin {
            LaunchAtLoginManager.setEnabled(true)
        }
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
        checkForDuplicateInstalls()
        checkForHiddenMenuBarIcon()

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
            self?.visibleNotice = nil
            banner.showProgress("Starting update...")
            self?.updateManager.runUpdate()
        }
        banner.onRestart = { [weak self] in self?.restart() }
        banner.onDismiss = { [weak self] in
            guard let self else { return }
            switch self.visibleNotice {
            case .duplicateInstall(let duplicate):
                self.preferencesManager.dismissedDuplicateInstall = duplicate.identity
            case .hiddenIcon:
                self.preferencesManager.dismissedHiddenIconBuild = Self.currentBuildIdentity
            case nil:
                break
            }
            self.visibleNotice = nil
            let dismissedUpdateOffer = self.isUpdateOfferVisible
            self.isUpdateOfferVisible = false
            guard dismissedUpdateOffer else { return }
            self.preferencesManager.dismissedUpdateCommit = self.lastOfferedUpdateCommit
        }
        updateManager.onEvent = { [weak self] event in
            guard let self else { return }
            self.isUpdateOfferVisible = false
            self.visibleNotice = nil
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
            self.visibleNotice = nil
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
            self.visibleNotice = nil
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

    // MARK: - Banner notices

    /// What the native banner is currently showing besides update state, so a
    /// dismissal can be remembered for the right thing.
    private enum BannerNotice {
        case duplicateInstall(DuplicateInstall)
        case hiddenIcon
    }

    private static var currentBuildIdentity: String {
        AppConstants.buildCommit ?? AppConstants.version
    }

    /// Gaps between successive hidden-icon samples. Right after launch, and
    /// especially after `killall ControlCenter` / `killall Dock`, the status
    /// item window sits at a placeholder frame until the menu bar places it,
    /// so a single early sample would cry wolf. Every sample must say hidden.
    private static let hiddenIconSampleIntervals: [TimeInterval] = [3, 8, 15]

    /// macOS Tahoe can leave the status item alive but off-screen while the
    /// hotkey keeps working, which reads as "the app is broken". Say so in the
    /// panel and point at the fix instead of staying silent.
    private func checkForHiddenMenuBarIcon() {
        scheduleHiddenIconSample(index: 0)
    }

    private func scheduleHiddenIconSample(index: Int) {
        guard index < Self.hiddenIconSampleIntervals.count else {
            showHiddenMenuBarIconNotice()
            return
        }
        let delay = Self.hiddenIconSampleIntervals[index]
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            guard let self else { return }
            // One sample that sees the icon in a menu bar settles it.
            guard self.statusBarController.isIconLikelyHidden() else { return }
            self.scheduleHiddenIconSample(index: index + 1)
        }
    }

    private func showHiddenMenuBarIconNotice() {
        guard preferencesManager.dismissedHiddenIconBuild != Self.currentBuildIdentity else { return }
        let banner = panelController.updateBanner
        // A duplicate-install notice or update progress is more urgent — keep it.
        guard banner.isHidden else { return }
        visibleNotice = .hiddenIcon
        banner.showNotice(
            "Menu bar icon is hidden by macOS",
            buttonTitle: "Help",
            tooltip: "GlanceBar is running (the hotkey works) but macOS keeps its menu bar icon off-screen. "
                + "Remove duplicate GlanceBar.app copies, then check System Settings → Menu Bar → "
                + "Allow in the Menu Bar (or your menu bar manager). If it stays hidden, the known fix is "
                + "a new bundle identifier — see docs/troubleshooting-invisible-icon.md."
        ) { [weak self] in
            self?.visibleNotice = nil
            banner.hide()
            let docURL = "https://github.com/\(AppConstants.githubRepo)/blob/main/docs/troubleshooting-invisible-icon.md"
            if let url = URL(string: docURL) {
                NSWorkspace.shared.open(url)
            }
        }
    }

    // MARK: - Duplicate installs

    /// Another GlanceBar.app registered with Launch Services that was built
    /// from different code than this binary.
    private struct DuplicateInstall {
        let url: URL
        let version: String?
        let buildCommit: String?
        let isNewer: Bool

        /// Stable identity for remembering dismissals.
        var identity: String { "\(url.path)|\(buildCommit ?? version ?? "unknown")" }
    }

    /// Spotlight, Raycast and Login Items resolve "GlanceBar" through Launch
    /// Services, which can pick a stale copy (an old /Applications drag, a
    /// leftover dev build) over the one the `glancebar` alias opens. A stale
    /// copy looks alive but runs old code — pre-1.1.5 builds, for example,
    /// ran actions with the bare launchd PATH, so scripts failed unless the
    /// app was started from a terminal. Each copy also rewrites the default
    /// widget HTML to its own template, so the UI flips with whichever copy
    /// launched last. Surface such copies in the native banner so the user
    /// can trash them (or, when the other copy is newer, switch to it).
    private func checkForDuplicateInstalls() {
        guard let duplicate = findDuplicateInstalls().first else { return }
        guard duplicate.identity != preferencesManager.dismissedDuplicateInstall else { return }
        showDuplicateInstallNotice(duplicate)
    }

    private func findDuplicateInstalls() -> [DuplicateInstall] {
        let fm = FileManager.default
        let myURL = Bundle.main.bundleURL.standardizedFileURL.resolvingSymlinksInPath()
        let myCommit = AppConstants.buildCommit
        let myVersion = UpdateChecker.versionComponents(AppConstants.version)
        var seen: Set<String> = [myURL.path]
        var duplicates: [DuplicateInstall] = []

        for bundleID in AppConstants.allBundleIdentifiers {
            for candidate in NSWorkspace.shared.urlsForApplications(withBundleIdentifier: bundleID) {
                let url = candidate.standardizedFileURL.resolvingSymlinksInPath()
                guard seen.insert(url.path).inserted else { continue }
                // Copies already in the Trash cannot be launched by anyone.
                guard !url.pathComponents.contains(".Trash") else { continue }
                let plistURL = url.appendingPathComponent("Contents/Info.plist")
                guard fm.fileExists(atPath: plistURL.path),
                    let info = NSDictionary(contentsOf: plistURL) as? [String: Any]
                else { continue }

                let rawCommit = (info["GlanceBarBuildCommit"] as? String)?
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                let commit = (rawCommit == nil || rawCommit == "" || rawCommit == "unknown") ? nil : rawCommit
                let version = info["CFBundleShortVersionString"] as? String

                // Same commit as this binary (e.g. the build output update.sh
                // leaves in ~/.glancebar-src) is identical code — harmless.
                if let commit, commit == myCommit { continue }
                // Two unstamped builds of the same version are indistinguishable.
                if commit == nil, myCommit == nil, version == AppConstants.version { continue }

                // Same version string but different code (a dev build in a
                // checkout next to the installed app) is told apart by build time.
                let versionOrder = version.map {
                    UpdateChecker.compare(UpdateChecker.versionComponents($0), myVersion)
                } ?? -1
                let isNewer: Bool
                if versionOrder != 0 {
                    isNewer = versionOrder > 0
                } else {
                    let otherBuilt = Self.executableModificationDate(of: url)
                    let thisBuilt = Self.executableModificationDate(of: Bundle.main.bundleURL)
                    isNewer = otherBuilt > thisBuilt
                }
                duplicates.append(
                    DuplicateInstall(url: url, version: version, buildCommit: commit, isNewer: isNewer))
            }
        }
        return duplicates
    }

    private static func executableModificationDate(of bundleURL: URL) -> Date {
        let executable = bundleURL.appendingPathComponent("Contents/MacOS/\(AppConstants.appName)")
        let attributes = try? FileManager.default.attributesOfItem(atPath: executable.path)
        return attributes?[.modificationDate] as? Date ?? .distantPast
    }

    private func showDuplicateInstallNotice(_ duplicate: DuplicateInstall) {
        let banner = panelController.updateBanner
        let path = (duplicate.url.path as NSString).abbreviatingWithTildeInPath
        let folder = (duplicate.url.deletingLastPathComponent().path as NSString).abbreviatingWithTildeInPath
        let otherVersion = duplicate.version.map { "v\($0)" } ?? "unstamped build"
        isUpdateOfferVisible = false
        visibleNotice = .duplicateInstall(duplicate)

        if duplicate.isNewer {
            banner.showNotice(
                "Newer copy (\(otherVersion)) in \(folder)",
                buttonTitle: "Open",
                tooltip: "A newer GlanceBar (\(otherVersion)) is installed at \(path). "
                    + "This copy (v\(AppConstants.version)) is out of date — open the newer one instead; "
                    + "it takes over from this copy."
            ) { [weak self] in
                self?.visibleNotice = nil
                banner.hide()
                NSWorkspace.shared.openApplication(
                    at: duplicate.url, configuration: NSWorkspace.OpenConfiguration()
                ) { _, _ in }
            }
        } else {
            banner.showNotice(
                "Stale copy (\(otherVersion)) in \(folder)",
                buttonTitle: "Trash",
                tooltip: "Another GlanceBar (\(otherVersion)) is installed at \(path). "
                    + "Spotlight, Raycast and Login Items can launch that stale copy instead of this one "
                    + "(v\(AppConstants.version)), so GlanceBar looks like it is running but with old code. "
                    + "Move it to the Trash so only this copy can start."
            ) { [weak self] in
                self?.trashDuplicateInstall(duplicate)
            }
        }
    }

    private func trashDuplicateInstall(_ duplicate: DuplicateInstall) {
        let banner = panelController.updateBanner
        visibleNotice = nil
        // Quit any running instance of that copy first so it cannot keep
        // owning the hotkey or come back on top after its bundle is gone.
        let bundlePrefix = duplicate.url.path + "/"
        for app in NSWorkspace.shared.runningApplications {
            guard app.processIdentifier != ProcessInfo.processInfo.processIdentifier,
                let executable = app.executableURL?.standardizedFileURL.resolvingSymlinksInPath(),
                executable.path.hasPrefix(bundlePrefix)
            else { continue }
            app.terminate()
        }
        NSWorkspace.shared.recycle([duplicate.url]) { [weak self] _, error in
            DispatchQueue.main.async {
                guard let self else { return }
                if let error {
                    banner.showTransient("Could not trash it: \(error.localizedDescription)")
                } else {
                    banner.showTransient("Moved the stale copy to the Trash \u{2713}")
                    // Surface the next duplicate, if there is more than one.
                    self.checkForDuplicateInstalls()
                }
            }
        }
    }

    /// Terminates other running GlanceBar instances (any bundle ID vintage)
    /// that launched before this one.
    private func terminateOlderInstances() {
        let myPID = ProcessInfo.processInfo.processIdentifier
        let myLaunchDate = NSRunningApplication.current.launchDate ?? Date()
        let bundleIDs = AppConstants.allBundleIdentifiers

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
