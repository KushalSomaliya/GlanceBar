# GlanceBar

A lightweight macOS menu bar app that provides a custom widget sidebar panel with hot corner and global hotkey activation. Think "Quick Note meets Notification Center" but fully customizable via HTML/CSS/JS.

## Development Workflow

**IMPORTANT: Always follow this sequence when making changes:**

1. `pkill -f GlanceBar || true` — kill the running app first
2. Make your code edits
3. `rm -f ~/.glancebar/index.html` — only if DefaultWidget.swift changed (forces regeneration)
4. **NEVER delete `~/.glancebar/data.json`** — this is the user's actual data.
5. `swift build -c release` — compile
6. `bash build.sh` — assemble .app bundle
7. `open GlanceBar.app` — launch

## Architecture

- **Build system**: Swift Package Manager (no Xcode.app required, just Swift CLI tools)
- **Language**: Swift 5.9+, targeting macOS 14+ (Sonoma)
- **App lifecycle**: AppDelegate-based (not SwiftUI App) — needed for NSPanel, NSStatusItem, Carbon hotkeys
- **Widget rendering**: WKWebView loading a local HTML file (`~/.glancebar/index.html`)
- **Data persistence**: Widget data stored in `~/.glancebar/data.json`, managed via JS bridge
- **Data format**: `{ pages: [{ id, name, cards: [{ id, title, hideValues, sections: [{ id, title, items, sections }] }] }] }`
- **Theme**: CSS variables with `@media (prefers-color-scheme)` + explicit `data-theme` attribute override
- **Global hotkey**: Carbon `RegisterEventHotKey` with `GetEventDispatcherTarget()` (no Accessibility permissions needed)

## Key Files

| File                                            | Purpose                                                                                       |
| ----------------------------------------------- | --------------------------------------------------------------------------------------------- |
| `Sources/GlanceBar/main.swift`                  | NSApplication bootstrap entry point                                                           |
| `Sources/GlanceBar/AppDelegate.swift`           | Central orchestrator — wires all controllers together                                         |
| `Sources/GlanceBar/GlancePanel.swift`           | NSPanel subclass with `canBecomeKey = true` (needed for input focus and paste)                |
| `Sources/GlanceBar/PanelController.swift`       | Panel lifecycle, slide animations, dismiss monitors, desktop pin mode, theme                  |
| `Sources/GlanceBar/WebViewController.swift`     | WKWebView setup, JS bridge (clipboard, data save/load, import/export), transparent background |
| `Sources/GlanceBar/FileWatcher.swift`           | DispatchSource file monitoring with atomic-save handling (vim, VS Code)                       |
| `Sources/GlanceBar/HotCornerMonitor.swift`      | Mouse position tracking, corner detection state machine with debounce                         |
| `Sources/GlanceBar/GlobalShortcutManager.swift` | Carbon RegisterEventHotKey global hotkey (default: Cmd+])                                     |
| `Sources/GlanceBar/StatusBarController.swift`   | Menu bar icon + right-click context menu                                                      |
| `Sources/GlanceBar/PreferencesManager.swift`    | UserDefaults wrapper for all app settings                                                     |
| `Sources/GlanceBar/PreferencesWindow.swift`     | SwiftUI preferences UI with theme picker, shortcut recorder, hot corner selector              |
| `Sources/GlanceBar/DefaultWidget.swift`         | Default HTML/CSS/JS widget template (embedded as Swift string literal)                        |
| `Sources/GlanceBar/LaunchAtLoginManager.swift`  | SMAppService login item management                                                            |
| `Sources/GlanceBar/DesktopPinManager.swift`     | Desktop window level constants                                                                |
| `Sources/GlanceBar/Constants.swift`             | App-wide constants and ScreenCorner enum                                                      |

## Key Technical Decisions & Lessons Learned

### Global Hotkey (Carbon API)

- **MUST use `GetEventDispatcherTarget()`** — NOT `GetApplicationEventTarget()`. The latter requires Accessibility permissions; the former does not.
- Carbon `RegisterEventHotKey` is the only macOS API for global hotkeys that works without ANY permissions.
- This is what Alfred, Raycast, and Hammerspoon use.
- `NSEvent.addGlobalMonitorForEvents(.keyDown)` silently fails without Accessibility permission.
- `CGEvent.tapCreate` requires Accessibility permission AND breaks with ad-hoc code signing (each rebuild invalidates the TCC grant).
- See `~/.claude/docs/macos-global-hotkeys.md` for the full cross-language reference.

### NSPanel & Input Focus

