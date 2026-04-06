import AppKit

// Desktop pin logic is integrated into PanelController.
// This file exists as a namespace for related utilities if needed in the future.

enum DesktopPinManager {
    static let desktopWindowLevel = NSWindow.Level(
        rawValue: Int(CGWindowLevelForKey(.desktopIconWindow))
    )
}
