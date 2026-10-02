# GlanceBar

A lightweight macOS menu bar app that provides a custom widget sidebar panel with hot corner and global hotkey activation. Think "Quick Note meets Notification Center" but fully customizable via HTML/CSS/JS.

## Known Issues

- **Invisible menu bar icon on macOS Tahoe** — after many rebuild cycles, the icon may disappear even though the app runs and Cmd+] works. Full troubleshooting guide: [`docs/troubleshooting-invisible-icon.md`](docs/troubleshooting-invisible-icon.md). TL;DR: change `CFBundleIdentifier` (rotated three times so far; current ID `glancebar`, previous IDs live in `AppConstants.legacyBundleIdentifiers`, and the app migrates UserDefaults + the login item itself on first launch under a new ID).
- **"Running but broken" (copy works, scripts fail, odd strip above the search bar), usually after a reboot or a Spotlight/Raycast launch** — a stale duplicate `GlanceBar.app` is being launched instead of the one the `glancebar` alias opens. Guide: [`docs/troubleshooting-stale-copy.md`](docs/troubleshooting-stale-copy.md). The app now flags duplicates in the native banner (Trash/Open) and the status menu shows "Running from …".

## Development Workflow

**IMPORTANT: Always follow this sequence when making changes:**

1. Make your code edits
2. `rm -f ~/.glancebar/index.html` — only if DefaultWidget.swift changed (forces regeneration)
3. **NEVER delete `~/.glancebar/data.json`** — this is the user's actual data.
4. `bash build.sh --install` — compiles, assembles the bundle, quits the running app, replaces `/Applications/GlanceBar.app` (previous build goes to the Trash), re-signs it there, registers it with Launch Services, deletes the checkout bundle, and launches the installed copy.

`bash build.sh` without `--install` only compiles and assembles `./GlanceBar.app` for a build check; **never `open` that checkout bundle** — see the rules below. `swift build -c release` alone is fine for a quick compile check.

### Rules that keep "stale duplicate copy" and "invisible icon" from coming back

These two problems (Oct 2026) came from the same habit: launching checkout builds while an older copy sat in `/Applications`, each ad-hoc signed differently, all sharing one bundle ID.

- **Exactly one bundle, at `/Applications/GlanceBar.app`.** Never `open GlanceBar.app` from the checkout, never `cp` a copy to `~/Applications`, Desktop, etc. Spotlight, Raycast and Login Items resolve "GlanceBar" through Launch Services and launch whichever copy they find; a stale one runs old code (pre-1.1.5: scripts fail with the launchd PATH), shows an out-of-date banner and rewrites the default widget to its template. `build.sh --install` deletes the checkout bundle after installing for exactly this reason. If the panel shows a "Stale copy …" or "Newer copy …" banner, act on it; `install.sh`/`update.sh` also print every other copy they find.
- **Sign with a stable identity, not ad hoc.** `codesign --sign -` produces a new identity every build, so TCC (Accessibility for the hot corner) and Tahoe's per-app menu bar permission treat each rebuild as a new app; that churn is what eventually parked the icon off-screen. One-time setup: in Keychain Access select the **login** keychain, then use the **Keychain Access menu in the menu bar** (next to the Apple logo) → Certificate Assistant → Create a Certificate… — not the pencil toolbar button, which only creates a password item. Name `GlanceBar`, Identity Type `Self-Signed Root`, Certificate Type `Code Signing`, leave "Let me override defaults" off → Create → Done. It appears under My Certificates. `build.sh`, `install.sh` and `update.sh` use it automatically whenever `security find-identity -v -p codesigning` lists it; if it is not listed or `codesign` complains, double-click the certificate → Trust → Code Signing: Always Trust. A terminal-only alternative is in `docs/troubleshooting-invisible-icon.md`. `GLANCEBAR_SIGN_IDENTITY=<name>` picks another identity, `GLANCEBAR_SIGN_IDENTITY=-` forces ad hoc. Verify: `codesign -dv /Applications/GlanceBar.app 2>&1 | grep -E 'Authority|TeamIdentifier'`.
- **Permissions after a signing or bundle-ID change** (both happened on 2026-10-02, this is what was learned):
  - *Accessibility (hot corner).* The grant is tied to bundle ID + signing identity, so it is lost after either changes. The app now asks macOS to show its own prompt on launch whenever the hot corner is enabled but not trusted, once per build (`HotCornerMonitor.requestAccessibilityIfNeeded()`, `accessibilityPromptedBuild`); approve it, or use its "Open System Settings" button. The pane is **System Settings → Privacy & Security → Accessibility** (scroll down inside Privacy & Security; the top-level "Accessibility" pane is for assistive features and is NOT it). Shortcut: `open "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility"`. Remove greyed-out old GlanceBar rows there.
  - *Login Items.* Every bundle ID rotation leaves a ghost "GlanceBar" row in System Settings → General → Login Items & Extensions → Open at Login, and System Settings selects same-named rows together. Select them, press "−" until none remain, then turn **Launch at Login off and on in GlanceBar's Preferences** so the live copy registers itself through `SMAppService`. Do not use the "+" button there: that creates a plain login item the app's own toggle cannot see. Launch at Login and all preferences migrate automatically after a rotation (the app re-registers once when it migrated a `launchAtLogin = true` setting), which is where one of the ghost rows came from.
