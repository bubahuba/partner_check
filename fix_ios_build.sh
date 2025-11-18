#!/bin/bash

# Fix iOS build issues for flutter_contacts module
# This script cleans and rebuilds the iOS project

set -e

echo "🧹 Cleaning Flutter build..."
flutter clean

echo "📦 Getting Flutter dependencies..."
flutter pub get

echo "🍎 Cleaning iOS pods..."
cd ios
rm -rf Pods
rm -rf Podfile.lock
rm -rf .symlinks
rm -rf Flutter/Flutter.framework
rm -rf Flutter/Flutter.podspec

echo "📥 Reinstalling pods..."
export LANG=en_US.UTF-8
pod install

echo "✅ iOS build fix complete!"
echo ""
echo "Next steps:"
echo "1. Open Xcode: open ios/Runner.xcworkspace"
echo "2. In Xcode: Product > Clean Build Folder (Shift+Cmd+K)"
echo "3. Build the project (Cmd+B)"
