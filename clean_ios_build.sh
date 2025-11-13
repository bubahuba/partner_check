#!/bin/bash

# Clean iOS build script
echo "Cleaning Flutter build..."
flutter clean

echo "Removing iOS build artifacts..."
cd ios
rm -rf Pods
rm -rf Podfile.lock
rm -rf .symlinks
rm -rf Flutter/Flutter.framework
rm -rf Flutter/Flutter.podspec
rm -rf build
rm -rf ~/Library/Developer/Xcode/DerivedData/*

echo "Running pod install..."
pod deintegrate || true
pod install --repo-update

cd ..

echo "Getting Flutter dependencies..."
flutter pub get

echo "Clean complete! Try building again."

