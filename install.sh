#!/bin/bash
set -e

# GlanceBar Installer
# Usage: curl -fsSL https://raw.githubusercontent.com/KushalSomaliya/GlanceBar/main/install.sh | bash

REPO="https://github.com/KushalSomaliya/GlanceBar.git"
SRC_DIR="$HOME/.glancebar-src"
APP_DIR="$HOME/Applications"
APP_NAME="GlanceBar.app"

echo ""
echo "  ┌─────────────────────────────────┐"
echo "  │  Installing GlanceBar...        │"
echo "  └─────────────────────────────────┘"
echo ""

# Check for Swift
if ! command -v swift &>/dev/null; then
    echo "Error: Swift is required. Install Xcode Command Line Tools:"
    echo "  xcode-select --install"
    exit 1
fi

# Detect existing installation so we replace in-place instead of creating a
# duplicate somewhere else. Priority: running process > common locations.
EXISTING=""
RUNNING_LINE=$(ps -eo command 2>/dev/null | grep -E 'GlanceBar\.app/Contents/MacOS/GlanceBar' | head -1 || true)
if [ -n "$RUNNING_LINE" ]; then
    EXEC=$(echo "$RUNNING_LINE" | awk '{print $1}')
    if [ -f "$EXEC" ]; then
        EXISTING="${EXEC%/Contents/MacOS/GlanceBar}"
    fi
fi
if [ -z "$EXISTING" ]; then
    for p in "/Applications/$APP_NAME" "$HOME/Applications/$APP_NAME" "$HOME/Desktop/$APP_NAME" "$HOME/Downloads/$APP_NAME"; do
        if [ -d "$p" ]; then EXISTING="$p"; break; fi
    done
fi
if [ -n "$EXISTING" ]; then
    APP_DIR=$(dirname "$EXISTING")
    APP_NAME=$(basename "$EXISTING")
    echo "→ Found existing install at $EXISTING — replacing in place"
fi

# Use existing clone or clone fresh
if [ -d "$SRC_DIR/.git" ]; then
    echo "→ Source found, updating..."
    cd "$SRC_DIR"
    git pull --ff-only
else
    echo "→ Cloning repository..."
    git clone "$REPO" "$SRC_DIR" 2>/dev/null || true
    cd "$SRC_DIR"
fi

# Build
echo "→ Building (this may take a moment on first run)..."
swift build -c release 2>&1 | tail -3

# Assemble .app bundle
echo "→ Assembling app bundle..."
bash build.sh 2>/dev/null

# Stop any running instance before replacing the binary, otherwise `open`
# below may just focus the old one instead of cold-starting the new build.
pkill -f 'GlanceBar\.app/Contents/MacOS/GlanceBar' 2>/dev/null || true
sleep 1

# Install to detected location (or default ~/Applications for fresh installs)
mkdir -p "$APP_DIR"
rm -rf "$APP_DIR/$APP_NAME"
cp -r "$SRC_DIR/GlanceBar.app" "$APP_DIR/$APP_NAME"

# Re-sign at the final install path and strip quarantine — Tahoe's Gatekeeper
# shows a bogus "damaged" dialog for ad-hoc bundles with stale provenance.
xattr -rd com.apple.quarantine "$APP_DIR/$APP_NAME" 2>/dev/null || true
# Same rule as build.sh: a self-signed "GlanceBar" certificate keeps one
# identity across rebuilds; GLANCEBAR_SIGN_IDENTITY overrides, "-" is ad hoc.
SIGN_IDENTITY="${GLANCEBAR_SIGN_IDENTITY:-}"
if [ -z "$SIGN_IDENTITY" ] && security find-identity -v -p codesigning 2>/dev/null | grep -q '"GlanceBar"'; then
    SIGN_IDENTITY="GlanceBar"
