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
                        window.webkit.messageHandlers.glancebar.postMessage({
                            action: 'copy',
                            text: text
                        });
                    },
                    openURL: function(url) {
                        window.webkit.messageHandlers.glancebar.postMessage({
                            action: 'openURL',
                            url: url
                        });
                    },
                    saveData: function(data) {
                        window.webkit.messageHandlers.glancebar.postMessage({
                            action: 'saveData',
                            data: JSON.stringify(data)
                        });
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

    // Inject saved data after page loads
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        injectSavedData()
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
        default:
            break
        }
    }
}
