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
pkill -f GlanceBar 2>/dev/null || true
sleep 1

# Install to detected location (or default ~/Applications for fresh installs)
mkdir -p "$APP_DIR"
rm -rf "$APP_DIR/$APP_NAME"
cp -r "$SRC_DIR/$APP_NAME" "$APP_DIR/$APP_NAME"
echo "→ Installed to $APP_DIR/$APP_NAME"

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
