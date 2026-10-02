#!/bin/bash
set -e

# GlanceBar build script
#
#   bash build.sh            compile + assemble ./GlanceBar.app (nothing is launched)
#   bash build.sh --install  additionally: quit the running app, replace
#                            /Applications/GlanceBar.app (or $GLANCEBAR_INSTALL_DIR/GlanceBar.app)
#                            with this build, re-sign it there, register it with Launch
#                            Services, remove the checkout bundle, launch the installed copy.
#
# One installed bundle is the rule: Spotlight, Raycast and Login Items resolve
# "GlanceBar" through Launch Services and will launch whatever copy they find,
# so a checkout build that is left around becomes the "stale duplicate copy"
# problem (docs/troubleshooting-stale-copy.md).
#
# Signing: ad-hoc signatures change on every build, so TCC grants (Accessibility
# for the hot corner) and Tahoe's per-app menu bar state see each rebuild as a
# new app. A self-signed "GlanceBar" code-signing certificate in the login
# keychain keeps one identity across rebuilds and is picked up automatically.
# Override with GLANCEBAR_SIGN_IDENTITY=<name>, or GLANCEBAR_SIGN_IDENTITY=- for
# ad hoc. See CLAUDE.md → Development Workflow.

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
BUILD_DIR="$PROJECT_DIR/.build/release"
APP_DIR="$PROJECT_DIR/GlanceBar.app"
CONTENTS_DIR="$APP_DIR/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"

INSTALL=0
for arg in "$@"; do
    case "$arg" in
        --install) INSTALL=1 ;;
        -h|--help)
            sed -n '4,22p' "$0" | sed 's/^# \{0,1\}//'
            exit 0
            ;;
        *) echo "Unknown option: $arg (try --help)" >&2; exit 2 ;;
    esac
done

fail() {
    echo "Error: $*" >&2
    exit 1
}

echo "Building GlanceBar..."
cd "$PROJECT_DIR"
swift build -c release 2>&1

echo "Assembling app bundle..."
rm -rf "$APP_DIR"
mkdir -p "$MACOS_DIR"
mkdir -p "$RESOURCES_DIR"

# Copy binary
cp "$BUILD_DIR/GlanceBar" "$MACOS_DIR/"

# Copy Info.plist
cp "$PROJECT_DIR/Resources/Info.plist" "$CONTENTS_DIR/"

# App icon. Resources/AppIcon.iconset holds the PNGs rendered from
# Resources/AppIcon.svg (scripts/render-app-icon.js); iconutil, part of macOS,
# packs them into the AppIcon.icns that Info.plist's CFBundleIconFile names.
ICONSET="$PROJECT_DIR/Resources/AppIcon.iconset"
if [ -d "$ICONSET" ]; then
    if command -v iconutil >/dev/null 2>&1; then
        if ! iconutil -c icns "$ICONSET" -o "$RESOURCES_DIR/AppIcon.icns"; then
            fail "iconutil could not build AppIcon.icns from $ICONSET"
        fi
    else
        echo "Warning: iconutil not found; the bundle will show the generic app icon." >&2
    fi
fi

# Stamp the source revision and version into the bundle. The update system
# compares GlanceBarBuildCommit against origin/main to decide whether an
# update exists, and update.sh reads it to know if the installed app is stale.
PLIST_BUDDY=/usr/libexec/PlistBuddy
PLIST="$CONTENTS_DIR/Info.plist"

BUILD_COMMIT="unknown"
BUILD_DIRTY=true
if command -v git >/dev/null 2>&1 &&
   RESOLVED_BUILD_COMMIT=$(git -C "$PROJECT_DIR" rev-parse --verify HEAD 2>/dev/null); then
    BUILD_COMMIT="$RESOLVED_BUILD_COMMIT"
    if BUILD_STATUS=$(git -C "$PROJECT_DIR" status --porcelain=v1 --untracked-files=no --ignore-submodules=untracked 2>/dev/null) &&
       [ -z "$BUILD_STATUS" ]; then
        BUILD_DIRTY=false
    fi
fi

if ! APP_VERSION=$(sed -nE 's/^[[:space:]]*static[[:space:]]+let[[:space:]]+version[[:space:]]*=[[:space:]]*"([^"]+)".*/\1/p' "$PROJECT_DIR/Sources/GlanceBar/Constants.swift"); then
    fail "Could not read the app version from Constants.swift"
fi
case "$APP_VERSION" in
    "") fail "Could not determine the app version from Constants.swift" ;;
    *$'\n'*) fail "Found multiple app versions in Constants.swift" ;;
esac

