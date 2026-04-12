import AppKit

class GlancePanel: NSPanel {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { false }

    var onPreferencesShortcut: (() -> Void)?

    // Forward standard edit commands (Cmd+V, Cmd+C, Cmd+X, Cmd+A)
    // to the WKWebView's first responder, since nonactivatingPanel
    // doesn't route these through the normal responder chain.
    override func keyDown(with event: NSEvent) {
        let flags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
        if flags == .command, let chars = event.charactersIgnoringModifiers {
            switch chars {
            case ",":
                onPreferencesShortcut?()
                return
            case "v":
                if let responder = firstResponder {
                    responder.doCommand(by: #selector(NSText.paste(_:)))
                    return
                }
            case "c":
                if let responder = firstResponder {
                    responder.doCommand(by: #selector(NSText.copy(_:)))
                    return
                }
            case "x":
                if let responder = firstResponder {
                    responder.doCommand(by: #selector(NSText.cut(_:)))
                    return
                }
            case "a":
                if let responder = firstResponder {
                    responder.doCommand(by: #selector(NSText.selectAll(_:)))
                    return
                }
            default:
                break
            }
        }
        super.keyDown(with: event)
    }
}
