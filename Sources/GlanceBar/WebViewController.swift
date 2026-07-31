import AppKit
import Darwin
import WebKit

class WebViewController: NSObject, WKScriptMessageHandler, WKNavigationDelegate {
    private final class ActionExecutionState: @unchecked Sendable {
        private let lock = NSLock()
        private var timedOut = false
        private var finished = false

        func timeOut(_ process: Process) -> Bool {
            lock.lock()
            defer { lock.unlock() }

            guard !finished, process.isRunning else { return false }
            // Process shares GlanceBar's process group, so signal only its direct PID.
            guard kill(process.processIdentifier, SIGTERM) == 0 else { return false }
            timedOut = true
            return true
        }

        func killIfRunning(_ process: Process) {
            lock.lock()
            defer { lock.unlock() }

            if timedOut && !finished && process.isRunning {
                _ = kill(process.processIdentifier, SIGKILL)
            }
        }

        func finish() -> Bool {
            lock.lock()
            finished = true
            let didTimeOut = timedOut
            lock.unlock()
            return didTimeOut
        }
    }

    private final class CappedOutput: @unchecked Sendable {
        private(set) var data = Data()
        private(set) var wasTruncated = false

        func drain(_ handle: FileHandle, limit: Int) {
            while true {
                guard let chunk = try? handle.read(upToCount: 64 * 1024),
                    !chunk.isEmpty
                else { return }

                let remaining = max(0, limit - data.count)
                if remaining > 0 {
                    data.append(contentsOf: chunk.prefix(remaining))
                }
                if chunk.count > remaining {
                    wasTruncated = true
                }
            }
        }
    }

    let webView: WKWebView
    private let preferencesManager: PreferencesManager
    private var allowsAboutBlankNavigation = false

    /// Invoked when legacy widget HTML posts a 'runUpdate' message (old
    /// in-page banner). The native banner drives updates through
    /// UpdateManager directly.
    var onRunUpdate: (() -> Void)?

    private var dataFilePath: String {
        let dir = AppConstants.defaultWidgetDirectory.path
        return "\(dir)/data.json"
    }

    private var widgetDirectoryURL: URL {
        return URL(fileURLWithPath: preferencesManager.widgetFilePath)
            .deletingLastPathComponent()
            .standardizedFileURL
            .resolvingSymlinksInPath()
    }

    private static let bridgeScript = WKUserScript(
        source: """
            window.GlanceBar = {
                copy: function(text) {
                    window.webkit.messageHandlers.glancebar.postMessage({ action: 'copy', text: text });
                },
                openURL: function(url) {
                    window.webkit.messageHandlers.glancebar.postMessage({ action: 'openURL', url: url });
                },
                saveData: function(data) {
                    window.webkit.messageHandlers.glancebar.postMessage({ action: 'saveData', data: JSON.stringify(data) });
                },
                exportData: function() {
                    window.webkit.messageHandlers.glancebar.postMessage({ action: 'exportData' });
                },
                importData: function() {
                    window.webkit.messageHandlers.glancebar.postMessage({ action: 'importData' });
                },
                runAction: function(id, command, timeout) {
                    window.webkit.messageHandlers.glancebar.postMessage({ action: 'runAction', id: id, command: command, timeout: timeout || 30 });
                }
            };
            """,
        injectionTime: .atDocumentStart,
        forMainFrameOnly: true
    )

    init(preferencesManager: PreferencesManager) {
        self.preferencesManager = preferencesManager

        let config = WKWebViewConfiguration()
        config.preferences.setValue(true, forKey: "developerExtrasEnabled")

        webView = WKWebView(frame: .zero, configuration: config)
        webView.setValue(false, forKey: "drawsBackground")
        webView.allowsMagnification = false

        super.init()

        rebuildUserScripts(theme: preferencesManager.theme)
        webView.navigationDelegate = self
        config.userContentController.add(self, name: "glancebar")
    }

