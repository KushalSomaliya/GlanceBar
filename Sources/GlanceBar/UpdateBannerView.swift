import AppKit

/// Native update banner pinned to the top of the panel. It lives outside the
/// WKWebView so it works with ANY widget HTML — including user-customized
/// files and stale app-generated ones that predate the old in-page banner.
final class UpdateBannerView: NSView {
    var onUpdate: (() -> Void)?
    var onDismiss: (() -> Void)?

    private let label = NSTextField(labelWithString: "")
    private let actionButton = NSButton(title: "Update", target: nil, action: nil)
    private let closeButton = NSButton(title: "\u{2715}", target: nil, action: nil)
    private let spinner = NSProgressIndicator()
    private var autoHideTimer: Timer?

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)

        wantsLayer = true
        layer?.cornerRadius = 10
        layer?.borderWidth = 1
        shadow = NSShadow()
        layer?.shadowOpacity = 0.25
        layer?.shadowRadius = 8
        layer?.shadowOffset = CGSize(width: 0, height: -2)

        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.lineBreakMode = .byTruncatingTail
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        actionButton.bezelStyle = .rounded
        actionButton.controlSize = .small
        actionButton.font = .systemFont(ofSize: 11, weight: .semibold)
        actionButton.target = self
        actionButton.action = #selector(updateClicked)
        actionButton.translatesAutoresizingMaskIntoConstraints = false

        closeButton.isBordered = false
        closeButton.font = .systemFont(ofSize: 10, weight: .bold)
        closeButton.target = self
        closeButton.action = #selector(dismissClicked)
        closeButton.translatesAutoresizingMaskIntoConstraints = false

        spinner.style = .spinning
        spinner.controlSize = .small
        spinner.isDisplayedWhenStopped = false
        spinner.translatesAutoresizingMaskIntoConstraints = false

        addSubview(label)
        addSubview(actionButton)
        addSubview(closeButton)
        addSubview(spinner)

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            label.centerYAnchor.constraint(equalTo: centerYAnchor),
            label.trailingAnchor.constraint(lessThanOrEqualTo: actionButton.leadingAnchor, constant: -8),
            spinner.trailingAnchor.constraint(equalTo: closeButton.leadingAnchor, constant: -8),
            spinner.centerYAnchor.constraint(equalTo: centerYAnchor),
            actionButton.trailingAnchor.constraint(equalTo: closeButton.leadingAnchor, constant: -8),
            actionButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            closeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            closeButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            closeButton.widthAnchor.constraint(equalToConstant: 18),
        ])

        isHidden = true
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override var wantsUpdateLayer: Bool { true }

    override func updateLayer() {
        let isDark = effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
        if isDark {
            layer?.backgroundColor = NSColor(white: 0.17, alpha: 0.98).cgColor
            layer?.borderColor = NSColor(white: 1.0, alpha: 0.12).cgColor
            label.textColor = NSColor(white: 0.95, alpha: 1.0)
        } else {
            layer?.backgroundColor = NSColor(white: 0.99, alpha: 0.98).cgColor
            layer?.borderColor = NSColor(white: 0.0, alpha: 0.10).cgColor
            label.textColor = NSColor(white: 0.15, alpha: 1.0)
        }
        closeButton.contentTintColor = isDark ? NSColor(white: 0.7, alpha: 1) : NSColor(white: 0.45, alpha: 1)
    }

    // MARK: - States

    func showUpdateAvailable(_ text: String) {
        present(text: text, buttonTitle: "Update", showsClose: true, spinning: false)
    }

    func showProgress(_ text: String) {
        present(text: text, buttonTitle: nil, showsClose: false, spinning: true)
    }

    func showError(_ text: String) {
        present(text: text, buttonTitle: "Retry", showsClose: true, spinning: false)
    }

    /// Info message that auto-hides ("You're up to date", check failures).
    func showTransient(_ text: String) {
        present(text: text, buttonTitle: nil, showsClose: true, spinning: false)
        autoHideTimer = Timer.scheduledTimer(withTimeInterval: 3.5, repeats: false) { [weak self] _ in
            self?.hide()
        }
    }

    func hide() {
        autoHideTimer?.invalidate()
        autoHideTimer = nil
        isHidden = true
    }

    private func present(text: String, buttonTitle: String?, showsClose: Bool, spinning: Bool) {
        autoHideTimer?.invalidate()
        autoHideTimer = nil
        label.stringValue = text
        label.toolTip = text
        if let buttonTitle {
            actionButton.title = buttonTitle
            actionButton.isHidden = false
        } else {
            actionButton.isHidden = true
        }
        closeButton.isHidden = !showsClose
        if spinning { spinner.startAnimation(nil) } else { spinner.stopAnimation(nil) }
        needsDisplay = true
        guard isHidden else { return }
        isHidden = false
        alphaValue = 0
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.2
            animator().alphaValue = 1
        }
    }

    @objc private func updateClicked() { onUpdate?() }

    @objc private func dismissClicked() {
        hide()
        onDismiss?()
    }
}
