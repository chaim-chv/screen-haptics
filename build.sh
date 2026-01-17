#!/bin/bash

VERSION="${1:-0.1.0}"
APP_NAME="ScreenHaptics"
BUNDLE_ID="com.local.ScreenHaptics"
OUTPUT_DIR="."
APP_BUNDLE="$OUTPUT_DIR/$APP_NAME.app"
MACOS_DIR="$APP_BUNDLE/Contents/MacOS"
RESOURCES_DIR="$APP_BUNDLE/Contents/Resources"

echo "🔨 Building $APP_NAME v$VERSION..."

# clean old build
rm -rf "$APP_BUNDLE"
mkdir -p "$MACOS_DIR"
mkdir -p "$RESOURCES_DIR"

cat > "$APP_BUNDLE/Contents/Info.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>$APP_NAME</string>
    <key>CFBundleIdentifier</key>
    <string>$BUNDLE_ID</string>
    <key>CFBundleName</key>
    <string>$APP_NAME</string>
    <key>CFBundleShortVersionString</key>
    <string>$VERSION</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>LSUIElement</key>
    <true/>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleLocalizations</key>
    <array>
        <string>en</string>
        <string>he</string>
    </array>
</dict>
</plist>
EOF

swiftc main.swift -o "$MACOS_DIR/$APP_NAME"

# Copy localizations
if [ -d "Resources" ]; then
    cp -r Resources/*.lproj "$RESOURCES_DIR/"
    echo "📦 Copied localization files"
fi

codesign --force --deep --sign - "$APP_BUNDLE"

echo "✅ Done! $APP_NAME.app v$VERSION is ready in the current directory."
