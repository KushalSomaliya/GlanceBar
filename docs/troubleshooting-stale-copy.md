# "GlanceBar is running but broken" — Stale Duplicate Copy

Symptoms, all at once:

- Entries copy fine, but **action/launch entries fail** (toast like `Action failed: zsh: command not found` / `sh: node: command not found`, or nothing happens).
- The **top of the panel looks wrong** — a dark strip or half-hidden box sits above the search bar, or the search bar/layout looks like an older version.
- It tends to start **after a reboot** (Login Items) or when you open GlanceBar from **Spotlight or Raycast**.
- Quitting and running the `glancebar` terminal alias makes everything work again.

## What is actually happening

There is more than one `GlanceBar.app` on the disk, built from different commits — e.g. an old copy in
`/Applications` from a manual `cp -r`, and the current one in `~/Applications` from `install.sh`, or a dev
build left in a source checkout.

- The `glancebar` alias opens **one specific path** (written into `~/.zshrc` by `install.sh`).
- Spotlight, Raycast and Login Items resolve "GlanceBar" through **Launch Services**, which can pick the
  **other** copy. Launching a copy also kills any older-launched instance (single-instance guard), so the
  stale copy takes over the hotkey and the panel.
- Builds before 1.1.5 ran action entries with `/bin/sh -c` and the bare launchd `PATH`
  (`/usr/bin:/bin:/usr/sbin:/sbin`), so anything from Homebrew/nvm was "command not found". Launching from a
  terminal masked it because `open` passes the terminal's full environment to the app — which is exactly why
  the alias "works" and Spotlight "doesn't".
- A stale copy that is behind `origin/main` shows the **update banner**, and before this fix the banner was
  pinned 10pt from the top of a panel that extends under the menu bar — on a notched MacBook only the bottom
  ~13pt of it peeked out above the search bar. That strip is the "weird search bar".
- Every copy also rewrites `~/.glancebar/index.html` to **its own** default template when the file is an
  unmodified default (hash-gated), so the widget's look flips to whichever copy launched last.

## Confirm it

```bash
# every GlanceBar.app Launch Services / Spotlight knows about, with version + build commit
for app in $(mdfind "kMDItemCFBundleIdentifier == 'dev.kushal.glancebar' || kMDItemCFBundleIdentifier == 'com.kushal.glancebar'") \
           ~/.glancebar-src/GlanceBar.app /Applications/GlanceBar.app ~/Applications/GlanceBar.app; do
  [ -d "$app" ] || continue
  printf '%s  v%s  %s\n' "$app" \
    "$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$app/Contents/Info.plist" 2>/dev/null)" \
    "$(/usr/libexec/PlistBuddy -c 'Print :GlanceBarBuildCommit' "$app/Contents/Info.plist" 2>/dev/null || echo unstamped)"
done | sort -u

# which copy is running right now (also: right-click the menu bar icon → "Running from …")
ps -eo lstart,command | grep '[G]lanceBar.app/Contents/MacOS'

# which copy Launch Services would launch for the bundle ID
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister \
  -dump | grep -B1 -A3 -i 'path:.*GlanceBar.app' | grep -iE 'path|version'
```

## Fix

1. Keep exactly one copy. Trash the others (the app now offers a **Trash** button in the banner when it
   finds a stale copy; "Running from …" in the status menu shows which one you are on).
2. Make sure Login Items points at the surviving copy: System Settings → General → Login Items → remove
   GlanceBar, then re-enable "Launch at Login" in GlanceBar's Preferences from the copy you kept.
3. If `~/.glancebar/index.html` was downgraded by the stale copy, launching the current copy regenerates it
   (a backup is written to `index.html.bak` first).

## Prevention

- Install/update only through `install.sh` / `glancebar-update` / the in-app updater — they replace the
  existing bundle in place rather than creating a second one.
- When developing, launch the build output (`open GlanceBar.app` in the checkout) only while the installed
  copy is quit, and prefer `bash update.sh` (or `install.sh`) to put a build where the alias points.
