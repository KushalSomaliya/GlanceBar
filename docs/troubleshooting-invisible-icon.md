# Invisible Menu Bar Icon — Troubleshooting

If GlanceBar is running (Cmd+] works, app appears in Activity Monitor) but the menu bar icon is nowhere to be seen, you've hit a macOS Tahoe bug. This doc captures what we learned debugging it so you don't have to go through the same pain.

## Symptoms

All of these at once:
- App is running (`pgrep -fl GlanceBar` shows the process)
- Cmd+] (or your configured hotkey) opens the panel correctly
- `statusItem.isVisible = true`, `button.image` is not nil, `button.isHidden = false`
- But the icon is invisible in the menu bar
- **System Settings → Menu Bar → Allow in the Menu Bar** shows GlanceBar with the toggle ON
- Toggling off/on does nothing
- A friend with the same code on a fresh install sees the icon just fine

Debug output typically shows:
```
window.frame: (0.0, -5.0, 38.0, 22.0)   ← positioned off-screen
window.isOnActiveSpace: false
```

## Root Cause

macOS Tahoe (26.x) tracks menu bar permissions per bundle identifier. Over many rebuild cycles with ad-hoc code signing (each rebuild gets a new binary hash), Tahoe's internal permission state for that bundle ID can get corrupted. The System Settings UI keeps showing the toggle as ON, but the underlying system-level state is stuck in a "denied/unregistered" state. The system silently positions the status item window off-screen at `(0, -5)` regardless of what the app does.

There is no user-accessible plist containing this state, so you can't directly clean it. `tccutil reset` doesn't cover it. `lsregister -u` doesn't clear it. Deleting `com.apple.controlcenter.plist` doesn't help. Restarting the Mac doesn't help.

## Things that DON'T fix it

These all seem like they should work. None of them do.

- `killall SystemUIServer` / `killall Dock` / `killall ControlCenter`
- Deleting `~/Library/Preferences/com.apple.systemuiserver.plist`
- Deleting `~/Library/Preferences/ByHost/com.apple.controlcenter.*.plist`
- `defaults delete <bundle-id>` (UserDefaults cleanup)
- `lsregister -u` on the app bundle
- `xattr -cr` to clear quarantine
- Toggling "Allow in Menu Bar" off and on
- Disabling "Automatically hide and show the menu bar"
- Moving the app to `/Applications/`
- Restarting the Mac
- A full "nuclear reset" combining all of the above
- Rebuilding with different Info.plist keys (`NSPrincipalClass`, `LSApplicationCategoryType`, `autosaveName`, etc.)
- Switching to SwiftUI `MenuBarExtra` (different problem — crashes with SPM @main)

## The fix that actually works

**Change the `CFBundleIdentifier`** in `Resources/Info.plist` to something new. Tahoe sees it as a brand new app with clean state. The icon appears immediately.

Example — we went from:
```xml
<key>CFBundleIdentifier</key>
<string>com.kushal.glancebar</string>
```

to:

```xml
<key>CFBundleIdentifier</key>
<string>dev.kushal.glancebar</string>
```

Then:

1. Update `AppConstants.bundleIdentifier` in `Sources/GlanceBar/Constants.swift` to match, and add the
   previous ID to the top of `AppConstants.legacyBundleIdentifiers`
2. Add the previous ID to `LEGACY_BUNDLE_IDS` in `update.sh` and to the `case`/`mdfind` lists in `install.sh`
3. Rebuild: `rm -rf .build GlanceBar.app && swift build -c release && bash build.sh`
4. Replace the installed copy: `mv /Applications/GlanceBar.app ~/.Trash/ && cp -R GlanceBar.app /Applications/ && codesign --force --deep --sign - /Applications/GlanceBar.app`
5. Restart menu bar: `killall ControlCenter; killall Dock`
6. Launch: `open /Applications/GlanceBar.app`

The app takes care of the rest on its first launch under the new ID: `PreferencesManager` copies every
setting from the newest previous bundle ID's defaults domain, and if Launch at Login was on it re-registers
the login item (login items are per bundle ID). Two things still need a human: re-grant **Accessibility**
for the hot corner (TCC is per bundle ID too), and remove the old ID's ghost rows from System Settings →
Accessibility and → Login Items.

### Rotation log

