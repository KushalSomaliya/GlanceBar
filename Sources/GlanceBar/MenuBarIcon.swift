import AppKit

/// The menu bar glyph: GlanceBar's "handle" mark — a pill at the screen edge
/// with a chevron pointing into it, the same mark as the app icon.
///
/// It is drawn in code rather than loaded from a file because the bundle is
/// assembled by build.sh, not by Xcode: there is no asset catalog, and
/// `NSImage(named:)` would need an @1x/@2x pair copied into Resources. A
/// drawing handler is re-run at whatever scale the menu bar needs, so it stays
/// crisp on every display. It is a template image: macOS tints it for light and
/// dark menu bars and for the pressed state, so it is drawn in black only.
enum MenuBarIcon {
    /// 18 × 18 pt, the standard glyph size for a status item in the 22 pt bar.
    static let size = NSSize(width: 18, height: 18)

    static func image() -> NSImage {
        let image = NSImage(size: size, flipped: true) { _ in
            NSColor.black.setFill()
            NSColor.black.setStroke()

            // The handle: a 4.5 pt pill at the right edge.
            let pill = NSBezierPath(
                roundedRect: NSRect(x: 10.75, y: 3, width: 4.5, height: 12),
                xRadius: 2.25,
                yRadius: 2.25
            )
            pill.fill()

            // The chevron pointing at it.
            let chevron = NSBezierPath()
            chevron.move(to: NSPoint(x: 7.5, y: 6))
            chevron.line(to: NSPoint(x: 4.5, y: 9))
            chevron.line(to: NSPoint(x: 7.5, y: 12))
            chevron.lineWidth = 2
            chevron.lineCapStyle = .round
            chevron.lineJoinStyle = .round
            chevron.stroke()
            return true
        }
        image.isTemplate = true
        image.accessibilityDescription = "GlanceBar"
        return image
    }
}
