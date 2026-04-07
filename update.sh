#!/bin/bash
set -e

# GlanceBar Updater
# Usage: glancebar-update (or bash ~/.glancebar-src/update.sh)

SRC_DIR="$HOME/.glancebar-src"
APP_DIR="$HOME/Applications"
APP_NAME="GlanceBar.app"

if [ ! -d "$SRC_DIR" ]; then
    echo "Error: GlanceBar source not found at $SRC_DIR"
    echo "Run the install script first."
    exit 1
fi

echo "→ Checking for updates..."
cd "$SRC_DIR"

# Fetch latest
git fetch origin main --quiet

LOCAL=$(git rev-parse HEAD)
REMOTE=$(git rev-parse origin/main)

if [ "$LOCAL" = "$REMOTE" ]; then
    echo "✓ Already up to date."
    exit 0
fi

echo "→ Update available! Pulling changes..."
git pull --ff-only

echo "→ Stopping GlanceBar..."
pkill -f GlanceBar || true
sleep 1

echo "→ Building..."
swift build -c release 2>&1 | tail -3

echo "→ Assembling app bundle..."
bash build.sh 2>/dev/null

echo "→ Installing..."
mkdir -p "$APP_DIR"
rm -rf "$APP_DIR/$APP_NAME"
cp -r "$SRC_DIR/$APP_NAME" "$APP_DIR/$APP_NAME"

echo "→ Launching..."
open "$APP_DIR/$APP_NAME"

echo ""
echo "✓ GlanceBar updated successfully!"
echo ""
