#!/bin/bash
set -e

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
BUILD_DIR="$PROJECT_DIR/.build/release"
APP_DIR="$PROJECT_DIR/GlanceBar.app"
CONTENTS_DIR="$APP_DIR/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"

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

# Stamp the source revision and version into the bundle. The update system
# compares GlanceBarBuildCommit against origin/main to decide whether an
# update exists, and update.sh reads it to know if the installed app is stale.
PLIST_BUDDY=/usr/libexec/PlistBuddy
PLIST="$CONTENTS_DIR/Info.plist"

fail() {
    echo "Error: $*" >&2
    exit 1
}

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

# Codesign (ad-hoc for local use)
codesign --force --sign - "$APP_DIR" 2>/dev/null || true

echo ""
echo "Build complete: $APP_DIR"
echo ""
echo "To run:  open $APP_DIR"
echo "To install: cp -r $APP_DIR /Applications/"
