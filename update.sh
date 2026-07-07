#!/bin/bash
set -euo pipefail

# GlanceBar Updater
# Usage: glancebar-update (or bash ~/.glancebar-src/update.sh)
#
# The whole script runs inside main() so bash parses the entire file before
# executing any of it — `git pull` below replaces this file on disk mid-run,
# and without the wrapper bash could execute a half-old, half-new script.
main() {
    local SRC_DIR="$HOME/.glancebar-src"
    local APP_DIR="$HOME/Applications"
    local APP_NAME="GlanceBar.app"

    # If invoked from the running app (via the in-app updater), install
    # in-place at the bundle's current location rather than defaulting to
    # ~/Applications. Prevents duplicate GlanceBar.app entries when the user
    # installed elsewhere (e.g. /Applications via a Finder drag).
    local FROM_APP=0
    if [ -n "${GLANCEBAR_TARGET:-}" ] && [ -d "$GLANCEBAR_TARGET" ]; then
        FROM_APP=1
        APP_DIR=$(dirname "$GLANCEBAR_TARGET")
        APP_NAME=$(basename "$GLANCEBAR_TARGET")
    else
        # Terminal run: find where the app actually lives (running process
        # first, then common locations) so we replace it in-place instead of
        # installing a duplicate into ~/Applications.
        local RUNNING_LINE EXEC EXISTING=""
        RUNNING_LINE=$(ps -eo command 2>/dev/null | grep -E 'GlanceBar\.app/Contents/MacOS/GlanceBar' | head -1 || true)
        if [ -n "$RUNNING_LINE" ]; then
            EXEC=$(echo "$RUNNING_LINE" | awk '{print $1}')
            if [ -f "$EXEC" ]; then
                EXISTING="${EXEC%/Contents/MacOS/GlanceBar}"
            fi
        fi
        if [ -z "$EXISTING" ]; then
            for p in "/Applications/GlanceBar.app" "$HOME/Applications/GlanceBar.app"; do
                if [ -d "$p" ]; then EXISTING="$p"; break; fi
            done
        fi
        if [ -n "$EXISTING" ]; then
            APP_DIR=$(dirname "$EXISTING")
            APP_NAME=$(basename "$EXISTING")
        fi
    fi

    # Bundle IDs — old needs to be fully purged from Tahoe's caches
    # (macOS 26 keeps ghost entries in "Allow in Menu Bar" otherwise)
    local OLD_BUNDLE_ID="com.kushal.glancebar"
    local NEW_BUNDLE_ID="dev.kushal.glancebar"

    if [ ! -d "$SRC_DIR" ]; then
        echo "Error: GlanceBar source not found at $SRC_DIR"
        echo "Run the install script first."
        exit 1
    fi

    echo "→ Checking for updates..."
    cd "$SRC_DIR"

    git fetch origin main --quiet

    local LOCAL REMOTE INSTALLED_COMMIT=""
    LOCAL=$(git rev-parse HEAD)
    REMOTE=$(git rev-parse origin/main)
    local PLIST="$APP_DIR/$APP_NAME/Contents/Info.plist"
    if [ -f "$PLIST" ]; then
        INSTALLED_COMMIT=$(/usr/libexec/PlistBuddy -c 'Print :GlanceBarBuildCommit' "$PLIST" 2>/dev/null || true)
    fi

    # Up to date only when BOTH the source checkout and the installed app
    # match origin/main. The old script only compared the checkout, so a
    # stale installed app with a current checkout could never be repaired.
    if [ "$LOCAL" = "$REMOTE" ] && [ "$INSTALLED_COMMIT" = "$REMOTE" ]; then
        echo "✓ Already up to date."
        exit 0
    fi

    if [ "$LOCAL" != "$REMOTE" ]; then
        echo "→ Update available! Pulling changes..."
        if ! git pull --ff-only --quiet origin main; then
            # Upstream history was rewritten. This checkout is only a build
            # cache, so force it to match.
            git reset --hard origin/main --quiet
        fi
    else
        echo "→ Rebuilding: installed app is older than the source..."
    fi

    # Migrate preferences from old bundle ID to new (one-time migration)
    local OLD_PREF="$HOME/Library/Preferences/$OLD_BUNDLE_ID.plist"
    local NEW_PREF="$HOME/Library/Preferences/$NEW_BUNDLE_ID.plist"
    if [ -f "$OLD_PREF" ] && [ ! -f "$NEW_PREF" ]; then
        echo "→ Migrating preferences to new bundle ID..."
        cp "$OLD_PREF" "$NEW_PREF"
    fi

    # Build BEFORE stopping the app. The running app streams these lines into
    # its update banner — and killing it first would SIGPIPE this script the
    # moment it writes into the dead app's pipe, which is exactly how the old
    # updater died mid-run and left a stale app behind.
    echo "→ Building..."
    swift build -c release 2>&1 | tail -3

    echo "→ Assembling app bundle..."
    bash build.sh >/dev/null 2>&1

    echo "→ Installing to $APP_DIR..."
    mkdir -p "$APP_DIR"

    # Unregister the currently installed app (old or new) from Launch Services
    # before replacing, so we don't get duplicate entries
    local LS_REGISTER=/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister
    if [ -d "$APP_DIR/$APP_NAME" ]; then
        "$LS_REGISTER" -u "$APP_DIR/$APP_NAME" 2>/dev/null || true
    fi
    # Also unregister any dev build that might be floating around
    if [ -d "$SRC_DIR/GlanceBar.app" ]; then
        "$LS_REGISTER" -u "$SRC_DIR/GlanceBar.app" 2>/dev/null || true
    fi

    # Replacing a running app's bundle on disk is safe — the old process
    # keeps its open inodes until we restart it below.
    rm -rf "$APP_DIR/$APP_NAME"
    cp -R "$SRC_DIR/GlanceBar.app" "$APP_DIR/$APP_NAME"

    # Re-sign at the final install path and strip quarantine. Tahoe's
    # Gatekeeper keeps per-path provenance records for ad-hoc apps; a bundle
    # replaced in place with a stale record gets a bogus "GlanceBar is
    # damaged and can't be opened" dialog on next launch.
    xattr -rd com.apple.quarantine "$APP_DIR/$APP_NAME" 2>/dev/null || true
    codesign --force --deep --sign - "$APP_DIR/$APP_NAME" 2>/dev/null || true

    # Purge all traces of the old bundle ID — Tahoe caches menu bar permissions
    # per bundle ID and leaves ghost entries behind that we need to clear
    echo "→ Purging old bundle ID state..."
    defaults delete "$OLD_BUNDLE_ID" 2>/dev/null || true
    rm -f "$HOME/Library/Preferences/ByHost/$OLD_BUNDLE_ID."* 2>/dev/null || true

    # Flush the preferences daemon cache — without this, Tahoe's "Allow in Menu
    # Bar" list keeps showing a ghost entry for the deleted old bundle ID
    killall cfprefsd 2>/dev/null || true
    killall ControlCenter 2>/dev/null || true

    echo "→ Restarting GlanceBar..."

    # When the app spawned us, it's about to die — any write to its pipe
    # after the pkill would SIGPIPE-kill this script, so silence ourselves
    # for the remaining steps. (Terminal runs keep their output.)
    if [ "$FROM_APP" = "1" ]; then
        exec >/dev/null 2>&1
    fi

    pkill -f 'GlanceBar\.app/Contents/MacOS/GlanceBar' 2>/dev/null || true
    sleep 1

    open "$APP_DIR/$APP_NAME"

    echo ""
    echo "✓ GlanceBar updated successfully!"
    echo ""
}

main "$@"
