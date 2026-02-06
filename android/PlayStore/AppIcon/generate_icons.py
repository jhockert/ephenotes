#!/usr/bin/env python3
"""
ephenotes Android Icon Generator

This script generates all required Android icon sizes from a source 512x512 image.
It creates icons for all density buckets (mdpi through xxxhdpi) and the Play Store.

Requirements:
    - Python 3.6+
    - Pillow (PIL): pip install Pillow

Usage:
    python generate_icons.py [source_image.png]
    
    If no source image is provided, it looks for 'icon-512.png' in the current directory.
"""

import os
import sys
from pathlib import Path
try:
    from PIL import Image
except ImportError:
    print("Error: Pillow library not found.")
    print("Install it with: pip install Pillow")
    sys.exit(1)


# Android icon sizes for different density buckets
ANDROID_ICON_SIZES = {
    'mdpi': 48,      # 1.0x
    'hdpi': 72,      # 1.5x
    'xhdpi': 96,     # 2.0x
    'xxhdpi': 144,   # 3.0x
    'xxxhdpi': 192,  # 4.0x
}

# Adaptive icon sizes (foreground and background layers)
ADAPTIVE_ICON_SIZES = {
    'mdpi': 108,     # 1.0x
    'hdpi': 162,     # 1.5x
    'xhdpi': 216,    # 2.0x
    'xxhdpi': 324,   # 3.0x
    'xxxhdpi': 432,  # 4.0x
}


def validate_source_image(image_path):
    """Validate that the source image meets requirements."""
    if not os.path.exists(image_path):
        print(f"Error: Source image not found: {image_path}")
        return False
    
    try:
        img = Image.open(image_path)
        width, height = img.size
        
        if width < 512 or height < 512:
            print(f"Error: Source image must be at least 512x512 pixels.")
            print(f"Current size: {width}x{height}")
            return False
        
        if width != height:
            print(f"Warning: Source image is not square ({width}x{height}).")
            print("It will be cropped to square.")
        
        return True
    except Exception as e:
        print(f"Error: Could not open source image: {e}")
        return False


def make_square(image):
    """Crop image to square if needed."""
    width, height = image.size
    if width == height:
        return image
    
    # Crop to center square
    size = min(width, height)
    left = (width - size) // 2
    top = (height - size) // 2
    right = left + size
    bottom = top + size
    
    return image.crop((left, top, right, bottom))


def generate_launcher_icons(source_image_path, output_base_dir):
    """Generate launcher icons for all density buckets."""
    print("\n📱 Generating launcher icons...")
    
    # Open and prepare source image
    source = Image.open(source_image_path)
    source = make_square(source)
    
    # Ensure source is at least 512x512
    if source.size[0] < 512:
        source = source.resize((512, 512), Image.LANCZOS)
    
    generated_count = 0
    
    for density, size in ANDROID_ICON_SIZES.items():
        # Resize image
        resized = source.resize((size, size), Image.LANCZOS)
        
        # Create output directory
        output_dir = os.path.join(output_base_dir, f'mipmap-{density}')
        os.makedirs(output_dir, exist_ok=True)
        
        # Save icon
        output_path = os.path.join(output_dir, 'ic_launcher.png')
        resized.save(output_path, 'PNG', optimize=True)
        
        print(f"  ✓ {density:8s} {size:3d}x{size:3d}px → {output_path}")
        generated_count += 1
    
    print(f"\n✅ Generated {generated_count} launcher icons")
    return generated_count


def generate_adaptive_icons(source_image_path, output_base_dir):
    """Generate adaptive icon foreground layers for all density buckets."""
    print("\n🎨 Generating adaptive icon layers...")
    
    # Open and prepare source image
    source = Image.open(source_image_path)
    source = make_square(source)
    
    # Ensure source is at least 512x512
    if source.size[0] < 512:
        source = source.resize((512, 512), Image.LANCZOS)
    
    generated_count = 0
    
    for density, size in ADAPTIVE_ICON_SIZES.items():
        # For adaptive icons, we need to add padding
        # The safe zone is 66dp out of 108dp (61%)
        # So we scale the icon to 61% and center it
        safe_zone_size = int(size * 0.61)
        
        # Resize icon to safe zone size
        resized = source.resize((safe_zone_size, safe_zone_size), Image.LANCZOS)
        
        # Create new image with full size and transparent background
        adaptive = Image.new('RGBA', (size, size), (0, 0, 0, 0))
        
        # Paste resized icon in center
        offset = (size - safe_zone_size) // 2
        adaptive.paste(resized, (offset, offset), resized if resized.mode == 'RGBA' else None)
        
        # Create output directory
        output_dir = os.path.join(output_base_dir, f'mipmap-{density}')
        os.makedirs(output_dir, exist_ok=True)
        
        # Save adaptive icon foreground
        output_path = os.path.join(output_dir, 'ic_launcher_foreground.png')
        adaptive.save(output_path, 'PNG', optimize=True)
        
        print(f"  ✓ {density:8s} {size:3d}x{size:3d}px → {output_path}")
        generated_count += 1
    
    print(f"\n✅ Generated {generated_count} adaptive icon layers")
    return generated_count


