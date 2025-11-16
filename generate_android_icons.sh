#!/bin/bash

# Generate Android icons from appIcon.png
SOURCE_ICON="appIcon.png"
ANDROID_RES_DIR="android/app/src/main/res"

# Check if source icon exists
if [ ! -f "$SOURCE_ICON" ]; then
    echo "Error: Source icon not found at $SOURCE_ICON"
    exit 1
fi

echo "Generating Android icons from $SOURCE_ICON..."
echo ""

# Android icon sizes for different densities
# mipmap-mdpi: 48x48 px
# mipmap-hdpi: 72x72 px
# mipmap-xhdpi: 96x96 px
# mipmap-xxhdpi: 144x144 px
# mipmap-xxxhdpi: 192x192 px

sips -z 48 48 "$SOURCE_ICON" --out "$ANDROID_RES_DIR/mipmap-mdpi/ic_launcher.png"
echo "✓ Generated mipmap-mdpi/ic_launcher.png (48x48)"

sips -z 72 72 "$SOURCE_ICON" --out "$ANDROID_RES_DIR/mipmap-hdpi/ic_launcher.png"
echo "✓ Generated mipmap-hdpi/ic_launcher.png (72x72)"

sips -z 96 96 "$SOURCE_ICON" --out "$ANDROID_RES_DIR/mipmap-xhdpi/ic_launcher.png"
echo "✓ Generated mipmap-xhdpi/ic_launcher.png (96x96)"

sips -z 144 144 "$SOURCE_ICON" --out "$ANDROID_RES_DIR/mipmap-xxhdpi/ic_launcher.png"
echo "✓ Generated mipmap-xxhdpi/ic_launcher.png (144x144)"

sips -z 192 192 "$SOURCE_ICON" --out "$ANDROID_RES_DIR/mipmap-xxxhdpi/ic_launcher.png"
echo "✓ Generated mipmap-xxxhdpi/ic_launcher.png (192x192)"

echo ""
echo "✅ All Android icons generated successfully!"
echo "📱 Icons location: $ANDROID_RES_DIR/mipmap-*/ic_launcher.png"

