#!/usr/bin/env python3
"""
Generate app icons for Partner Check app
Design: Two overlapping circles (partners) with a checkmark (compatibility check)
"""

from PIL import Image, ImageDraw
import os

def create_icon(size, output_path):
    """Create an icon with partner compatibility theme"""
    # Create image with rounded corners
    img = Image.new('RGB', (size, size), color='#6366F1')  # Indigo background
    draw = ImageDraw.Draw(img)
    
    # Draw gradient background (simplified - solid color with gradient effect)
    # For simplicity, using a gradient-like color scheme
    center = size // 2
    
    # Draw two overlapping circles (representing partners)
    circle_radius = int(size * 0.25)
    offset = int(size * 0.15)
    
    # Left circle (partner 1) - pink/magenta
    left_center = (center - offset, center)
    draw.ellipse(
        [left_center[0] - circle_radius, left_center[1] - circle_radius,
         left_center[0] + circle_radius, left_center[1] + circle_radius],
        fill='#EC4899',  # Pink
        outline='#FFFFFF',
        width=max(2, size // 64)
    )
    
    # Right circle (partner 2) - blue
    right_center = (center + offset, center)
    draw.ellipse(
        [right_center[0] - circle_radius, right_center[1] - circle_radius,
         right_center[0] + circle_radius, right_center[1] + circle_radius],
        fill='#3B82F6',  # Blue
        outline='#FFFFFF',
        width=max(2, size // 64)
    )
    
    # Draw checkmark in the center (compatibility indicator)
    check_size = int(size * 0.2)
    check_thickness = max(4, size // 20)
    
    # Checkmark coordinates (centered, slightly below center)
    check_x = center
    check_y = center + int(size * 0.08)
    
    # Calculate checkmark points
    check_left = check_x - check_size // 3
    check_mid_x = check_x - check_size // 6
    check_mid_y = check_y
    check_right = check_x + check_size // 2
    check_top = check_y - check_size // 3
    
    # Draw checkmark: vertical line then diagonal
    # Vertical part (left side)
    draw.line(
        [(check_left, check_top),
         (check_mid_x, check_mid_y)],
        fill='#FFFFFF',
        width=check_thickness
    )
    # Diagonal part (right side)
    draw.line(
        [(check_mid_x, check_mid_y),
         (check_right, check_top)],
        fill='#FFFFFF',
        width=check_thickness
    )
    
    # Save the image
    img.save(output_path, 'PNG')
    print(f"Generated: {output_path} ({size}x{size})")

def main():
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
    
    for size, scale, filename in ios_sizes:
        create_icon(size, os.path.join(ios_dir, filename))
    
    # Android icons
    android_sizes = [
        (48, 'mipmap-mdpi'),
        (72, 'mipmap-hdpi'),
        (96, 'mipmap-xhdpi'),
        (144, 'mipmap-xxhdpi'),
        (192, 'mipmap-xxxhdpi'),
    ]
    
    for size, folder in android_sizes:
        android_dir = f'android/app/src/main/res/{folder}'
        os.makedirs(android_dir, exist_ok=True)
        create_icon(size, os.path.join(android_dir, 'ic_launcher.png'))
    
    # Web icons
    web_sizes = [
        (192, 'Icon-192.png'),
        (512, 'Icon-512.png'),
        (192, 'Icon-maskable-192.png'),
        (512, 'Icon-maskable-512.png'),
    ]
    
    web_dir = 'web/icons'
    os.makedirs(web_dir, exist_ok=True)
    
    for size, filename in web_sizes:
        create_icon(size, os.path.join(web_dir, filename))
    
    # macOS icons (if needed)
    macos_sizes = [
        (16, 1, 'app_icon_16.png'),
        (32, 1, 'app_icon_32.png'),
        (32, 2, 'app_icon_64.png'),
        (128, 1, 'app_icon_128.png'),
        (128, 2, 'app_icon_256.png'),
        (256, 1, 'app_icon_256.png'),
        (256, 2, 'app_icon_512.png'),
        (512, 1, 'app_icon_512.png'),
        (512, 2, 'app_icon_1024.png'),
    ]
    
    macos_dir = 'macos/Runner/Assets.xcassets/AppIcon.appiconset'
    os.makedirs(macos_dir, exist_ok=True)
    
    for size, scale, filename in macos_sizes:
        actual_size = size * scale
        create_icon(actual_size, os.path.join(macos_dir, filename))
    
    print("\nAll icons generated successfully!")

if __name__ == '__main__':
    main()

