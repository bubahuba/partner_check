#!/bin/bash

echo "=== iOS Build Debug Script ==="
echo ""

# Check Flutter installation
echo "1. Checking Flutter installation..."
if command -v flutter &> /dev/null; then
    FLUTTER_PATH=$(which flutter)
    echo "   Flutter found at: $FLUTTER_PATH"
    flutter --version
else
    echo "   ERROR: Flutter not found in PATH"
    echo "   Please add Flutter to your PATH or use the full path"
    exit 1
fi

echo ""
echo "2. Checking Flutter root..."
FLUTTER_ROOT=$(flutter --version | grep "Flutter SDK" | awk '{print $4}' || echo "")
if [ -z "$FLUTTER_ROOT" ]; then
    FLUTTER_ROOT=$(dirname $(dirname $(which flutter)))
fi
echo "   Flutter root: $FLUTTER_ROOT"

echo ""
echo "3. Checking Generated.xcconfig..."
if [ -f "ios/Flutter/Generated.xcconfig" ]; then
    echo "   Generated.xcconfig exists"
    echo "   Contents:"
    cat ios/Flutter/Generated.xcconfig | head -5
    echo ""
    
    # Check FLUTTER_ROOT in Generated.xcconfig
    CONFIG_FLUTTER_ROOT=$(grep "FLUTTER_ROOT" ios/Flutter/Generated.xcconfig | cut -d'=' -f2)
    echo "   FLUTTER_ROOT in config: $CONFIG_FLUTTER_ROOT"
    
    if [ "$CONFIG_FLUTTER_ROOT" != "$FLUTTER_ROOT" ]; then
        echo "   WARNING: FLUTTER_ROOT mismatch!"
        echo "   Expected: $FLUTTER_ROOT"
        echo "   Found: $CONFIG_FLUTTER_ROOT"
    fi
else
    echo "   ERROR: Generated.xcconfig not found!"
fi

echo ""
echo "4. Checking Podfile..."
if [ -f "ios/Podfile" ]; then
    echo "   Podfile exists"
else
    echo "   ERROR: Podfile not found!"
fi

echo ""
echo "5. Checking CocoaPods installation..."
if command -v pod &> /dev/null; then
    echo "   CocoaPods found: $(pod --version)"
else
    echo "   ERROR: CocoaPods not found"
    echo "   Install with: sudo gem install cocoapods"
fi

echo ""
echo "6. Checking for build scripts..."
if [ -f "$FLUTTER_ROOT/packages/flutter_tools/bin/xcode_backend.sh" ]; then
    echo "   xcode_backend.sh found"
    ls -la "$FLUTTER_ROOT/packages/flutter_tools/bin/xcode_backend.sh"
else
    echo "   ERROR: xcode_backend.sh not found at expected location"
    echo "   Expected: $FLUTTER_ROOT/packages/flutter_tools/bin/xcode_backend.sh"
fi

echo ""
echo "=== Recommendations ==="
echo "1. Run: flutter clean && flutter pub get"
echo "2. Run: cd ios && pod deintegrate && pod install && cd .."
echo "3. Open Xcode and clean build folder (Shift+Cmd+K)"
echo "4. Check Xcode build log for specific error details"

