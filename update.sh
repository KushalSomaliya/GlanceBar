#!/bin/bash
set -e

# GlanceBar Updater
# Usage: glancebar-update (or bash ~/.glancebar-src/update.sh)

SRC_DIR="$HOME/.glancebar-src"
APP_DIR="$HOME/Applications"
APP_NAME="GlanceBar.app"

# If invoked from the running app (via the in-app updater), install in-place
# at the bundle's current location rather than defaulting to ~/Applications.
# Prevents duplicate GlanceBar.app entries when the user installed elsewhere
# (e.g. /Applications via a Finder drag).
if [ -n "${GLANCEBAR_TARGET:-}" ] && [ -d "$GLANCEBAR_TARGET" ]; then
    APP_DIR=$(dirname "$GLANCEBAR_TARGET")
    APP_NAME=$(basename "$GLANCEBAR_TARGET")
fi

# Bundle IDs — old needs to be fully purged from Tahoe's caches
# (macOS 26 keeps ghost entries in "Allow in Menu Bar" otherwise)
OLD_BUNDLE_ID="com.kushal.glancebar"
NEW_BUNDLE_ID="dev.kushal.glancebar"

if [ ! -d "$SRC_DIR" ]; then
    echo "Error: GlanceBar source not found at $SRC_DIR"
    echo "Run the install script first."
    exit 1
fi

echo "→ Checking for updates..."
cd "$SRC_DIR"

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
pkill -f GlanceBar 2>/dev/null || true
sleep 1

# Migrate preferences from old bundle ID to new (one-time migration)
OLD_PREF="$HOME/Library/Preferences/$OLD_BUNDLE_ID.plist"
NEW_PREF="$HOME/Library/Preferences/$NEW_BUNDLE_ID.plist"
if [ -f "$OLD_PREF" ] && [ ! -f "$NEW_PREF" ]; then
    echo "→ Migrating preferences to new bundle ID..."
    cp "$OLD_PREF" "$NEW_PREF"
fi

echo "→ Building..."
swift build -c release 2>&1 | tail -3

echo "→ Assembling app bundle..."
bash build.sh 2>/dev/null

echo "→ Installing to $APP_DIR..."
mkdir -p "$APP_DIR"

# Unregister the currently installed app (old or new) from Launch Services
# before replacing, so we don't get duplicate entries
LS_REGISTER=/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister
if [ -d "$APP_DIR/$APP_NAME" ]; then
    "$LS_REGISTER" -u "$APP_DIR/$APP_NAME" 2>/dev/null || true
fi
# Also unregister any dev build that might be floating around
if [ -d "$SRC_DIR/$APP_NAME" ]; then
    "$LS_REGISTER" -u "$SRC_DIR/$APP_NAME" 2>/dev/null || true
fi

rm -rf "$APP_DIR/$APP_NAME"
cp -r "$SRC_DIR/$APP_NAME" "$APP_DIR/$APP_NAME"

# Purge all traces of the old bundle ID — Tahoe caches menu bar permissions
# per bundle ID and leaves ghost entries behind that we need to clear
echo "→ Purging old bundle ID state..."
defaults delete "$OLD_BUNDLE_ID" 2>/dev/null || true
rm -f "$HOME/Library/Preferences/ByHost/$OLD_BUNDLE_ID."* 2>/dev/null || true

# Flush the preferences daemon cache — without this, Tahoe's "Allow in Menu
# Bar" list keeps showing a ghost entry for the deleted old bundle ID
killall cfprefsd 2>/dev/null || true
killall ControlCenter 2>/dev/null || true

echo "→ Launching..."
open "$APP_DIR/$APP_NAME"

echo ""
echo "✓ GlanceBar updated successfully!"
echo ""
