#!/bin/bash

echo "Checking Flutter installation..."

# Check if flutter command exists
if command -v flutter &> /dev/null; then
    FLUTTER_PATH=$(which flutter)
    FLUTTER_ROOT=$(dirname $(dirname "$FLUTTER_PATH"))
    echo "Flutter found at: $FLUTTER_ROOT"
    echo "Updating Generated.xcconfig with correct path..."
    
    # Update Generated.xcconfig
    cat > ios/Flutter/Generated.xcconfig << EOF
// This is a generated file; do not edit or check into version control.
FLUTTER_ROOT=$FLUTTER_ROOT
FLUTTER_APPLICATION_PATH=$(pwd)
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
    
    echo "Generated.xcconfig updated!"
    echo "FLUTTER_ROOT set to: $FLUTTER_ROOT"
    
    # Check if backend script exists
    BACKEND_SCRIPT="$FLUTTER_ROOT/packages/flutter_tools/bin/xcode_backend.sh"
    if [ -f "$BACKEND_SCRIPT" ]; then
        echo "✓ Flutter backend script found"
    else
        echo "✗ Flutter backend script NOT found at: $BACKEND_SCRIPT"
    fi
else
    echo "ERROR: Flutter command not found in PATH"
    echo "Please ensure Flutter is installed and in your PATH"
fi