| Date       | From                   | To                      | Why                                                                                 |
| ---------- | ---------------------- | ----------------------- | ----------------------------------------------------------------------------------- |
| 2026-04-12 | `com.kushal.glancebar` | `dev.kushal.glancebar`  | Icon invisible after many ad-hoc rebuilds                                           |
| 2026-10-02 | `dev.kushal.glancebar` | `dev.kushal.glancebar2` | Icon invisible again; two differently signed copies had shared the ID for months    |

## How to avoid it in the first place

The corruption builds up over many rebuild cycles — and faster when several differently signed copies share
the bundle ID (the Oct 2026 case: a stale `/Applications` copy plus checkout builds). To prevent:

- **Keep one bundle and install through `bash build.sh --install`.** It replaces `/Applications/GlanceBar.app`
  and deletes the checkout bundle, so no second copy is ever registered. Never `open` a checkout build. See
  [`troubleshooting-stale-copy.md`](troubleshooting-stale-copy.md).
- **Sign with a stable identity.** Ad-hoc signatures (`codesign --sign -`) get a new identity on every build.
  Create a self-signed code-signing certificate once — Keychain Access → Certificate Assistant → Create a
  Certificate… → Name `GlanceBar Dev`, Identity Type `Self-Signed Root`, Certificate Type `Code Signing` —
  and `build.sh`, `install.sh` and `update.sh` pick it up automatically (`security find-identity -v -p
  codesigning` must list it; set its Code Signing trust to Always Trust if `codesign` complains). A Developer
  ID or free "Apple Development" certificate works the same way via `GLANCEBAR_SIGN_IDENTITY=<name>`. Stable
  signatures also keep the Accessibility grant for the hot corner across rebuilds.
- **Don't rebuild dozens of times while the app is installed** if you are stuck with ad-hoc signing.
- **Don't toggle "Allow in Menu Bar" rapidly.** It seems to stick in a bad state if toggled many times quickly.

## How to confirm you've hit this specific bug

Add this to your status bar controller to print diagnostic info:

```swift
func debugInfo() -> String {
    var info = ""
    info += "isVisible: \(statusItem.isVisible)\n"
    if let button = statusItem.button {
        info += "button.image: \(button.image != nil ? "YES" : "nil")\n"
        if let window = button.window {
            info += "window.frame: \(window.frame)\n"
            info += "window.isOnActiveSpace: \(window.isOnActiveSpace)\n"
        }
    }
    return info
}
```

If `window.frame.origin.y` is negative (like `-5` or `-17`) and `isOnActiveSpace` is `false` while `isVisible` is `true`, it's this bug. Change the bundle ID.

## Detection in-app

GlanceBar does this itself now: `StatusBarController.isIconLikelyHidden()` reports hidden when the status
item's window overlaps no screen's menu bar strip, and `AppDelegate.checkForHiddenMenuBarIcon()` samples it at
3s, +8s and +15s after launch — the status item can sit at a placeholder frame right after launch or after a
`killall ControlCenter` — and shows a "Menu bar icon is hidden by macOS" notice in the panel banner only when
every sample agrees (Help opens this doc). Dismissing it silences the notice until the next rebuild. Also check for duplicate `GlanceBar.app` copies first — see
[`troubleshooting-stale-copy.md`](troubleshooting-stale-copy.md); several differently-signed copies sharing one
bundle ID is the setup that most often ends here.

The pattern, for reference (from the Stats app) — check the window Y position 1-2 seconds after launch:

```swift
DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
    guard let window = self?.statusItem.button?.window else { return }
    let screenHeight = NSScreen.main?.frame.height ?? 0
    if window.frame.origin.y < screenHeight - 100 {
        // Icon is off-screen — show alert directing user to System Settings
    }
}
```

## Further reading

- Full research report: [`nsstatusitem-invisible-icon-deep-research.md`](../nsstatusitem-invisible-icon-deep-research.md)
- Related GitHub issues hitting the same Tahoe bug:
  - [Maccy #1224](https://github.com/p0deje/Maccy/issues/1224)
  - [Stats #2704](https://github.com/exelban/stats/issues/2704)
  - [Ice #679](https://github.com/jordanbaird/Ice/issues/679)
  - [AeroSpace #1968](https://github.com/nikitabobko/AeroSpace/discussions/1968)
  - [BetterDisplay #4957](https://github.com/waydabber/BetterDisplay/discussions/4957)
  - [Tauri #13770](https://github.com/tauri-apps/tauri/issues/13770)
