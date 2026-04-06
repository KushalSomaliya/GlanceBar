# GlanceBar

A lightweight macOS menu bar app that gives you a slide-in widget sidebar — like Quick Note, but for anything you want to glance at quickly.

Your widget is a plain HTML file. Edit it, save it, and it live-reloads instantly. Full CSS/JS — hover effects, animations, clipboard access, everything a browser can do.

![macOS 14+](https://img.shields.io/badge/macOS-14%2B-blue) ![Swift](https://img.shields.io/badge/Swift-5.9-orange)

## Features

- **Hot corner** — move your mouse to a screen corner, sidebar slides in
- **Click-to-copy** — tap any entry to copy its value to clipboard
- **Hide values** — toggle to mask sensitive data with dots, hover to peek
- **Select & delete** — select multiple entries, review what you're deleting, confirm
- **Add cards, sections, entries** — all inline, no popups
- **Live reload** — edit `~/.glancebar/index.html`, save, widget updates instantly
- **Desktop pin** — pin the widget to your desktop like a native macOS widget
- **Auto-close** — dismisses when you switch desktops (3-finger swipe)
- **Persistent data** — everything saved to `~/.glancebar/data.json`, survives restarts
## Install

**Requirements:** macOS 14+ (Sonoma), Swift CLI tools (`xcode-select --install`)

```bash
git clone https://github.com/YOUR_USERNAME/GlanceBar.git
cd GlanceBar
./build.sh
open GlanceBar.app

# Optional: copy to Applications
cp -r GlanceBar.app /Applications/
```

**Quick reopen alias** (add to your `.zshrc`):

```bash
echo 'alias glancebar="open ~/Documents/personal/GlanceBar/GlanceBar.app"' >> ~/.zshrc && source ~/.zshrc
```

## Usage

| Action | How |
|---|---|
| Open sidebar | Click menu bar icon, or hot corner |
| Close sidebar | Click outside, press `Esc`, or switch desktops |
| Copy a value | Click any entry row |
| Add entry | Hover a section header, click `+` |
| Add section | Click `...` on a card, choose "Add Section" |
| Add card | Click "+ Add Card" at the bottom |
| Delete entries | Click `...` > "Select & Delete Items" > select > Delete |
| Hide values | Click `...` > toggle "Hide Values" |
| Pin to desktop | Right-click menu bar icon > "Pin to Desktop" |
| Edit widget | Right-click menu bar icon > "Edit Widget..." |
| Preferences | Right-click menu bar icon > "Preferences..." |

## Customization

Your widget lives at `~/.glancebar/index.html`. It's a standard HTML file — edit it in any text editor. The app watches the file and reloads on save.

Data is stored separately in `~/.glancebar/data.json` and persists across widget file changes.

### JS Bridge

Your widget can call these from JavaScript:

```javascript
GlanceBar.copy("text")        // Copy to clipboard
GlanceBar.saveData(object)    // Persist data to data.json
GlanceBar.openURL("https://") // Open URL in browser
```

Saved data is injected on page load via `window._onDataLoaded(data)`.

## Build from source

```bash
swift build -c release    # Compile
./build.sh                # Compile + assemble .app bundle
```

No Xcode.app needed — just Swift CLI tools.

## How it works

- **NSPanel** (borderless, non-activating) slides in from the right edge
- **NSVisualEffectView** with `.sidebar` material for native macOS blur
- **WKWebView** renders your HTML with transparent background
- **DispatchSource** watches your widget file for changes (handles atomic saves from vim/VS Code)
- **NSEvent global monitor** tracks mouse position for hot corner detection
- **NSWorkspace notification** auto-closes the panel on desktop switch
- Data flows: HTML `-->` JS bridge `-->` Swift `-->` `data.json` on disk