    /// Injects the bridge plus a document-start theme stamp. Setting
    /// data-theme before first paint prevents the flash of the wrong theme
    /// on every load when the forced theme differs from the system one.
    private func rebuildUserScripts(theme: String) {
        let controller = webView.configuration.userContentController
        controller.removeAllUserScripts()
        controller.addUserScript(Self.bridgeScript)
        controller.addUserScript(WKUserScript(
            source: "document.documentElement.setAttribute('data-theme', '\(theme)');",
            injectionTime: .atDocumentStart,
            forMainFrameOnly: true
        ))
    }

    func loadWidget() {
        let filePath = preferencesManager.widgetFilePath
        let fileURL = URL(fileURLWithPath: filePath)
        let accessDirectory = fileURL.deletingLastPathComponent()

        if FileManager.default.fileExists(atPath: filePath) {
            allowsAboutBlankNavigation = false
            webView.loadFileURL(fileURL, allowingReadAccessTo: accessDirectory)
        } else {
            allowsAboutBlankNavigation = true
            webView.loadHTMLString(
                "<html><body style='color:white;font-family:system-ui;padding:20px;'>"
                    + "<h2>No widget file found</h2>"
                    + "<p>Create a file at:<br><code>\(filePath)</code></p>"
                    + "</body></html>",
                baseURL: nil
            )
        }
    }

    func reload() {
        loadWidget()
    }

