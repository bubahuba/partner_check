#!/bin/bash

echo "=== Comprehensive iOS Build Fix ==="
echo ""

# Get the project directory
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_DIR"

echo "Project directory: $PROJECT_DIR"
echo ""

# Step 1: Find Flutter
echo "Step 1: Finding Flutter installation..."
if command -v flutter &> /dev/null; then
    FLUTTER_CMD=$(which flutter)
    FLUTTER_DIR=$(dirname $(dirname "$FLUTTER_CMD"))
    echo "   Flutter found at: $FLUTTER_DIR"
else
    echo "   ERROR: Flutter not in PATH"
    echo "   Please run: export PATH=\"\$PATH:\$(pwd)/flutter/bin\""
    echo "   Or provide Flutter path manually"
    read -p "   Enter Flutter path (or press Enter to exit): " FLUTTER_DIR
    if [ -z "$FLUTTER_DIR" ]; then
        exit 1
    fi
fi

# Verify Flutter installation
if [ ! -f "$FLUTTER_DIR/bin/flutter" ]; then
    echo "   ERROR: Invalid Flutter path: $FLUTTER_DIR"
    exit 1
fi

echo "   Using Flutter: $FLUTTER_DIR"
echo ""

# Step 2: Clean everything
echo "Step 2: Cleaning build artifacts..."
rm -rf build
rm -rf ios/Pods
rm -rf ios/Podfile.lock
rm -rf ios/.symlinks
rm -rf ios/Flutter/Flutter.framework
rm -rf ios/Flutter/Flutter.podspec
rm -rf ios/Flutter/ephemeral
rm -rf ios/Flutter/Generated.xcconfig
echo "   Cleaned"
echo ""

# Step 3: Get Flutter dependencies
echo "Step 3: Getting Flutter dependencies..."
"$FLUTTER_DIR/bin/flutter" clean
"$FLUTTER_DIR/bin/flutter" pub get
echo "   Dependencies fetched"
echo ""

# Step 4: Verify Generated.xcconfig was created
echo "Step 4: Verifying Generated.xcconfig..."
if [ -f "ios/Flutter/Generated.xcconfig" ]; then
    echo "   Generated.xcconfig exists"
    echo "   FLUTTER_ROOT in config:"
    grep "FLUTTER_ROOT" ios/Flutter/Generated.xcconfig || echo "   WARNING: FLUTTER_ROOT not found in config"
    
    # Check if FLUTTER_ROOT matches
    CONFIG_ROOT=$(grep "FLUTTER_ROOT" ios/Flutter/Generated.xcconfig | cut -d'=' -f2)
    if [ "$CONFIG_ROOT" != "$FLUTTER_DIR" ]; then
        echo "   WARNING: FLUTTER_ROOT mismatch!"
        echo "   Config has: $CONFIG_ROOT"
        echo "   Expected: $FLUTTER_DIR"
        echo "   Regenerating..."
        "$FLUTTER_DIR/bin/flutter" pub get
    fi
else
    echo "   ERROR: Generated.xcconfig not created!"
    echo "   Trying to regenerate..."
    "$FLUTTER_DIR/bin/flutter" pub get
    if [ ! -f "ios/Flutter/Generated.xcconfig" ]; then
        echo "   ERROR: Still missing. Creating manually..."
        cat > ios/Flutter/Generated.xcconfig << EOF
// This is a generated file; do not edit or check into version control.
FLUTTER_ROOT=$FLUTTER_DIR
FLUTTER_APPLICATION_PATH=$PROJECT_DIR
COCOAPODS_PARALLEL_CODE_SIGN=true
FLUTTER_TARGET=lib/main.dart
FLUTTER_BUILD_DIR=build
FLUTTER_BUILD_NAME=0.1.0
FLUTTER_BUILD_NUMBER=0.1.0
EXCLUDED_ARCHS[sdk=iphonesimulator*]=i386
EXCLUDED_ARCHS[sdk=iphoneos*]=armv7
DART_OBFUSCATION=false
TRACK_WIDGET_CREATION=true
TREE_SHAKE_ICONS=false
PACKAGE_CONFIG=.dart_tool/package_config.json
EOF
    fi
fi
echo ""

# Step 5: Verify xcode_backend.sh exists
echo "Step 5: Verifying Flutter build script..."
BACKEND_SCRIPT="$FLUTTER_DIR/packages/flutter_tools/bin/xcode_backend.sh"
if [ -f "$BACKEND_SCRIPT" ]; then
    echo "   xcode_backend.sh found at: $BACKEND_SCRIPT"
    chmod +x "$BACKEND_SCRIPT"
else
    echo "   ERROR: xcode_backend.sh not found!"
    echo "   Expected at: $BACKEND_SCRIPT"
    exit 1
fi
echo ""

# Step 6: Clean and reinstall CocoaPods
echo "Step 6: Cleaning and reinstalling CocoaPods..."
cd ios
if command -v pod &> /dev/null; then
    pod deintegrate
    pod cache clean --all 2>/dev/null || true
    pod install --repo-update
    echo "   CocoaPods reinstalled"
else
    echo "   WARNING: CocoaPods not found"
    echo "   Install with: sudo gem install cocoapods"
fi
cd ..
echo ""

# Step 7: Clean Xcode derived data
echo "Step 7: Cleaning Xcode derived data..."
rm -rf ~/Library/Developer/Xcode/DerivedData/*
echo "   Derived data cleaned"
echo ""

echo "=== Fix Complete ==="
echo ""
echo "Next steps:"
echo "1. Open Xcode: open ios/Runner.xcworkspace"
echo "2. In Xcode: Product → Clean Build Folder (Shift+Cmd+K)"
echo "3. Try building again"
echo ""
echo "If the error persists, check the Xcode build log for specific error details."

