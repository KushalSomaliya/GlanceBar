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
BUILD_COMMIT=$(git -C "$PROJECT_DIR" rev-parse HEAD 2>/dev/null || echo "unknown")
APP_VERSION=$(sed -n 's/.*static let version = "\([^"]*\)".*/\1/p' "$PROJECT_DIR/Sources/GlanceBar/Constants.swift" | head -1)

"$PLIST_BUDDY" -c "Delete :GlanceBarBuildCommit" "$PLIST" 2>/dev/null || true
"$PLIST_BUDDY" -c "Add :GlanceBarBuildCommit string $BUILD_COMMIT" "$PLIST"
if [ -n "$APP_VERSION" ]; then
    "$PLIST_BUDDY" -c "Set :CFBundleShortVersionString $APP_VERSION" "$PLIST" 2>/dev/null || true
    "$PLIST_BUDDY" -c "Set :CFBundleVersion $APP_VERSION" "$PLIST" 2>/dev/null || true
fi

# Codesign (ad-hoc for local use)
codesign --force --sign - "$APP_DIR" 2>/dev/null || true

echo ""
echo "Build complete: $APP_DIR"
echo ""
echo "To run:  open $APP_DIR"
echo "To install: cp -r $APP_DIR /Applications/"
