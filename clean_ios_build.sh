#!/bin/bash

# Clean iOS build script
echo "Cleaning Flutter build..."
flutter clean

echo "Cleaning iOS Pods..."
cd ios
rm -rf Pods
rm -rf Podfile.lock
rm -rf .symlinks
rm -rf build
rm -rf ~/Library/Developer/Xcode/DerivedData/*

echo "Reinstalling Pods..."
pod deintegrate
pod install

cd ..

echo "Getting Flutter dependencies..."
flutter pub get

echo "Clean complete! Try building again."