stamp_plist_value() {
    local key="$1"
    local type="$2"
    local expected="$3"
    local actual

    if "$PLIST_BUDDY" -c "Print :$key" "$PLIST" >/dev/null 2>&1; then
        if ! "$PLIST_BUDDY" -c "Delete :$key" "$PLIST"; then
            fail "Could not replace $key in Info.plist"
        fi
    fi
    if ! "$PLIST_BUDDY" -c "Add :$key $type $expected" "$PLIST"; then
        fail "Could not write $key to Info.plist"
    fi
    if ! actual=$("$PLIST_BUDDY" -c "Print :$key" "$PLIST" 2>/dev/null); then
        fail "Could not read $key back from Info.plist"
    fi
    if [ "$actual" != "$expected" ]; then
        fail "Info.plist $key mismatch (expected '$expected', got '$actual')"
    fi
}

stamp_plist_value GlanceBarBuildCommit string "$BUILD_COMMIT"
stamp_plist_value GlanceBarBuildDirty bool "$BUILD_DIRTY"
stamp_plist_value CFBundleShortVersionString string "$APP_VERSION"
stamp_plist_value CFBundleVersion string "$APP_VERSION"

# Codesign — stable identity when one exists, ad hoc otherwise (see header).
SIGN_IDENTITY="${GLANCEBAR_SIGN_IDENTITY:-}"
if [ -z "$SIGN_IDENTITY" ] && security find-identity -v -p codesigning 2>/dev/null | grep -q '"GlanceBar"'; then
    SIGN_IDENTITY="GlanceBar"
fi

sign_bundle() {
    local bundle="$1"
    if [ -n "$SIGN_IDENTITY" ] && [ "$SIGN_IDENTITY" != "-" ]; then
        if ! codesign --force --deep --sign "$SIGN_IDENTITY" "$bundle"; then
            fail "codesign with '$SIGN_IDENTITY' failed. In Keychain Access set that certificate's Code Signing trust to Always Trust, or run with GLANCEBAR_SIGN_IDENTITY=- to sign ad hoc."
        fi
    else
        codesign --force --deep --sign - "$bundle" 2>/dev/null || true
    fi
}

sign_bundle "$APP_DIR"
if [ -n "$SIGN_IDENTITY" ] && [ "$SIGN_IDENTITY" != "-" ]; then
    echo "Signed with identity: $SIGN_IDENTITY"
else
    echo "Signed ad hoc. Create a 'GlanceBar' code-signing certificate so permissions survive rebuilds (CLAUDE.md → Development Workflow)."
fi

if [ "$INSTALL" = "0" ]; then
    echo ""
    echo "Build complete: $APP_DIR"
    echo ""
    echo "To install and launch:  bash build.sh --install"
    exit 0
fi

INSTALL_DIR="${GLANCEBAR_INSTALL_DIR:-/Applications}"
INSTALL_APP="$INSTALL_DIR/GlanceBar.app"
# End-anchored: the app's command line is exactly its executable path, while a
# shell whose command line merely mentions the path must not be matched.
GLANCEBAR_PROCESS='GlanceBar\.app/Contents/MacOS/GlanceBar$'
LS_REGISTER=/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister

echo "Installing to $INSTALL_APP..."
pkill -f "$GLANCEBAR_PROCESS" 2>/dev/null || true
for _ in $(seq 1 50); do
    pgrep -f "$GLANCEBAR_PROCESS" >/dev/null 2>&1 || break
    sleep 0.1
done

mkdir -p "$INSTALL_DIR"
if [ -d "$INSTALL_APP" ]; then
    # Keep the previous build recoverable instead of deleting it.
    mkdir -p "$HOME/.Trash"
    mv "$INSTALL_APP" "$HOME/.Trash/GlanceBar-replaced-$(date +%Y%m%d-%H%M%S).app"
fi
cp -R "$APP_DIR" "$INSTALL_APP"
xattr -rd com.apple.quarantine "$INSTALL_APP" 2>/dev/null || true
# Sign again at the final path: Tahoe keeps per-path provenance for ad-hoc apps.
sign_bundle "$INSTALL_APP"
"$LS_REGISTER" -f "$INSTALL_APP" 2>/dev/null || true
# Finder and the Dock cache app icons by path; a fresh mtime makes them re-read it.
touch "$INSTALL_APP"

# The checkout bundle is now a second copy of this exact build. Remove it so
# Spotlight, Raycast and Login Items can only ever find the installed one.
rm -rf "$APP_DIR"

open "$INSTALL_APP"
echo ""
echo "Installed and launched: $INSTALL_APP"