def generate_play_store_icon(source_image_path, output_dir):
    """Generate 512x512 Play Store icon."""
    print("\n🏪 Generating Play Store icon...")
    
    # Open and prepare source image
    source = Image.open(source_image_path)
    source = make_square(source)
    
    # Resize to 512x512 if needed
    if source.size[0] != 512:
        source = source.resize((512, 512), Image.LANCZOS)
    
    # Save Play Store icon
    os.makedirs(output_dir, exist_ok=True)
    output_path = os.path.join(output_dir, 'icon-512.png')
    source.save(output_path, 'PNG', optimize=True)
    
    file_size = os.path.getsize(output_path)
    file_size_kb = file_size / 1024
    
    print(f"  ✓ 512x512px → {output_path}")
    print(f"  ℹ File size: {file_size_kb:.1f} KB")
    
    if file_size > 1024 * 1024:  # 1 MB
        print(f"  ⚠ Warning: File size exceeds 1 MB limit!")
    
    print(f"\n✅ Generated Play Store icon")
    return 1


def create_adaptive_icon_xml(output_base_dir):
    """Create XML files for adaptive icons."""
    print("\n📄 Creating adaptive icon XML files...")
    
    # Create anydpi-v26 directory
    anydpi_dir = os.path.join(output_base_dir, 'mipmap-anydpi-v26')
    os.makedirs(anydpi_dir, exist_ok=True)
    
    # ic_launcher.xml
    launcher_xml = '''<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@color/ic_launcher_background"/>
    <foreground android:drawable="@mipmap/ic_launcher_foreground"/>
</adaptive-icon>
'''
    
    launcher_path = os.path.join(anydpi_dir, 'ic_launcher.xml')
    with open(launcher_path, 'w') as f:
        f.write(launcher_xml)
    print(f"  ✓ Created {launcher_path}")
    
    # ic_launcher_round.xml
    round_path = os.path.join(anydpi_dir, 'ic_launcher_round.xml')
    with open(round_path, 'w') as f:
        f.write(launcher_xml)
    print(f"  ✓ Created {round_path}")
    
    # Create colors.xml for background color
    values_dir = os.path.join(output_base_dir, '..', 'values')
    os.makedirs(values_dir, exist_ok=True)
    
    colors_path = os.path.join(values_dir, 'ic_launcher_colors.xml')
    if not os.path.exists(colors_path):
        colors_xml = '''<?xml version="1.0" encoding="utf-8"?>
<resources>
    <!-- Adaptive icon background color -->
    <color name="ic_launcher_background">#2196F3</color>
</resources>
'''
        with open(colors_path, 'w') as f:
            f.write(colors_xml)
        print(f"  ✓ Created {colors_path}")
    else:
        print(f"  ℹ Skipped {colors_path} (already exists)")
    
    print(f"\n✅ Created adaptive icon XML files")


def main():
    """Main function to generate all icons."""
    print("=" * 60)
    print("ephenotes Android Icon Generator")
    print("=" * 60)
    
    # Get source image path
    if len(sys.argv) > 1:
        source_image = sys.argv[1]
    else:
        source_image = 'icon-512.png'
    
    # Validate source image
    if not validate_source_image(source_image):
        sys.exit(1)
    
    print(f"\n📂 Source image: {source_image}")
    
    # Determine output directories
    script_dir = Path(__file__).parent
    android_res_dir = script_dir.parent.parent.parent / 'android' / 'app' / 'src' / 'main' / 'res'
    play_store_dir = script_dir
    
    print(f"📂 Android res directory: {android_res_dir}")
    print(f"📂 Play Store directory: {play_store_dir}")
    
    # Generate all icons
    total_generated = 0
    
    try:
        # Generate launcher icons
        total_generated += generate_launcher_icons(source_image, android_res_dir)
        
        # Generate adaptive icons
        total_generated += generate_adaptive_icons(source_image, android_res_dir)
        
        # Generate Play Store icon
        total_generated += generate_play_store_icon(source_image, play_store_dir)
        
        # Create adaptive icon XML files
        create_adaptive_icon_xml(android_res_dir)
        
        # Summary
        print("\n" + "=" * 60)
        print(f"✅ SUCCESS! Generated {total_generated} icon files")
        print("=" * 60)
        print("\nNext steps:")
        print("1. Review generated icons in Android Studio")
        print("2. Test adaptive icons on Android 8.0+ devices")
        print("3. Upload icon-512.png to Play Console")
        print("4. Build and test your app")
        print("\n")
        
    except Exception as e:
        print(f"\n❌ Error generating icons: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)


if __name__ == '__main__':
    main()
