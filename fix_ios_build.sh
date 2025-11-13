#!/bin/bash

set -e

echo "=== Fixing iOS Build Issues ==="

cd "$(dirname "$0")"

echo "1. Cleaning Flutter..."
flutter clean

echo "2. Cleaning iOS build artifacts..."
cd ios
rm -rf build
rm -rf Pods
rm -rf Podfile.lock
rm -rf .symlinks
rm -rf ~/Library/Developer/Xcode/DerivedData/*

echo "3. Getting Flutter dependencies..."
cd ..
flutter pub get

echo "4. Deintegrating CocoaPods..."
cd ios
pod deintegrate || true

echo "5. Installing CocoaPods..."
pod install --repo-update

echo "6. Verifying Podfile.lock and Manifest.lock match..."
if ! diff Podfile.lock Pods/Manifest.lock > /dev/null 2>&1; then
    echo "ERROR: Podfile.lock and Manifest.lock don't match!"
    echo "Running pod install again..."
    pod install
fi

echo "7. Final Flutter clean..."
cd ..
flutter clean

echo ""
echo "=== Fix Complete ==="
echo "Try building in Xcode now. If it still fails:"
echo "1. Open Xcode"
echo "2. Product > Clean Build Folder (Shift+Cmd+K)"
echo "3. Close Xcode"
echo "4. Run this script again"
echo "5. Open Xcode and build"

