# GlanceBar

A lightweight macOS menu bar app that provides a custom widget sidebar panel with hot corner activation. Think "Quick Note meets Notification Center" but fully customizable via HTML/CSS/JS.

## Architecture

- **Build system**: Swift Package Manager (no Xcode.app required, just CLI tools)
- **Language**: Swift 5.9+, targeting macOS 14+ (Sonoma)
- **App lifecycle**: AppDelegate-based (not SwiftUI App) — needed for NSPanel, NSStatusItem, global event monitors
- **Widget rendering**: WKWebView loading a local HTML file (`~/.glancebar/index.html`)
- **Data persistence**: Widget data stored in `~/.glancebar/data.json`, managed via JS bridge

## Key Files

| File | Purpose |
|---|---|
| `Sources/GlanceBar/main.swift` | NSApplication bootstrap entry point |
| `Sources/GlanceBar/AppDelegate.swift` | Central orchestrator — wires all controllers together |
| `Sources/GlanceBar/GlancePanel.swift` | NSPanel subclass with `canBecomeKey = true` (needed for input focus) |
| `Sources/GlanceBar/PanelController.swift` | Panel lifecycle, slide animations, dismiss monitors, desktop pin mode |
| `Sources/GlanceBar/WebViewController.swift` | WKWebView setup, JS bridge (clipboard, data save/load), transparent background |
| `Sources/GlanceBar/FileWatcher.swift` | DispatchSource file monitoring with atomic-save handling (vim, VS Code) |
| `Sources/GlanceBar/HotCornerMonitor.swift` | Mouse position tracking, corner detection state machine with debounce |
| `Sources/GlanceBar/GlobalShortcutManager.swift` | Global keyboard shortcut (currently disabled) |
| `Sources/GlanceBar/StatusBarController.swift` | Menu bar icon + right-click context menu |
| `Sources/GlanceBar/PreferencesManager.swift` | UserDefaults wrapper for app settings |
| `Sources/GlanceBar/PreferencesWindow.swift` | SwiftUI preferences UI |
| `Sources/GlanceBar/DefaultWidget.swift` | Default HTML/CSS/JS widget template (embedded as string) |
| `Sources/GlanceBar/LaunchAtLoginManager.swift` | SMAppService login item management |
| `Sources/GlanceBar/DesktopPinManager.swift` | Desktop window level constants |
| `Sources/GlanceBar/Constants.swift` | App-wide constants and ScreenCorner enum |

## Build & Run

```bash
# Build
swift build -c release

# Build .app bundle
./build.sh

# Run
open GlanceBar.app

# Install to /Applications
cp -r GlanceBar.app /Applications/
```

## JS Bridge API

The widget HTML can call these via `window.GlanceBar`:

- `GlanceBar.copy(text)` — copy text to system clipboard
- `GlanceBar.saveData(data)` — persist JSON data to `~/.glancebar/data.json`
- `GlanceBar.openURL(url)` — open URL in default browser

On page load, Swift injects saved data via `window._onDataLoaded(data)`.

## Widget Customization

Edit `~/.glancebar/index.html` in any text editor. The app watches the file and live-reloads on save. The widget has full CSS/JS capabilities including hover effects, transitions, backdrop-filter, etc.

Data is stored separately in `~/.glancebar/data.json` and survives widget file changes.

## Important Notes

- `NSPanel` uses `.nonactivatingPanel` style — doesn't steal focus from the current app
- `GlancePanel` subclass overrides `canBecomeKey` to allow text input in WKWebView
- `setValue(false, forKey: "drawsBackground")` on WKWebView is a private API for transparency — stable but not public
- Hot corner detection requires the app (or Terminal) to have Accessibility permission
- `LSUIElement = true` in Info.plist hides the app from the Dock
- Atomic saves (vim, VS Code) are handled by re-establishing the DispatchSource on rename/delete events
- Panel auto-closes on desktop/space switch via `NSWorkspace.activeSpaceDidChangeNotification`