fi
codesign --force --deep --sign "${SIGN_IDENTITY:--}" "$APP_DIR/$APP_NAME" 2>/dev/null || true
echo "→ Installed to $APP_DIR/$APP_NAME"

# Register this copy with Launch Services and point out any other GlanceBar.app
# built from different code: Spotlight, Raycast and Login Items may launch a
# stale copy instead of this one. Nothing is deleted here — the app's banner
# offers a Trash button for stale copies.
LS_REGISTER=/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister
"$LS_REGISTER" -f "$APP_DIR/$APP_NAME" 2>/dev/null || true
INSTALL_REAL=$(cd -P "$APP_DIR/$APP_NAME" && pwd -P)
INSTALL_COMMIT=$(/usr/libexec/PlistBuddy -c 'Print :GlanceBarBuildCommit' "$APP_DIR/$APP_NAME/Contents/Info.plist" 2>/dev/null || true)
while IFS= read -r CANDIDATE; do
    [ -d "$CANDIDATE" ] || continue
    REAL=$(cd -P "$CANDIDATE" && pwd -P) || continue
    [ "$REAL" = "$INSTALL_REAL" ] && continue
    case "$REAL" in */.Trash/*) continue ;; esac
    ID=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$REAL/Contents/Info.plist" 2>/dev/null) || continue
    case "$ID" in glancebar|dev.kushal.glancebar2|dev.kushal.glancebar|com.kushal.glancebar) ;; *) continue ;; esac
    COMMIT=$(/usr/libexec/PlistBuddy -c 'Print :GlanceBarBuildCommit' "$REAL/Contents/Info.plist" 2>/dev/null || true)
    if [ -n "$COMMIT" ] && [ "$COMMIT" = "$INSTALL_COMMIT" ]; then continue; fi
    VERSION=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$REAL/Contents/Info.plist" 2>/dev/null || echo "?")
    echo "→ Another GlanceBar.app at $REAL (v$VERSION, ${COMMIT:-unstamped}) — move it to the Trash so Spotlight, Raycast and Login Items can only open $APP_DIR/$APP_NAME"
done < <({
    mdfind "kMDItemCFBundleIdentifier == 'glancebar' || kMDItemCFBundleIdentifier == 'dev.kushal.glancebar2' || kMDItemCFBundleIdentifier == 'dev.kushal.glancebar' || kMDItemCFBundleIdentifier == 'com.kushal.glancebar'" 2>/dev/null || true
    printf '%s\n' /Applications/GlanceBar.app "$HOME/Applications/GlanceBar.app" \
        "$HOME/Desktop/GlanceBar.app" "$HOME/Downloads/GlanceBar.app" "$SRC_DIR/GlanceBar.app"
} | awk 'NF' | sort -u)

# Add alias if not present
SHELL_RC="$HOME/.zshrc"
if [ -f "$HOME/.bashrc" ] && [ ! -f "$HOME/.zshrc" ]; then
    SHELL_RC="$HOME/.bashrc"
fi
if ! grep -q "alias glancebar=" "$SHELL_RC" 2>/dev/null; then
    echo "" >> "$SHELL_RC"
    echo "# GlanceBar" >> "$SHELL_RC"
    echo "alias glancebar=\"open $APP_DIR/$APP_NAME\"" >> "$SHELL_RC"
    echo "alias glancebar-update=\"bash $SRC_DIR/update.sh\"" >> "$SHELL_RC"
    echo "→ Added 'glancebar' and 'glancebar-update' aliases to $SHELL_RC"
fi

# Launch
echo "→ Launching GlanceBar..."
open "$APP_DIR/$APP_NAME"

echo ""
echo "  ✓ GlanceBar installed successfully!"
echo ""
echo "  • Click the sidebar icon (⊞) in your menu bar"
echo "  • Or press Cmd+] from any app"
echo "  • Run 'glancebar-update' to check for updates"
echo "  • Run 'source $SHELL_RC' to load aliases now"
echo ""
