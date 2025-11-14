#!/usr/bin/env python3
"""
Generate app icons from source image for Partner Check app
Optimizes and resizes the source image for Android and iOS
"""

from PIL import Image
import os
import sys

def resize_and_save(source_image, size, output_path, optimize=True):
    """Resize image to specified size and save with optimization"""
    # Open and resize image
    img = Image.open(source_image)
    
    # Convert to RGB if necessary (for PNG with transparency)
    if img.mode in ('RGBA', 'LA', 'P'):
        # Create a white background
        background = Image.new('RGB', img.size, (255, 255, 255))
        if img.mode == 'P':
            img = img.convert('RGBA')
        background.paste(img, mask=img.split()[-1] if img.mode in ('RGBA', 'LA') else None)
        img = background
    elif img.mode != 'RGB':
        img = img.convert('RGB')
    
    # Resize with high-quality resampling
    img_resized = img.resize((size, size), Image.Resampling.LANCZOS)
    
    # Save with optimization
    img_resized.save(output_path, 'PNG', optimize=optimize)
    print(f"Generated: {output_path} ({size}x{size})")

def main():
    if len(sys.argv) < 2:
        print("Usage: python3 generate_icons_from_image.py <source_image_path>")
        print("Example: python3 generate_icons_from_image.py icon_source.png")
        sys.exit(1)
    
    source_image = sys.argv[1]
    
    if not os.path.exists(source_image):
        print(f"Error: Source image '{source_image}' not found!")
        sys.exit(1)
    
    print(f"Processing source image: {source_image}\n")
    
    # iOS icons
    ios_sizes = [
        (20, 1, 'Icon-App-20x20@1x.png'),
        (40, 2, 'Icon-App-20x20@2x.png'),
        (60, 3, 'Icon-App-20x20@3x.png'),
        (29, 1, 'Icon-App-29x29@1x.png'),
        (58, 2, 'Icon-App-29x29@2x.png'),
        (87, 3, 'Icon-App-29x29@3x.png'),
        (40, 1, 'Icon-App-40x40@1x.png'),
        (80, 2, 'Icon-App-40x40@2x.png'),
        (120, 3, 'Icon-App-40x40@3x.png'),
        (120, 2, 'Icon-App-60x60@2x.png'),
        (180, 3, 'Icon-App-60x60@3x.png'),
        (76, 1, 'Icon-App-76x76@1x.png'),
        (152, 2, 'Icon-App-76x76@2x.png'),
        (167, 2, 'Icon-App-83.5x83.5@2x.png'),
        (1024, 1, 'Icon-App-1024x1024@1x.png'),
    ]
    
    ios_dir = 'ios/Runner/Assets.xcassets/AppIcon.appiconset'
    os.makedirs(ios_dir, exist_ok=True)
    
    print("Generating iOS icons...")
    for size, scale, filename in ios_sizes:
        resize_and_save(source_image, size, os.path.join(ios_dir, filename))
    
    # Android icons
    android_sizes = [
        (48, 'mipmap-mdpi'),
        (72, 'mipmap-hdpi'),
        (96, 'mipmap-xhdpi'),
        (144, 'mipmap-xxhdpi'),
        (192, 'mipmap-xxxhdpi'),
    ]
    
    print("\nGenerating Android icons...")
    for size, folder in android_sizes:
        android_dir = f'android/app/src/main/res/{folder}'
        os.makedirs(android_dir, exist_ok=True)
        resize_and_save(source_image, size, os.path.join(android_dir, 'ic_launcher.png'))
    
    # Web icons
    web_sizes = [
        (192, 'Icon-192.png'),
        (512, 'Icon-512.png'),
        (192, 'Icon-maskable-192.png'),
        (512, 'Icon-maskable-512.png'),
    ]
    
    web_dir = 'web/icons'
    os.makedirs(web_dir, exist_ok=True)
    
    print("\nGenerating Web icons...")
    for size, filename in web_sizes:
        resize_and_save(source_image, size, os.path.join(web_dir, filename))
    
    # Save to assets folder for use in settings screen (512x512 for good quality)
    assets_dir = 'assets'
    os.makedirs(assets_dir, exist_ok=True)
    
    print("\nGenerating assets icon...")
    resize_and_save(source_image, 512, os.path.join(assets_dir, 'app_icon.png'))
    
    print("\n✅ All icons generated successfully!")
    print(f"📱 iOS icons: {ios_dir}")
    print(f"🤖 Android icons: android/app/src/main/res/mipmap-*/")
    print(f"🌐 Web icons: {web_dir}")
    print(f"⚙️  Settings icon: {os.path.join(assets_dir, 'app_icon.png')}")

if __name__ == '__main__':
    main()

