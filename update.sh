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

    local SOURCE_APP="$SRC_DIR/GlanceBar.app"
    local INSTALL_APP="$APP_DIR/$APP_NAME"
    local SOURCE_REAL INSTALL_REAL APP_DIR_REAL INSTALL_ERROR=""

    canonical_bundle_path() {
        local path="$1" dir base physical_dir
        if [ -d "$path" ]; then
            (cd -P "$path" && pwd -P)
        else
            dir=$(dirname "$path")
            base=$(basename "$path")
            physical_dir=$(cd -P "$dir" && pwd -P) || return 1
            printf '%s/%s\n' "$physical_dir" "$base"
        fi
    }

    prepare_bundle() {
        local bundle="$1"
        local executable="$bundle/Contents/MacOS/GlanceBar"

        if [ ! -d "$bundle/Contents/MacOS" ] || [ ! -f "$bundle/Contents/Info.plist" ]; then
            INSTALL_ERROR="Replacement app has an invalid bundle structure"
            return 1
        fi
        if [ ! -f "$executable" ] || [ ! -x "$executable" ]; then
            INSTALL_ERROR="Replacement app executable is missing or not executable"
            return 1
        fi
        # Re-sign the candidate and strip quarantine before installation. Tahoe's
        # Gatekeeper keeps per-path provenance records for ad-hoc apps; a bundle
        # replaced in place with a stale record gets a bogus "GlanceBar is
        # damaged and can't be opened" dialog on next launch.
        if ! xattr -rd com.apple.quarantine "$bundle" 2>/dev/null; then
            INSTALL_ERROR="Could not strip quarantine from the replacement app"
            return 1
        fi
        if ! codesign --force --deep --sign - "$bundle" 2>/dev/null; then
            INSTALL_ERROR="Could not sign the replacement app"
            return 1
        fi
        if ! codesign --verify --deep --strict "$bundle" 2>/dev/null; then
            INSTALL_ERROR="Replacement app failed code-signature verification"
            return 1
        fi
    }

    if ! SOURCE_REAL=$(canonical_bundle_path "$SOURCE_APP"); then
        echo "→ Error: Could not resolve the built app path." >&2
        exit 1
    fi
    if ! INSTALL_REAL=$(canonical_bundle_path "$INSTALL_APP"); then
        echo "→ Error: Could not resolve the install path." >&2
        exit 1
    fi
    if ! APP_DIR_REAL=$(cd -P "$APP_DIR" && pwd -P); then
        echo "→ Error: Could not resolve the install directory." >&2
        exit 1
    fi

    # Replacing a running app's bundle on disk is safe — the old process
    # keeps its open inodes until we restart it below. Stage and verify the
    # replacement first, then swap it into place with rollback protection.
    if [ "$SOURCE_REAL" = "$INSTALL_REAL" ]; then
        echo "→ Built app is already at the install path; signing and verifying in place..."
        if ! prepare_bundle "$INSTALL_APP"; then
            echo "→ Error: $INSTALL_ERROR." >&2
            exit 1
        fi
    else
        # Temp directories must be siblings, never nested inside either bundle.
        case "$APP_DIR_REAL/" in
            "$SOURCE_REAL/"*|"$INSTALL_REAL/"*)
                echo "→ Error: Install directory resolves inside an app bundle." >&2
                exit 1
                ;;
        esac

        local STAGE_DIR="" STAGED_APP="" OLD_DIR="" OLD_APP=""
        local HAD_OLD=0 NEW_MOVED=0 SWAP_COMMITTED=0

        cleanup_install() {
            local status="$1" restored=0 preserve_old=0
            trap - EXIT HUP INT TERM
            set +e

            if [ "$SWAP_COMMITTED" = "0" ] && [ -n "$OLD_APP" ] && { [ -e "$OLD_APP" ] || [ -L "$OLD_APP" ]; }; then
                if [ -e "$INSTALL_APP" ] || [ -L "$INSTALL_APP" ]; then
                    rm -rf "$INSTALL_APP"
                fi
                if [ ! -e "$INSTALL_APP" ] && [ ! -L "$INSTALL_APP" ] && mv "$OLD_APP" "$INSTALL_APP"; then
                    restored=1
                else
                    preserve_old=1
                fi
            elif [ "$SWAP_COMMITTED" = "0" ] && [ "$HAD_OLD" = "0" ] && [ "$NEW_MOVED" = "1" ]; then
                rm -rf "$INSTALL_APP"
            fi

            if [ -n "$STAGE_DIR" ]; then
                rm -rf "${STAGE_DIR:?}"
            fi
            if [ -n "$OLD_DIR" ] && [ "$preserve_old" = "0" ]; then
                rm -rf "${OLD_DIR:?}"
            fi

            if [ "$status" -ne 0 ]; then
                if [ "$SWAP_COMMITTED" = "1" ]; then
                    echo "→ Error: ${INSTALL_ERROR:-Installation failed}; verified replacement remains installed." >&2
                elif [ "$restored" = "1" ]; then
                    echo "→ Error: ${INSTALL_ERROR:-Installation failed}; previous app restored." >&2
                elif [ "$preserve_old" = "1" ]; then
                    echo "→ Error: ${INSTALL_ERROR:-Installation failed}; restore it from $OLD_APP." >&2
                elif [ "$HAD_OLD" = "1" ]; then
                    echo "→ Error: ${INSTALL_ERROR:-Installation failed}; previous app left unchanged." >&2
                else
                    echo "→ Error: ${INSTALL_ERROR:-Installation failed}; no existing app was replaced." >&2
                fi
            fi
            exit "$status"
        }

        trap 'cleanup_install "$?"' EXIT
        trap 'INSTALL_ERROR="Installation interrupted"; exit 1' HUP INT TERM

        if ! STAGE_DIR=$(mktemp -d "$APP_DIR/.GlanceBar.new.XXXXXX"); then
            INSTALL_ERROR="Could not create the staging directory"
            exit 1
        fi
        STAGED_APP="$STAGE_DIR/$APP_NAME"
        if ! cp -R "$SOURCE_APP" "$STAGED_APP"; then
            INSTALL_ERROR="Could not stage the replacement app"
            exit 1
        fi
        if ! prepare_bundle "$STAGED_APP"; then
            exit 1
        fi

        if [ -e "$INSTALL_APP" ] || [ -L "$INSTALL_APP" ]; then
            HAD_OLD=1
            if ! OLD_DIR=$(mktemp -d "$APP_DIR/.GlanceBar.old.XXXXXX"); then
                INSTALL_ERROR="Could not create the rollback directory"
                exit 1
            fi
            OLD_APP="$OLD_DIR/$APP_NAME"
            if ! mv "$INSTALL_APP" "$OLD_APP"; then
                INSTALL_ERROR="Could not move the previous app aside"
                exit 1
            fi
        fi
        if ! mv "$STAGED_APP" "$INSTALL_APP"; then
            INSTALL_ERROR="Could not move the replacement app into place"
            exit 1
        fi
        NEW_MOVED=1

        if ! rmdir "$STAGE_DIR"; then
            INSTALL_ERROR="Could not remove the staging directory"
            exit 1
        fi
        STAGE_DIR=""
        SWAP_COMMITTED=1
        if [ -n "$OLD_DIR" ]; then
            if ! rm -rf "${OLD_DIR:?}"; then
                INSTALL_ERROR="Could not remove the previous app backup"
                exit 1
            fi
            OLD_DIR=""
            OLD_APP=""
        fi
        trap - EXIT HUP INT TERM
    fi

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
