#!/usr/bin/env python3
"""
Generate Android launcher icons from source image
Creates ic_launcher and ic_launcher_round in webp format for all densities
"""

from PIL import Image
import os
import sys

def resize_and_save_webp(source_image, size, output_path, optimize=True):
    """Resize image to specified size and save as WebP"""
    # Open and resize image
    img = Image.open(source_image)
    
    # Convert to RGBA to preserve transparency if present
    if img.mode == 'P':
        img = img.convert('RGBA')
    elif img.mode not in ('RGBA', 'LA'):
        # If no transparency, convert to RGB for better compression
        img = img.convert('RGB')
    
    # Resize with high-quality resampling
    img_resized = img.resize((size, size), Image.Resampling.LANCZOS)
    
    # Save as WebP
    img_resized.save(output_path, 'WEBP', optimize=optimize, quality=95)
    print(f"Generated: {output_path} ({size}x{size})")

def create_round_icon(source_image, size, output_path, optimize=True):
    """Create a round icon by adding transparent corners"""
    # Open and resize image
    img = Image.open(source_image)
    
    # Convert to RGBA
    if img.mode == 'P':
        img = img.convert('RGBA')
    elif img.mode not in ('RGBA', 'LA'):
        img = img.convert('RGBA')
    
    # Resize with high-quality resampling
    img_resized = img.resize((size, size), Image.Resampling.LANCZOS)
    
    # Create a mask for the round shape
    from PIL import ImageDraw
    mask = Image.new('L', (size, size), 0)
    draw = ImageDraw.Draw(mask)
    draw.ellipse([0, 0, size, size], fill=255)
    
    # Apply the mask to create round corners
    if img_resized.mode == 'RGBA':
        # Create a new image with alpha channel
        rounded = Image.new('RGBA', (size, size), (0, 0, 0, 0))
        rounded.paste(img_resized, (0, 0))
        rounded.putalpha(mask)
    else:
        rounded = img_resized.copy()
        rounded.putalpha(mask)
    
    # Save as WebP
    rounded.save(output_path, 'WEBP', optimize=optimize, quality=95)
    print(f"Generated: {output_path} ({size}x{size}, round)")

def main():
    source_image = 'assets/app_icon.png'
    
    if not os.path.exists(source_image):
        print(f"Error: Source image '{source_image}' not found!")
        sys.exit(1)
    
    print(f"Processing source image: {source_image}\n")
    
    # Android icon sizes for different densities
    # These are the sizes for ic_launcher (not foreground)
    android_sizes = [
        (48, 'mipmap-mdpi'),
        (72, 'mipmap-hdpi'),
        (96, 'mipmap-xhdpi'),
        (144, 'mipmap-xxhdpi'),
        (192, 'mipmap-xxxhdpi'),
    ]
    
    print("Generating Android launcher icons...")
    for size, folder in android_sizes:
        android_dir = f'android/app/src/main/res/{folder}'
        os.makedirs(android_dir, exist_ok=True)
        
        # Generate ic_launcher.webp
        ic_launcher_path = os.path.join(android_dir, 'ic_launcher.webp')
        resize_and_save_webp(source_image, size, ic_launcher_path)
        
        # Generate ic_launcher_round.webp
        ic_launcher_round_path = os.path.join(android_dir, 'ic_launcher_round.webp')
        create_round_icon(source_image, size, ic_launcher_round_path)
    
    print("\n✅ All Android launcher icons generated successfully!")
    print(f"🤖 Android icons: android/app/src/main/res/mipmap-*/")
    print("   - ic_launcher.webp (square)")
    print("   - ic_launcher_round.webp (round)")

if __name__ == '__main__':
    main()

