#!/usr/bin/env python3
"""
Generate app icons for Partner Check app
Design: Two overlapping circles (partners) with a checkmark (compatibility check)
"""

from PIL import Image, ImageDraw, ImageFont
import os

def add_free_ribbon(img, size):
    """Add a 'FREE' ribbon badge to the upper right corner of the image"""
    # Ensure image is in RGB mode for drawing
    if img.mode != 'RGB':
        img = img.convert('RGB')
    
    # Calculate ribbon size based on icon size
    # Make it much larger so it extends far beyond the icon edges
    ribbon_width = int(size * 1.5)  # 150% of icon width (diagonal, extends far beyond)
    ribbon_height = int(size * 0.15)  # 15% of icon height
    
    # Create a separate image for the ribbon to rotate it
    # Make canvas much larger to accommodate ribbon extending far beyond edges
    ribbon_size = int(size * 2.0)  # 2x larger canvas for rotation
    ribbon_img = Image.new('RGBA', (ribbon_size, ribbon_size), (0, 0, 0, 0))
    ribbon_draw = ImageDraw.Draw(ribbon_img)
    
    # Draw ribbon shape (rectangular, will be rotated)
    # Position in center of rotation canvas
    center_x = ribbon_size // 2
    center_y = ribbon_size // 2
    ribbon_x = center_x - ribbon_width // 2
    ribbon_y = center_y - ribbon_height // 2
    
    # Draw ribbon background (black)
    ribbon_color = (0, 0, 0)  # Black
    ribbon_points = [
        (ribbon_x, ribbon_y),
        (ribbon_x + ribbon_width, ribbon_y),
        (ribbon_x + ribbon_width, ribbon_y + ribbon_height),
        (ribbon_x, ribbon_y + ribbon_height),
    ]
    
    ribbon_draw.polygon(ribbon_points, fill=ribbon_color)
    
    # Add a subtle border for definition (dark gray)
    border_color = (50, 50, 50)  # Dark gray border
    ribbon_draw.polygon(ribbon_points, outline=border_color, width=max(1, size // 128))
    
    # Rotate the ribbon 45 degrees
    rotated_ribbon = ribbon_img.rotate(-45, expand=False, fillcolor=(0, 0, 0, 0))
    
    # Calculate position to place rotated ribbon in upper right corner
    # Position it so it extends far beyond the icon edges
    # The ribbon should start from well outside the icon and extend into it
    paste_x = int(size - ribbon_size * 0.6)  # Position so ribbon extends far beyond right edge
    paste_y = int(-ribbon_size * 0.4)  # Position so ribbon extends far beyond top edge
    
    # Paste the rotated ribbon onto the main image
    if img.mode == 'RGBA':
        img.paste(rotated_ribbon, (paste_x, paste_y), rotated_ribbon)
    else:
        # Convert to RGBA temporarily for alpha compositing
        img_rgba = img.convert('RGBA')
        img_rgba.paste(rotated_ribbon, (paste_x, paste_y), rotated_ribbon)
        img = img_rgba.convert('RGB')
    
    # Now draw text on the rotated ribbon
    draw = ImageDraw.Draw(img)
    
    # Add "FREE" text on the rotated ribbon
    # Create a text image, rotate it, and paste it
    font_size = max(8, int(size * 0.1))  # 10% of icon size, minimum 8
    
    # Try to load a bold font
    font = None
    font_paths = [
        "/System/Library/Fonts/Helvetica.ttc",
        "/System/Library/Fonts/Supplemental/Arial Bold.ttf",
        "/System/Library/Fonts/Supplemental/Arial.ttf",
        "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf",  # Linux
        "/Windows/Fonts/arialbd.ttf",  # Windows
    ]
    
    for font_path in font_paths:
        try:
            font = ImageFont.truetype(font_path, font_size)
            break
        except:
            continue
    
    # Fallback to default font if no system font found
    if font is None:
        try:
            font = ImageFont.load_default()
        except:
            pass
    
    # Create text image
    text = "FREE"
    text_img_size = int(ribbon_width * 1.2)  # Slightly larger for rotation
    text_img = Image.new('RGBA', (text_img_size, text_img_size), (0, 0, 0, 0))
    text_draw = ImageDraw.Draw(text_img)
    
    # Calculate text position (centered)
    if font:
        try:
            bbox = text_draw.textbbox((0, 0), text, font=font)
            text_width = bbox[2] - bbox[0]
            text_height = bbox[3] - bbox[1]
        except:
            text_width = len(text) * font_size * 0.6
            text_height = font_size
    else:
        text_width = len(text) * font_size * 0.6
        text_height = font_size
    
    text_x = (text_img_size - text_width) // 2
    text_y = (text_img_size - text_height) // 2
    
    # Draw text with shadow for readability
    shadow_offset = max(1, size // 256)
    try:
        text_draw.text(
            (text_x + shadow_offset, text_y + shadow_offset),
            text,
            fill=(100, 100, 100, 200),  # Gray shadow with transparency
            font=font
        )
    except:
        pass
    
    # Draw main text
    text_draw.text(
        (text_x, text_y),
        text,
        fill=(255, 255, 255, 255),  # White text
        font=font
    )
    
    # Rotate text image -45 degrees (same as ribbon)
    rotated_text = text_img.rotate(-45, expand=False, fillcolor=(0, 0, 0, 0))
    
    # Position text on the ribbon (centered on the rotated ribbon)
    # Calculate center of ribbon after rotation
    # Account for the paste position of the ribbon
    ribbon_center_x = paste_x + ribbon_size // 2
    ribbon_center_y = paste_y + ribbon_size // 2
    text_paste_x = ribbon_center_x - text_img_size // 2
    text_paste_y = ribbon_center_y - text_img_size // 2
    
    # Paste rotated text onto main image
    if img.mode == 'RGBA':
        img.paste(rotated_text, (text_paste_x, text_paste_y), rotated_text)
    else:
        img_rgba = img.convert('RGBA')
        img_rgba.paste(rotated_text, (text_paste_x, text_paste_y), rotated_text)
        img = img_rgba.convert('RGB')
    
    return img

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
    
    # Checkmark coordinates (centered, aligned with circle white line)
    # Move slightly up to align with the circle's white outline
    check_x = center
    check_y = center + int(size * 0.02)  # Moved up from 0.08 to 0.02 to align with circle
    
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
    
    # Add FREE ribbon badge
    img = add_free_ribbon(img, size)
    
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

