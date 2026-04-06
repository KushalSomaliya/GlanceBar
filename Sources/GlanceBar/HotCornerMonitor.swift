import AppKit

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

    private func handleMouseMoved() {
        let corner = preferencesManager.hotCorner
        guard corner != .disabled else { return }
        guard let screen = NSScreen.main else { return }

        let mouseLocation = NSEvent.mouseLocation
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
