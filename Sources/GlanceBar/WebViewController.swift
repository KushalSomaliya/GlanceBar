import AppKit
import WebKit

class WebViewController: NSObject, WKScriptMessageHandler, WKNavigationDelegate {
    let webView: WKWebView
    private let preferencesManager: PreferencesManager

    private var dataFilePath: String {
        let dir = AppConstants.defaultWidgetDirectory.path
        return "\(dir)/data.json"
    }

    init(preferencesManager: PreferencesManager) {
        self.preferencesManager = preferencesManager

        let userContentController = WKUserContentController()

        let bridgeScript = WKUserScript(
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
        userContentController.addUserScript(bridgeScript)

        let config = WKWebViewConfiguration()
        config.userContentController = userContentController
        config.preferences.setValue(true, forKey: "developerExtrasEnabled")

        webView = WKWebView(frame: .zero, configuration: config)
        webView.setValue(false, forKey: "drawsBackground")
        webView.allowsMagnification = false

        super.init()

        webView.navigationDelegate = self
        userContentController.add(self, name: "glancebar")
    }

    func loadWidget() {
        let filePath = preferencesManager.widgetFilePath
        let fileURL = URL(fileURLWithPath: filePath)
        let accessDirectory = fileURL.deletingLastPathComponent()

        if FileManager.default.fileExists(atPath: filePath) {
            webView.loadFileURL(fileURL, allowingReadAccessTo: accessDirectory)
        } else {
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

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        injectSavedData()
        setTheme(preferencesManager.theme)
    }

    func setTheme(_ theme: String) {
        webView.evaluateJavaScript(
            "document.documentElement.setAttribute('data-theme', '\(theme)');"
        ) { _, _ in }
    }

    private func injectSavedData() {
        if FileManager.default.fileExists(atPath: dataFilePath),
            let jsonString = try? String(contentsOfFile: dataFilePath, encoding: .utf8)
        {
            let escaped = jsonString
                .replacingOccurrences(of: "\\", with: "\\\\")
                .replacingOccurrences(of: "'", with: "\\'")
                .replacingOccurrences(of: "\n", with: "\\n")
            webView.evaluateJavaScript(
                "if(window._onDataLoaded) window._onDataLoaded(JSON.parse('\(escaped)'));"
            ) { _, _ in }
        }
    }

    // MARK: - WKScriptMessageHandler

    func userContentController(
        _ userContentController: WKUserContentController,
        didReceive message: WKScriptMessage
    ) {
        guard let body = message.body as? [String: Any],
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
                try? jsonString.write(
                    toFile: dataFilePath, atomically: true, encoding: .utf8)
            }
        case "exportData":
            handleExport()
        case "importData":
            handleImport()
        case "runUpdate":
            handleUpdate()
        case "runAction":
            if let id = body["id"] as? String, let command = body["command"] as? String {
                let timeout = (body["timeout"] as? Double) ?? 30
                runAction(id: id, command: command, timeout: timeout)
            }
        default:
            break
        }
    }

    // MARK: - runAction

    private func runAction(id: String, command: String, timeout: Double) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/bin/sh")
            process.arguments = ["-c", command]
            let stdoutPipe = Pipe()
            let stderrPipe = Pipe()
            process.standardOutput = stdoutPipe
            process.standardError = stderrPipe

            var timedOut = false
            let timeoutWork = DispatchWorkItem {
                if process.isRunning {
                    timedOut = true
                    process.terminate()
                }
            }
            DispatchQueue.global().asyncAfter(deadline: .now() + timeout, execute: timeoutWork)

            do {
                try process.run()
                process.waitUntilExit()
                timeoutWork.cancel()

                let stdoutData = stdoutPipe.fileHandleForReading.readDataToEndOfFile()
                let stderrData = stderrPipe.fileHandleForReading.readDataToEndOfFile()
                let stdout = String(data: stdoutData, encoding: .utf8) ?? ""
                let stderr = String(data: stderrData, encoding: .utf8) ?? ""
                let trimmed = stdout.trimmingCharacters(in: .whitespacesAndNewlines)

                let payload: [String: Any]
                if timedOut {
                    payload = ["ok": false, "error": "Timed out after \(Int(timeout))s"]
                } else if process.terminationStatus != 0 {
                    let errTrimmed = stderr.trimmingCharacters(in: .whitespacesAndNewlines)
                    let snippet = errTrimmed.isEmpty ? "Exit code \(process.terminationStatus)" : String(errTrimmed.prefix(200))
                    payload = ["ok": false, "error": snippet]
                } else {
                    payload = ["ok": true, "stdout": trimmed]
                }

                DispatchQueue.main.async { [weak self] in
                    self?.postActionResult(id: id, payload: payload)
                }
            } catch {
                timeoutWork.cancel()
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

    private func handleUpdate() {
        let srcDir = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent(".glancebar-src")
        let updateScript = srcDir.appendingPathComponent("update.sh")

        if FileManager.default.fileExists(atPath: updateScript.path) {
            // Run update.sh in background
            let task = Process()
            task.executableURL = URL(fileURLWithPath: "/bin/bash")
            task.arguments = [updateScript.path]
            task.currentDirectoryURL = srcDir
            try? task.run()
        } else {
            // Fallback: open the GitHub releases page
            if let url = URL(string: "https://github.com/\(AppConstants.githubRepo)/releases") {
                NSWorkspace.shared.open(url)
            }
        }
    }

    private func handleImport() {
        let openPanel = NSOpenPanel()
        openPanel.allowedContentTypes = [.json]
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = false
        openPanel.title = "Import GlanceBar Data"

        if openPanel.runModal() == .OK, let url = openPanel.url,
            let jsonString = try? String(contentsOf: url, encoding: .utf8)
        {
            // Write to data file
            try? jsonString.write(toFile: dataFilePath, atomically: true, encoding: .utf8)
            // Reload widget to pick up new data
            reload()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.webView.evaluateJavaScript("showToast('Imported successfully')") {
                    _, _ in
                }
            }
        }
    }
}
