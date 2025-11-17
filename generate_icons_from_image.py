#!/usr/bin/env python3
"""
Generate app icons from source image for Partner Check app
Optimizes and resizes the source image for Android and iOS
"""

from PIL import Image, ImageDraw, ImageFont
import os
import sys

def add_free_ribbon(img, size):
    """Add a 'FREE' ribbon badge to the upper right corner of the image"""
    # Store original mode and alpha channel if present
    original_mode = img.mode
    has_alpha = img.mode in ('RGBA', 'LA', 'P')
    alpha_channel = None
    
    if has_alpha:
        if img.mode == 'P':
            img = img.convert('RGBA')
        alpha_channel = img.split()[3] if img.mode == 'RGBA' else None
        # Convert to RGB for drawing, but we'll composite back
        img_rgb = Image.new('RGB', img.size, (255, 255, 255))
        img_rgb.paste(img, mask=img.split()[3] if img.mode == 'RGBA' else None)
        img = img_rgb
    
    # Ensure RGB mode for drawing
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
    # We need to calculate text position accounting for rotation
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
    
    # Convert back to RGBA if original had alpha channel
    if has_alpha and original_mode == 'RGBA':
        # Create new RGBA image
        img_rgba = Image.new('RGBA', img.size)
        img_rgba.paste(img)
        # Restore original alpha channel where ribbon wasn't drawn
        if alpha_channel:
            # Create a mask for the ribbon area (everything except ribbon should use original alpha)
            ribbon_mask = Image.new('L', img.size, 255)  # Start with full opacity
            # Draw ribbon area as opaque in the mask
            ribbon_draw = ImageDraw.Draw(ribbon_mask)
            ribbon_draw.polygon(ribbon_points, fill=255)  # Ribbon area is opaque
            # Composite: use original alpha everywhere except ribbon area
            # For simplicity, just use full opacity (we can refine this later)
            img_rgba.putalpha(Image.new('L', img.size, 255))  # Full opacity for now
        img = img_rgba
    elif has_alpha:
        img = img.convert('RGBA')
    
    return img

def resize_and_save(source_image, size, output_path, optimize=True, add_ribbon=True):
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
    
    # Add FREE ribbon badge
    if add_ribbon:
        img_resized = add_free_ribbon(img_resized, size)
    
    # Save with optimization
    img_resized.save(output_path, 'PNG', optimize=optimize)
    print(f"Generated: {output_path} ({size}x{size})")

def resize_and_save_foreground(source_image, size, output_path, optimize=True, add_ribbon=True):
    """Resize image to specified size and save as WebP foreground (preserves transparency)"""
    # Open and resize image
    img = Image.open(source_image)
    
    # Preserve transparency if present
    if img.mode == 'P':
        img = img.convert('RGBA')
    elif img.mode not in ('RGBA', 'LA'):
        # Convert to RGBA to support transparency
        img = img.convert('RGBA')
    
    # Resize with high-quality resampling
    img_resized = img.resize((size, size), Image.Resampling.LANCZOS)
    
    # Add FREE ribbon badge (will convert to RGB internally, then back to RGBA)
    if add_ribbon:
        img_resized = add_free_ribbon(img_resized, size)
        # Ensure it's RGBA after ribbon addition
        if img_resized.mode != 'RGBA':
            img_resized = img_resized.convert('RGBA')
    
    # Save as WebP with optimization
    img_resized.save(output_path, 'WEBP', optimize=optimize, quality=95)
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
        # Generate regular launcher icon
        resize_and_save(source_image, size, os.path.join(android_dir, 'ic_launcher.png'))
        # Generate foreground icon for adaptive icons (with transparency preserved)
        resize_and_save_foreground(source_image, size, os.path.join(android_dir, 'ic_launcher_foreground.webp'))
    
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

