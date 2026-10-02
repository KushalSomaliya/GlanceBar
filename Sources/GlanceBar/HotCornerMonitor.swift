import AppKit
import ApplicationServices

class HotCornerMonitor {
    private let preferencesManager: PreferencesManager
    private let onTrigger: () -> Void
    private var eventMonitor: Any?
    private var pendingActivation: DispatchWorkItem?
    private var hasTriggered = false

    private enum State {
        case idle
        case waiting
        case cooldown
    }
    private var state: State = .idle

    init(preferencesManager: PreferencesManager, onTrigger: @escaping () -> Void) {
        self.preferencesManager = preferencesManager
        self.onTrigger = onTrigger
    }

    func start() {
        requestAccessibilityIfNeeded()
        eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: .mouseMoved) {
            [weak self] _ in
            self?.handleMouseMoved()
        }
    }

    func stop() {
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
            eventMonitor = nil
        }
        pendingActivation?.cancel()
        pendingActivation = nil
    }

    /// Global mouse monitoring silently does nothing without the Accessibility
    /// permission, and the grant is tied to bundle ID + signing identity, so a
    /// rotation or a signing change loses it. Ask macOS to show its own prompt
    /// once per build while not trusted: it adds the app to System Settings →
    /// Privacy & Security → Accessibility and offers a button that opens that
    /// pane, which is much easier than finding it by hand. With a stable
    /// signing identity the grant survives rebuilds, so this fires once.
    private func requestAccessibilityIfNeeded() {
        guard preferencesManager.hotCorner != .disabled else { return }
        guard !AXIsProcessTrusted() else { return }
        let build = AppConstants.buildCommit ?? AppConstants.version
        guard preferencesManager.accessibilityPromptedBuild != build else { return }
        preferencesManager.accessibilityPromptedBuild = build
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
        _ = AXIsProcessTrustedWithOptions(options)
    }

    private func handleMouseMoved() {
        let corner = preferencesManager.hotCorner
        guard corner != .disabled else { return }

        let mouseLocation = NSEvent.mouseLocation
        // Check the corner of the display the cursor is actually on —
        // NSScreen.main is the menu-bar/key-window screen, so using it would
        // make hot corners dead on every secondary display.
        guard let screen = NSScreen.screens.first(where: { NSMouseInRect(mouseLocation, $0.frame, false) })
            ?? NSScreen.main
        else { return }
        let screenFrame = screen.frame
        let regionSize = AppConstants.cornerRegionSize

        let isInCorner = isMouseInCorner(
            mouseLocation: mouseLocation,
            screenFrame: screenFrame,
            corner: corner,
            regionSize: regionSize
        )

        switch state {
        case .idle:
            if isInCorner {
                state = .waiting
                let item = DispatchWorkItem { [weak self] in
                    guard let self, self.state == .waiting else { return }
                    self.state = .cooldown
                    self.onTrigger()
                }
                pendingActivation = item
                DispatchQueue.main.asyncAfter(
                    deadline: .now() + AppConstants.cornerActivationDelay,
                    execute: item
                )
            }

        case .waiting:
            if !isInCorner {
                pendingActivation?.cancel()
                pendingActivation = nil
                state = .idle
            }

        case .cooldown:
            if !isInCorner {
                state = .idle
            }
        }
    }

    private func isMouseInCorner(
        mouseLocation: NSPoint,
        screenFrame: NSRect,
        corner: ScreenCorner,
        regionSize: CGFloat
    ) -> Bool {
        let x = mouseLocation.x
        let y = mouseLocation.y
        let maxX = screenFrame.maxX
        let maxY = screenFrame.maxY
        let minX = screenFrame.minX
        let minY = screenFrame.minY

        switch corner {
        case .topLeft:
            return x <= minX + regionSize && y >= maxY - regionSize
        case .topRight:
            return x >= maxX - regionSize && y >= maxY - regionSize
        case .bottomLeft:
            return x <= minX + regionSize && y <= minY + regionSize
        case .bottomRight:
            return x >= maxX - regionSize && y <= minY + regionSize
        case .disabled:
            return false
        }
    }
}