- **Rotating the bundle ID is the last resort** for a hidden icon (`docs/troubleshooting-invisible-icon.md` has the recipe and log). Not a dev-loop step.
- `pkill -f GlanceBar || true` still stops a running instance by hand when needed.

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
| `Sources/GlanceBar/WidgetTemplate.swift`        | Regenerates `~/.glancebar/index.html` after updates when it's an unmodified default (hash-gated) |
| `Sources/GlanceBar/UpdateChecker.swift`         | Update detection: build-commit vs origin/main via GitHub compare API (tag fallback)           |
| `Sources/GlanceBar/UpdateManager.swift`         | Runs `~/.glancebar-src/update.sh` (bootstrap-clones if missing), streams progress             |
| `Sources/GlanceBar/UpdateBannerView.swift`      | Native AppKit update banner at the top of the panel (independent of widget HTML)              |
| `Sources/GlanceBar/LaunchAtLoginManager.swift`  | SMAppService login item management                                                            |
| `Sources/GlanceBar/DesktopPinManager.swift`     | Desktop window level constants                                                                |
| `Sources/GlanceBar/Constants.swift`             | App-wide constants, ScreenCorner enum, build-commit stamp accessor                            |

## Key Technical Decisions & Lessons Learned

### Update System (v1.1.3 redesign)

- **Source of truth is the git commit, not tags/version strings.** `build.sh` stamps `GlanceBarBuildCommit` (HEAD sha) into the bundle's Info.plist; `UpdateChecker` compares it against `origin/main` via the GitHub compare API (`ahead`/`diverged` ⇒ update, `identical`/`behind` ⇒ current, HTTP 404 ⇒ unpushed dev build ⇒ stay silent). Unstamped pre-1.1.3 binaries fall back to semver-sorted tags vs `AppConstants.version`.
- **The update banner is native AppKit** (`UpdateBannerView` in the panel), NOT widget HTML. The old in-page banner silently no-oped for users whose `~/.glancebar/index.html` predated it — that file is generated once and user-editable, so UI the app depends on must never live there.
- **`update.sh` must build BEFORE killing the app.** The app streams the script's stdout through a pipe; once the app dies, the next `echo` gets SIGPIPE and kills the script mid-update (this is how the old updater left repos pulled but apps stale). The script also `exec >/dev/null 2>&1` right before `pkill` when app-spawned, and is wrapped in `main()` so bash parses the whole file before `git pull` replaces it on disk.
- **`update.sh` gates on BOTH the checkout sha AND the installed app's stamp** — a current checkout with a stale installed app rebuilds instead of reporting "already up to date".
- **Widget HTML refresh is hash-gated** (`WidgetTemplate`): the file is only regenerated when its SHA-256 matches the sidecar (`~/.glancebar/.default-widget-sha256`) or a known historical default hash; a backup (`index.html.bak`) is written first. User-customized files are never touched.
- **Single-instance guard**: `AppDelegate.terminateOlderInstances()` kills earlier-launched GlanceBar instances (both bundle IDs) — a stale copy owning the panel with a newer HTML file was the main cause of "Bridge unavailable" errors.
- The widget JS also self-heals: if `window.GlanceBar` is missing/incomplete, it rebuilds the bridge on `webkit.messageHandlers.glancebar`, and action calls have a watchdog timeout instead of hanging forever.

### Duplicate Installs & Banner Placement

- **Several `GlanceBar.app` bundles = nondeterministic launches.** The `glancebar` alias opens one path; Spotlight, Raycast and Login Items resolve through Launch Services and may pick another (older) copy, which then kills the newer-launched instance via the single-instance guard. Pre-1.1.5 copies also ran actions with the launchd PATH, so scripts only worked when the app was started from a terminal (`open` passes the terminal's environment). `AppDelegate.checkForDuplicateInstalls()` queries `NSWorkspace.urlsForApplications(withBundleIdentifier:)` for every current and legacy bundle ID, ignores copies built from the same commit, and shows a native banner notice (Trash, or Open when the other copy is newer). Dismissals are remembered per copy (`dismissedDuplicateInstall`).
- **The slide-in panel spans the full screen height, under the menu bar.** Anything pinned to its top edge must clear `screen.frame.maxY - screen.visibleFrame.maxY` (37pt on notched MacBooks). The banner used to sit at +10 and was mostly hidden behind the menu bar; `PanelController.layoutBannerInsets()` now places it below the menu bar and, while it is visible, moves the web view's top down to the banner's top so the banner never covers the widget's search bar (the default widget's 48px body padding then lands content just under the banner).
- Action commands get `stdin = /dev/null` so an interactive rc file that prompts can never hang until the timeout.
- **Hidden menu bar icon is reported, not silently tolerated.** `StatusBarController.isIconLikelyHidden()` says hidden when the status item's window overlaps no screen's top 60pt strip (unknown states — no window yet, zero frame — count as not hidden). `AppDelegate` samples it at 3s, then +8s, then +15s and shows the banner notice (Help button) only if every sample says hidden — a single early sample is unreliable right after launch or a `killall ControlCenter`/`Dock`. Dismissal is remembered per build (`dismissedHiddenIconBuild`). `install.sh`/`update.sh` register the installed bundle with `lsregister -f` and print every other GlanceBar.app built from a different commit — they report, never delete.

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
- Hot corner mouse tracking (`NSEvent.addGlobalMonitorForEvents(.mouseMoved)`) still needs Accessibility permission. The app prompts for it via `AXIsProcessTrustedWithOptions` once per build while ungranted; if the hot corner still doesn't work, toggle GlanceBar off/on in System Settings → Privacy & Security → Accessibility.

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
- `dismissedUpdateCommit` — origin/main commit whose update offer was dismissed
- `dismissedDuplicateInstall` — "path|build" of a duplicate GlanceBar.app the user chose to ignore
- `dismissedHiddenIconBuild` — build for which the "menu bar icon hidden" notice was dismissed
- `legacyPreferencesMigrated` — bundle ID under which settings were (or were found not to need) migrating from a previous bundle ID's domain
- `accessibilityPromptedBuild` — build for which the system Accessibility prompt was already shown