- `.nonactivatingPanel` style doesn't steal focus from the current app, but also blocks keyboard input in WKWebView.
- Fix: `GlancePanel` subclass with `canBecomeKey = true`, and call `panel.makeKey()` after slide-in animation.
- `GlancePanel` also overrides `keyDown` to forward Cmd+V/C/X/A to the WKWebView's first responder (paste/copy/cut/select all).

### Escape Key Handling (Two Layers)

- Swift side: PanelController's local event monitor catches Escape. Before dismissing the panel, it checks via JS if an input/textarea is focused.
- If an input is focused: Swift calls `window._escCancel=true;cancelEdit()` in JS — cancels the edit without saving, panel stays open.
- If nothing is focused: Swift dismisses the panel.
- The `_escCancel` flag prevents the blur handler from auto-saving when Escape is pressed.

### WKWebView Transparency

- `setValue(false, forKey: "drawsBackground")` is a private API but stable for years.
- The HTML `body` must also have `background: transparent`.
- `NSVisualEffectView` with `.underWindowBackground` material sits behind the WKWebView for native blur.

### Panel Background (Dark Mode)

- In dark mode, `panel.backgroundColor` is set to `NSColor(white: 0.1, alpha: 1.0)` to prevent the light system blur from showing through below the cards.
- The `NSVisualEffectView` appearance is forced to `.darkAqua` or `.aqua` based on the theme preference.

### File Watching

- Uses `DispatchSource.makeFileSystemObjectSource` with `O_EVTONLY`.
- Handles atomic saves (vim, VS Code write to temp file then rename) by detecting `.delete`/`.rename` events and re-establishing the watch after 0.5s delay.
- Debounces reload by 0.3s to batch rapid saves.

### Data Migration

- Old format `{ cards: [...] }` is auto-migrated to new format `{ pages: [{ name: "Main", cards: [...] }] }` on load.
- The `_onDataLoaded` JS callback handles this transparently.

### JavaScript Dialogs

- `prompt()`, `confirm()`, and `alert()` are BLOCKED in WKWebView. Never use them.
- All dialogs must be implemented as inline HTML elements (forms, confirmation overlays).

### Code Signing & Accessibility

- Ad-hoc signing (`codesign --sign -`) creates a new identity on every rebuild, invalidating TCC Accessibility grants.
- Carbon RegisterEventHotKey avoids this issue entirely (no permissions needed).
- Hot corner mouse tracking (`NSEvent.addGlobalMonitorForEvents(.mouseMoved)`) still needs Accessibility permission. If hot corner doesn't work, toggle GlanceBar off/on in System Settings > Accessibility.

## JS Bridge API

The widget HTML can call these via `window.GlanceBar`:

- `GlanceBar.copy(text)` — copy text to system clipboard via NSPasteboard
- `GlanceBar.saveData(data)` — persist JSON data to `~/.glancebar/data.json`
- `GlanceBar.openURL(url)` — open URL in default browser
- `GlanceBar.exportData()` — opens native NSSavePanel to export data.json
- `GlanceBar.importData()` — opens native NSOpenPanel to import a JSON file

On page load, Swift injects saved data via `window._onDataLoaded(data)`.

## Widget Features

- **Multi-page tabs** — centered tab bar, click to switch, right-click to rename/delete, + to add
- **Cards** with sections and nested subsections (unlimited depth)
- **Click-to-copy** with green "Copied" feedback
- **Hide values toggle** per card — shows dots, hover to reveal, persisted in data.json
- **Inline editing** — right-click entry to edit, right-click section header to rename
- **Selection mode** — select entries/sections, bulk delete with confirmation
- **Drag to reorder** entries within a section via grip handle
- **Add entry** via + button, **add subsection** via dropdown arrow
- **Import/export** — tiny links at bottom, native file dialogs
- **Light/dark/auto theme** — CSS variables, follows macOS or manual override
- **Animations** — fadeSlideIn, scaleIn on cards, forms, context menus
- **No buttons on forms** — Enter saves, Escape cancels, click-outside auto-saves

## Widget Customization

Edit `~/.glancebar/index.html` in any text editor. The app watches the file and live-reloads on save.

Data is stored separately in `~/.glancebar/data.json` and survives widget file changes.

## Persisted Settings (UserDefaults)

- `hotCorner` — which screen corner triggers the panel (default: bottomRight)
- `panelWidth` — sidebar width in pixels (default: 380)
- `widgetFilePath` — path to the widget HTML file
- `launchAtLogin` — boolean
- `isPinnedToDesktop` — boolean
- `desktopPanelX/Y` — saved desktop position
- `theme` — "auto", "dark", or "light"
- `shortcutKey` — the key character for global hotkey (default: "]")
- `shortcutModifiers` — NSEvent.ModifierFlags raw value (default: Command)
