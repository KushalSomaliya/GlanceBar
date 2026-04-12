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

1. Update `AppConstants.bundleIdentifier` in `Sources/GlanceBar/Constants.swift` to match
2. If you have `autosaveName` on your status item, update that string too
3. Rebuild: `rm -rf .build GlanceBar.app && swift build -c release && bash build.sh`
4. Copy to `/Applications/`: `cp -r GlanceBar.app /Applications/`
5. Restart menu bar: `killall ControlCenter; killall Dock`
6. Launch: `open /Applications/GlanceBar.app`

## How to avoid it in the first place

The corruption builds up over many rebuild cycles. To prevent:

- **Don't rebuild dozens of times while the app is installed.** Uninstall between major rebuild sessions.
- **Use Developer ID signing** if you have an Apple Developer account ($99/year). Stable code signatures mean Tahoe doesn't keep re-evaluating permissions for "new" binaries every rebuild. Free Apple ID "Apple Development" certificates also work.
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

## Detection in-app (optional)

You can warn users if their icon is invisible using the Stats app's pattern — check the window Y position 1-2 seconds after launch:

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
