# App Icon Generation Guide

This script generates optimized app icons for Android and iOS from a source image.

## Prerequisites

Install Python Pillow library:
```bash
pip3 install Pillow
```

## Usage

1. Save your source image (the purple silhouette with blue/pink background) as `icon_source.png` in the project root, or use any image file.

2. Run the generation script:
```bash
python3 generate_icons_from_image.py icon_source.png
```

Or with any image file:
```bash
python3 generate_icons_from_image.py path/to/your/image.png
```

## What the Script Does

The script will:
- ✅ Generate all required iOS icon sizes (20x20 to 1024x1024)
- ✅ Generate all required Android icon sizes (48x48 to 192x192)
- ✅ Generate web icons (192x192 and 512x512)
- ✅ Create `assets/app_icon.png` (512x512) for use in the settings screen
- ✅ Optimize all images for best quality and file size

## Output Locations

- **iOS icons**: `ios/Runner/Assets.xcassets/AppIcon.appiconset/`
- **Android icons**: `android/app/src/main/res/mipmap-*/ic_launcher.png`
- **Web icons**: `web/icons/`
- **Settings screen icon**: `assets/app_icon.png`

## Notes

- The source image should be square (or will be cropped to square)
- Images are automatically optimized for best quality
- The settings screen already uses `assets/app_icon.png`, so it will update automatically

