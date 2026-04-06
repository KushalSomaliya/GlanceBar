import AppKit
import WebKit

class PanelController {
    private let panel: NSPanel
    private let visualEffectView: NSVisualEffectView
    private let webViewController: WebViewController
    private let preferencesManager: PreferencesManager
    private var clickOutsideMonitor: Any?
    private var escapeMonitor: Any?
    private(set) var isVisible = false
    private(set) var isPinnedToDesktop = false

    init(preferencesManager: PreferencesManager) {
        self.preferencesManager = preferencesManager

        panel = GlancePanel(
            contentRect: NSRect(x: 0, y: 0, width: preferencesManager.panelWidth, height: 600),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        panel.isFloatingPanel = true
        panel.level = .floating
        panel.hasShadow = true
        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.hidesOnDeactivate = false
        panel.animationBehavior = .utilityWindow
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]

        visualEffectView = NSVisualEffectView()
        visualEffectView.material = .sidebar
        visualEffectView.blendingMode = .behindWindow
        visualEffectView.state = .active
        visualEffectView.autoresizingMask = [.width, .height]

        panel.contentView = visualEffectView

        webViewController = WebViewController(preferencesManager: preferencesManager)

        let webView = webViewController.webView
        webView.translatesAutoresizingMaskIntoConstraints = false
        visualEffectView.addSubview(webView)

        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: visualEffectView.topAnchor),
            webView.bottomAnchor.constraint(equalTo: visualEffectView.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: visualEffectView.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: visualEffectView.trailingAnchor),
        ])

        webViewController.loadWidget()

        if preferencesManager.isPinnedToDesktop {
            isPinnedToDesktop = true
            applyDesktopPinMode()
            restoreDesktopPosition()
            panel.orderFront(nil)
            isVisible = true
        }
    }

    func toggle() {
        if isPinnedToDesktop {
            if isVisible {
                panel.orderOut(nil)
                isVisible = false
            } else {
                panel.orderFront(nil)
                isVisible = true
            }
            return
        }

        if isVisible {
            slideOut()
        } else {
            slideIn()
        }
    }

    func reloadWebView() {
        webViewController.reload()
    }

    func dismissIfVisible() {
        guard isVisible, !isPinnedToDesktop else { return }
        slideOut()
    }

    // MARK: - Slide Animations

    private func slideIn() {
        guard !isVisible else { return }
        guard let screen = NSScreen.main else { return }

        let screenFrame = screen.frame
        let panelWidth = preferencesManager.panelWidth

        let startFrame = NSRect(
            x: screenFrame.maxX,
            y: screenFrame.origin.y,
            width: panelWidth,
            height: screenFrame.height
        )
        panel.setFrame(startFrame, display: false)
        panel.orderFront(nil)

        let endFrame = NSRect(
            x: screenFrame.maxX - panelWidth,
            y: screenFrame.origin.y,
            width: panelWidth,
            height: screenFrame.height
        )

        NSAnimationContext.runAnimationGroup({ context in
            context.duration = AppConstants.slideAnimationDuration
            context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            panel.animator().setFrame(endFrame, display: true)
        }, completionHandler: { [weak self] in
            self?.isVisible = true
            self?.panel.makeKey()
            self?.installDismissMonitors()
        })
    }

    private func slideOut() {
        guard isVisible else { return }
        guard let screen = NSScreen.main else { return }

        removeDismissMonitors()

        let offScreenFrame = NSRect(
            x: screen.frame.maxX,
            y: panel.frame.origin.y,
            width: panel.frame.width,
            height: panel.frame.height
        )

        NSAnimationContext.runAnimationGroup({ context in
            context.duration = AppConstants.slideAnimationDuration
            context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            panel.animator().setFrame(offScreenFrame, display: true)
        }, completionHandler: { [weak self] in
            self?.panel.orderOut(nil)
            self?.isVisible = false
        })
    }

    // MARK: - Dismiss Monitors

    private func installDismissMonitors() {
        clickOutsideMonitor = NSEvent.addGlobalMonitorForEvents(
            matching: [.leftMouseDown, .rightMouseDown]
        ) { [weak self] _ in
            guard let self, self.isVisible, !self.isPinnedToDesktop else { return }
            let mouseLocation = NSEvent.mouseLocation
            if !self.panel.frame.contains(mouseLocation) {
                self.slideOut()
            }
        }

        escapeMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            if event.keyCode == 53 {
                self?.slideOut()
                return nil
            }
            return event
        }
    }

    private func removeDismissMonitors() {
        if let monitor = clickOutsideMonitor {
            NSEvent.removeMonitor(monitor)
            clickOutsideMonitor = nil
        }
        if let monitor = escapeMonitor {
            NSEvent.removeMonitor(monitor)
            escapeMonitor = nil
        }
    }

    // MARK: - Desktop Pin Mode

    func toggleDesktopPin() {
        if isPinnedToDesktop {
            unpinFromDesktop()
        } else {
            pinToDesktop()
        }
    }

    private func pinToDesktop() {
        isPinnedToDesktop = true
        preferencesManager.isPinnedToDesktop = true
        removeDismissMonitors()
        applyDesktopPinMode()

        if !isVisible {
            guard let screen = NSScreen.main else { return }
            let visibleFrame = screen.visibleFrame
            let panelWidth = preferencesManager.panelWidth
            let frame = NSRect(
                x: screen.frame.maxX - panelWidth - 20,
                y: visibleFrame.origin.y + 20,
                width: panelWidth,
                height: visibleFrame.height - 40
            )
            panel.setFrame(frame, display: true)
            panel.orderFront(nil)
            isVisible = true
        }
    }

    private func unpinFromDesktop() {
        saveDesktopPosition()
        isPinnedToDesktop = false
        preferencesManager.isPinnedToDesktop = false

        panel.level = .floating
        panel.isMovableByWindowBackground = false
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]

        slideOut()
    }

    private func applyDesktopPinMode() {
        panel.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.desktopIconWindow)))
        panel.isMovableByWindowBackground = true
        panel.collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle]
    }

    private func saveDesktopPosition() {
        preferencesManager.desktopPanelX = panel.frame.origin.x
        preferencesManager.desktopPanelY = panel.frame.origin.y
    }

    private func restoreDesktopPosition() {
        let x = preferencesManager.desktopPanelX
        let y = preferencesManager.desktopPanelY
        if x != 0 || y != 0 {
            panel.setFrameOrigin(NSPoint(x: x, y: y))
        }
    }
}