    private func isWidgetURL(_ url: URL) -> Bool {
        let host = url.host?.lowercased()
        guard url.isFileURL, host == nil || host == "" || host == "localhost" else {
            return false
        }

        let directoryComponents = widgetDirectoryURL.pathComponents
        let urlComponents = url.standardizedFileURL
            .resolvingSymlinksInPath()
            .pathComponents
        return urlComponents.starts(with: directoryComponents)
    }

    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.cancel)
            return
        }

        if isWidgetURL(url) {
            decisionHandler(.allow)
            return
        }

        if allowsAboutBlankNavigation,
            navigationAction.targetFrame?.isMainFrame == true,
            url.absoluteString == "about:blank"
        {
            allowsAboutBlankNavigation = false
            decisionHandler(.allow)
            return
        }

        if navigationAction.navigationType == .linkActivated,
            let scheme = url.scheme?.lowercased(),
            scheme == "http" || scheme == "https"
        {
            NSWorkspace.shared.open(url)
        }

        decisionHandler(.cancel)
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        injectSavedData()
        setTheme(preferencesManager.theme)
    }

    // The system can kill the web content process under memory pressure
    // (e.g. after the panel sits hidden for hours). Without this, the panel
    // stays blank and the JS bridge is dead until the app is relaunched.
    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        loadWidget()
    }

    func setTheme(_ theme: String) {
        // Update the live page and the document-start script so the next
        // reload paints with the right theme from the first frame.
        rebuildUserScripts(theme: theme)
        webView.evaluateJavaScript(
            "document.documentElement.setAttribute('data-theme', '\(theme)');"
        ) { _, _ in }
    }

    private func injectSavedData() {
        if FileManager.default.fileExists(atPath: dataFilePath),
            let jsonString = try? String(contentsOfFile: dataFilePath, encoding: .utf8)
        {
            webView.callAsyncJavaScript(
                "if (window._onDataLoaded) window._onDataLoaded(JSON.parse(jsonString));",
                arguments: ["jsonString": jsonString],
                in: nil,
                in: .page
            ) { _ in }
        }
    }

    // MARK: - WKScriptMessageHandler

    func userContentController(
        _ userContentController: WKUserContentController,
        didReceive message: WKScriptMessage
    ) {
        guard message.frameInfo.isMainFrame,
            message.frameInfo.securityOrigin.protocol == "file",
            let sourceURL = message.frameInfo.request.url,
            isWidgetURL(sourceURL),
            let body = message.body as? [String: Any],
            let action = body["action"] as? String
        else { return }

        switch action {
        case "copy":
            if let text = body["text"] as? String {
                NSPasteboard.general.clearContents()
                NSPasteboard.general.setString(text, forType: .string)
            }
        case "openURL":
            if let urlString = body["url"] as? String,
                let url = URL(string: urlString)
            {
                NSWorkspace.shared.open(url)
            }
        case "saveData":
            if let jsonString = body["data"] as? String {
                do {
                    try jsonString.write(
                        toFile: dataFilePath, atomically: true, encoding: .utf8)
                    postSaveResult(ok: true, error: "")
                } catch {
                    postSaveResult(ok: false, error: error.localizedDescription)
                }
            } else {
                postSaveResult(ok: false, error: "Invalid save data")
            }
        case "exportData":
            handleExport()
        case "importData":
            handleImport()
        case "runUpdate":
            onRunUpdate?()
        case "runAction":
            if let id = body["id"] as? String, let command = body["command"] as? String {
                let timeout = (body["timeout"] as? Double) ?? 30
                runAction(id: id, command: command, timeout: timeout)
            }
        default:
            break
        }
    }

    private func postSaveResult(ok: Bool, error: String) {
        webView.callAsyncJavaScript(
            "if (window._saveResult) window._saveResult(ok, error);",
            arguments: ["ok": ok, "error": error],
            in: nil,
            in: .page
        ) { _ in }
    }

    // MARK: - runAction

    private func runAction(id: String, command: String, timeout: Double) {
        guard timeout.isFinite else {
            postActionResult(id: id, payload: ["ok": false, "error": "Invalid timeout"])
            return
        }
        let timeout = min(max(timeout, 1), 300)

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let process = Process()
            var environment = ProcessInfo.processInfo.environment
            let shell = environment["SHELL"].flatMap { $0.isEmpty ? nil : $0 } ?? "/bin/zsh"
            let requiredPaths = ["/opt/homebrew/bin", "/usr/local/bin"]
            let existingPaths = (environment["PATH"] ?? "")
                .split(separator: ":")
                .map(String.init)
                .filter { !requiredPaths.contains($0) }
            environment["PATH"] = (requiredPaths + existingPaths).joined(separator: ":")
            process.executableURL = URL(fileURLWithPath: shell)
            // Finder/LaunchServices supplies only a minimal PATH, while setup is split across .zprofile (Homebrew) and .zshrc (nvm), so use an interactive login shell.
            process.arguments = ["-l", "-i", "-c", command]
            process.environment = environment
            let stdoutPipe = Pipe()
            let stderrPipe = Pipe()
            process.standardOutput = stdoutPipe
            process.standardError = stderrPipe

            let executionState = ActionExecutionState()

            do {
                try process.run()
                let timeoutWork = DispatchWorkItem {
                    if executionState.timeOut(process) {
                        DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
                            executionState.killIfRunning(process)
                        }
                    }
                }
                DispatchQueue.global().asyncAfter(deadline: .now() + timeout, execute: timeoutWork)

                // Keep draining after the cap so the child cannot block on a full pipe.
                let stdoutOutput = CappedOutput()
                let stderrOutput = CappedOutput()
                let outputLimit = 1_048_576
                let drainGroup = DispatchGroup()
                drainGroup.enter()
                DispatchQueue.global().async {
                    stdoutOutput.drain(stdoutPipe.fileHandleForReading, limit: outputLimit)
                    drainGroup.leave()
                }
                drainGroup.enter()
                DispatchQueue.global().async {
                    stderrOutput.drain(stderrPipe.fileHandleForReading, limit: outputLimit)
                    drainGroup.leave()
                }

                process.waitUntilExit()
                let timedOut = executionState.finish()
                drainGroup.wait()
                timeoutWork.cancel()

                let stdout = String(data: stdoutOutput.data, encoding: .utf8) ?? ""
                let stderr = String(data: stderrOutput.data, encoding: .utf8) ?? ""
                let trimmed = stdout.trimmingCharacters(in: .whitespacesAndNewlines)

                var payload: [String: Any]
                if timedOut {
                    payload = ["ok": false, "error": "Timed out after \(Int(timeout))s"]
                } else if process.terminationStatus != 0 {
                    let errTrimmed = stderr.trimmingCharacters(in: .whitespacesAndNewlines)
                    let snippet = errTrimmed.isEmpty ? "Exit code \(process.terminationStatus)" : String(errTrimmed.prefix(200))
                    payload = ["ok": false, "error": snippet]
                } else {
                    payload = ["ok": true, "stdout": trimmed]
                }
                if stdoutOutput.wasTruncated {
                    payload["stdoutTruncated"] = true
                }
                if stderrOutput.wasTruncated {
                    payload["stderrTruncated"] = true
                }

                DispatchQueue.main.async { [weak self] in
                    self?.postActionResult(id: id, payload: payload)
                }
            } catch {
                DispatchQueue.main.async { [weak self] in
                    self?.postActionResult(id: id, payload: ["ok": false, "error": error.localizedDescription])
                }
            }
        }
    }

    private func postActionResult(id: String, payload: [String: Any]) {
        guard let data = try? JSONSerialization.data(withJSONObject: payload),
              let jsonStr = String(data: data, encoding: .utf8)
        else { return }
        let escapedId = id.replacingOccurrences(of: "\\", with: "\\\\").replacingOccurrences(of: "'", with: "\\'")
        let js = "if(window._actionResult)window._actionResult('\(escapedId)', \(jsonStr));"
        webView.evaluateJavaScript(js) { _, _ in }
    }

    // MARK: - Import / Export

    private func handleExport() {
        guard FileManager.default.fileExists(atPath: dataFilePath),
            let jsonData = try? Data(contentsOf: URL(fileURLWithPath: dataFilePath))
        else { return }

        let savePanel = NSSavePanel()
        savePanel.nameFieldStringValue = "glancebar-data.json"
        savePanel.allowedContentTypes = [.json]
        savePanel.canCreateDirectories = true
        savePanel.title = "Export GlanceBar Data"

        if savePanel.runModal() == .OK, let url = savePanel.url {
            try? jsonData.write(to: url)
            webView.evaluateJavaScript("showToast('Exported successfully')") { _, _ in }
        }
    }

    private func handleImport() {
        let openPanel = NSOpenPanel()
        openPanel.allowedContentTypes = [.json]
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = false
        openPanel.title = "Import GlanceBar Data"

        guard openPanel.runModal() == .OK, let url = openPanel.url,
            let jsonString = try? String(contentsOf: url, encoding: .utf8)
        else { return }

        // Validate before touching the user's data — a malformed or
        // wrong-shaped file must never wipe data.json.
        guard let object = try? JSONSerialization.jsonObject(with: Data(jsonString.utf8)) as? [String: Any],
            object["pages"] is [Any] || object["cards"] is [Any]
        else {
            showToast("Import failed: not a GlanceBar data file", error: true)
            return
        }

        let alert = NSAlert()
        alert.messageText = "Replace your GlanceBar data?"
        alert.informativeText = "Your current entries will be replaced by the imported file. The existing data is backed up to data.json.bak first."
        alert.addButton(withTitle: "Import")
        alert.addButton(withTitle: "Cancel")
        NSApp.activate(ignoringOtherApps: true)
        guard alert.runModal() == .alertFirstButtonReturn else { return }

        if FileManager.default.fileExists(atPath: dataFilePath) {
            let backupPath = dataFilePath + ".bak"
            do {
                if FileManager.default.fileExists(atPath: backupPath) {
                    try FileManager.default.removeItem(atPath: backupPath)
                }
                try FileManager.default.copyItem(atPath: dataFilePath, toPath: backupPath)
            } catch {
                showToast("Import failed: could not back up existing data: \(error.localizedDescription)", error: true)
                return
            }
        }

        do {
            try jsonString.write(toFile: dataFilePath, atomically: true, encoding: .utf8)
        } catch {
            showToast("Import failed: could not write imported data: \(error.localizedDescription)", error: true)
            return
        }
        // Reload widget to pick up new data
        reload()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.showToast("Imported successfully")
        }
    }

    private func showToast(_ message: String, error: Bool = false) {
        let escaped = message
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "'", with: "\\'")
        let kind = error ? ",'error'" : ""
        webView.evaluateJavaScript("if(window.showToast)showToast('\(escaped)'\(kind));") { _, _ in }
    }
}
