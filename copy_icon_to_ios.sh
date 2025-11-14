#!/bin/bash

# Source Android icon (highest resolution)
SOURCE_ICON="android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png"
IOS_ICON_DIR="ios/Runner/Assets.xcassets/AppIcon.appiconset"

# Check if source icon exists
if [ ! -f "$SOURCE_ICON" ]; then
    echo "Error: Source icon not found at $SOURCE_ICON"
    exit 1
fi

echo "Copying Android icon to iOS..."
echo "Source: $SOURCE_ICON"

# Generate all iOS icon sizes using sips (macOS built-in tool)
cd "$(dirname "$0")"

# iPhone icons
sips -z 40 40 "$SOURCE_ICON" --out "$IOS_ICON_DIR/Icon-App-20x20@2x.png"
sips -z 60 60 "$SOURCE_ICON" --out "$IOS_ICON_DIR/Icon-App-20x20@3x.png"
sips -z 29 29 "$SOURCE_ICON" --out "$IOS_ICON_DIR/Icon-App-29x29@1x.png"
sips -z 58 58 "$SOURCE_ICON" --out "$IOS_ICON_DIR/Icon-App-29x29@2x.png"
sips -z 87 87 "$SOURCE_ICON" --out "$IOS_ICON_DIR/Icon-App-29x29@3x.png"
sips -z 80 80 "$SOURCE_ICON" --out "$IOS_ICON_DIR/Icon-App-40x40@2x.png"
sips -z 120 120 "$SOURCE_ICON" --out "$IOS_ICON_DIR/Icon-App-40x40@3x.png"
sips -z 120 120 "$SOURCE_ICON" --out "$IOS_ICON_DIR/Icon-App-60x60@2x.png"
sips -z 180 180 "$SOURCE_ICON" --out "$IOS_ICON_DIR/Icon-App-60x60@3x.png"

# iPad icons
sips -z 20 20 "$SOURCE_ICON" --out "$IOS_ICON_DIR/Icon-App-20x20@1x.png"
sips -z 40 40 "$SOURCE_ICON" --out "$IOS_ICON_DIR/Icon-App-20x20@2x.png"
sips -z 40 40 "$SOURCE_ICON" --out "$IOS_ICON_DIR/Icon-App-40x40@1x.png"
sips -z 76 76 "$SOURCE_ICON" --out "$IOS_ICON_DIR/Icon-App-76x76@1x.png"
sips -z 152 152 "$SOURCE_ICON" --out "$IOS_ICON_DIR/Icon-App-76x76@2x.png"
sips -z 167 167 "$SOURCE_ICON" --out "$IOS_ICON_DIR/Icon-App-83.5x83.5@2x.png"

# App Store icon (1024x1024)
sips -z 1024 1024 "$SOURCE_ICON" --out "$IOS_ICON_DIR/Icon-App-1024x1024@1x.png"

echo "✓ All iOS icons generated successfully!"

