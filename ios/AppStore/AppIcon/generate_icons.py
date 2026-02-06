#!/usr/bin/env python3
"""
ephenotes App Icon Generator

This script generates all required iOS app icon sizes from a master 1024x1024 icon.
Requires PIL (Pillow) library: pip install Pillow

Usage:
    python generate_icons.py master_icon.png

The script will create all required iOS app icon sizes and place them in the
correct directory structure for Xcode.
"""

import os
import sys
from PIL import Image, ImageDraw, ImageFilter
import argparse

# iOS App Icon sizes and their purposes
ICON_SIZES = {
    # App Store and Settings
    "Icon-App-1024x1024@1x.png": (1024, 1024),  # App Store
    
    # iPhone App Icons
    "Icon-App-60x60@2x.png": (120, 120),        # iPhone App @2x
    "Icon-App-60x60@3x.png": (180, 180),        # iPhone App @3x
    
    # iPad App Icons
    "Icon-App-76x76@1x.png": (76, 76),          # iPad App @1x
    "Icon-App-76x76@2x.png": (152, 152),        # iPad App @2x
    "Icon-App-83.5x83.5@2x.png": (167, 167),    # iPad Pro App @2x
    
    # iPhone Settings
    "Icon-App-29x29@1x.png": (29, 29),          # iPhone Settings @1x
    "Icon-App-29x29@2x.png": (58, 58),          # iPhone Settings @2x
    "Icon-App-29x29@3x.png": (87, 87),          # iPhone Settings @3x
    
    # iPhone Spotlight
    "Icon-App-40x40@2x.png": (80, 80),          # iPhone Spotlight @2x
    "Icon-App-40x40@3x.png": (120, 120),        # iPhone Spotlight @3x
    
    # iPad Settings and Spotlight
    "Icon-App-40x40@1x.png": (40, 40),          # iPad Spotlight @1x
    
    # Notifications
    "Icon-App-20x20@1x.png": (20, 20),          # iPad Notification @1x
    "Icon-App-20x20@2x.png": (40, 40),          # iPhone/iPad Notification @2x
    "Icon-App-20x20@3x.png": (60, 60),          # iPhone Notification @3x
}

def create_master_icon(output_path, size=1024):
    """
    Create a master app icon for ephenotes.
    This creates a simple design that can be used as the base for all sizes.
    """
    # Create a new image with white background
    img = Image.new('RGB', (size, size), '#FFFFFF')
    draw = ImageDraw.Draw(img)
    
    # Calculate proportional sizes
    note_width = int(size * 0.7)
    note_height = int(size * 0.55)
    corner_radius = int(size * 0.08)
    
    # Center the note
    x = (size - note_width) // 2
    y = (size - note_height) // 2
    
    # Draw main note shape (rounded rectangle)
    # Since PIL doesn't have native rounded rectangle, we'll create one
    note_color = '#4CAF50'  # Material Green
    
    # Create rounded rectangle by drawing rectangles and circles
    draw.rectangle([x + corner_radius, y, x + note_width - corner_radius, y + note_height], fill=note_color)
    draw.rectangle([x, y + corner_radius, x + note_width, y + note_height - corner_radius], fill=note_color)
    
    # Draw corners
    draw.ellipse([x, y, x + 2*corner_radius, y + 2*corner_radius], fill=note_color)
    draw.ellipse([x + note_width - 2*corner_radius, y, x + note_width, y + 2*corner_radius], fill=note_color)
    draw.ellipse([x, y + note_height - 2*corner_radius, x + 2*corner_radius, y + note_height], fill=note_color)
    draw.ellipse([x + note_width - 2*corner_radius, y + note_height - 2*corner_radius, x + note_width, y + note_height], fill=note_color)
    
    # Add priority indicator (orange circle)
    if size >= 60:  # Only add for larger sizes
        dot_size = int(size * 0.12)
        dot_x = x + note_width - dot_size - int(size * 0.05)
        dot_y = y + int(size * 0.05)
        draw.ellipse([dot_x, dot_y, dot_x + dot_size, dot_y + dot_size], fill='#FF9800')
    
    # Add subtle lines for larger sizes
    if size >= 120:
        line_color = 'rgba(255,255,255,0.3)'
        line_width = int(size * 0.004)
        line_length = int(note_width * 0.6)
        line_start_x = x + int(note_width * 0.2)
        
        for i in range(3):
            line_y = y + int(note_height * 0.3) + i * int(size * 0.08)
            draw.rectangle([line_start_x, line_y, line_start_x + line_length, line_y + line_width], 
                         fill=(255, 255, 255, 80))
    
    return img

def resize_icon(master_image, size, use_lanczos=True):
    """
    Resize the master icon to the specified size with high quality.
    """
    if use_lanczos:
        return master_image.resize(size, Image.Resampling.LANCZOS)
    else:
        return master_image.resize(size, Image.Resampling.NEAREST)

def generate_all_icons(master_icon_path=None, output_dir="ios/Runner/Assets.xcassets/AppIcon.appiconset"):
    """
    Generate all required iOS app icon sizes.
    """
    # Create output directory if it doesn't exist
    os.makedirs(output_dir, exist_ok=True)
    
    # Load or create master icon
    if master_icon_path and os.path.exists(master_icon_path):
        print(f"Loading master icon from {master_icon_path}")
        master_img = Image.open(master_icon_path)
        if master_img.size != (1024, 1024):
            print("Resizing master icon to 1024x1024")
            master_img = master_img.resize((1024, 1024), Image.Resampling.LANCZOS)
    else:
        print("Creating new master icon...")
        master_img = create_master_icon("temp_master.png")
        master_img.save("temp_master.png")
        print("Master icon saved as temp_master.png")
    
    # Generate all required sizes
    print(f"Generating {len(ICON_SIZES)} icon sizes...")
    
    for filename, size in ICON_SIZES.items():
        output_path = os.path.join(output_dir, filename)
        
        # Resize the master image
        resized_img = resize_icon(master_img, size)
        
        # Save the resized image
        resized_img.save(output_path, "PNG", optimize=True)
        print(f"Created {filename} ({size[0]}x{size[1]})")
    
    print(f"\nAll icons generated successfully in {output_dir}")
    print("\nNext steps:")
    print("1. Open ios/Runner.xcworkspace in Xcode")
    print("2. Verify all icons appear correctly in Assets.xcassets")
    print("3. Build and test the app to ensure icons display properly")

def update_contents_json(output_dir="ios/Runner/Assets.xcassets/AppIcon.appiconset"):
    """
    Update the Contents.json file with the correct icon mappings.
    """
    contents_json = {
        "images": [
            {
                "size": "20x20",
                "idiom": "iphone",
                "filename": "Icon-App-20x20@2x.png",
                "scale": "2x"
            },
            {
                "size": "20x20",
                "idiom": "iphone",
                "filename": "Icon-App-20x20@3x.png",
                "scale": "3x"
            },
            {
                "size": "29x29",
                "idiom": "iphone",
                "filename": "Icon-App-29x29@1x.png",
                "scale": "1x"
            },
            {
                "size": "29x29",
                "idiom": "iphone",
                "filename": "Icon-App-29x29@2x.png",
                "scale": "2x"
            },
            {
                "size": "29x29",
                "idiom": "iphone",
                "filename": "Icon-App-29x29@3x.png",
                "scale": "3x"
            },
            {
                "size": "40x40",
                "idiom": "iphone",
                "filename": "Icon-App-40x40@2x.png",
                "scale": "2x"
            },
            {
                "size": "40x40",
                "idiom": "iphone",
                "filename": "Icon-App-40x40@3x.png",
                "scale": "3x"
            },
            {
                "size": "60x60",
                "idiom": "iphone",
                "filename": "Icon-App-60x60@2x.png",
                "scale": "2x"
            },
            {
                "size": "60x60",
                "idiom": "iphone",
                "filename": "Icon-App-60x60@3x.png",
                "scale": "3x"
            },
            {
                "size": "20x20",
                "idiom": "ipad",
                "filename": "Icon-App-20x20@1x.png",
                "scale": "1x"
            },
            {
                "size": "20x20",
                "idiom": "ipad",
                "filename": "Icon-App-20x20@2x.png",
                "scale": "2x"
            },
            {
                "size": "29x29",
                "idiom": "ipad",
                "filename": "Icon-App-29x29@1x.png",
                "scale": "1x"
            },
            {
                "size": "29x29",
                "idiom": "ipad",
                "filename": "Icon-App-29x29@2x.png",
                "scale": "2x"
            },
            {
                "size": "40x40",
                "idiom": "ipad",
                "filename": "Icon-App-40x40@1x.png",
                "scale": "1x"
            },
            {
                "size": "40x40",
                "idiom": "ipad",
                "filename": "Icon-App-40x40@2x.png",
                "scale": "2x"
            },
            {
                "size": "76x76",
                "idiom": "ipad",
                "filename": "Icon-App-76x76@1x.png",
                "scale": "1x"
            },
            {
                "size": "76x76",
                "idiom": "ipad",
                "filename": "Icon-App-76x76@2x.png",
                "scale": "2x"
            },
            {
                "size": "83.5x83.5",
                "idiom": "ipad",
                "filename": "Icon-App-83.5x83.5@2x.png",
                "scale": "2x"
            },
            {
                "size": "1024x1024",
                "idiom": "ios-marketing",
                "filename": "Icon-App-1024x1024@1x.png",
                "scale": "1x"
            }
        ],
        "info": {
            "version": 1,
            "author": "xcode"
        }
    }
    
    import json
    contents_path = os.path.join(output_dir, "Contents.json")
    with open(contents_path, 'w') as f:
        json.dump(contents_json, f, indent=2)
    
    print(f"Updated {contents_path}")

def main():
    parser = argparse.ArgumentParser(description='Generate iOS app icons for ephenotes')
    parser.add_argument('master_icon', nargs='?', help='Path to master 1024x1024 icon (optional)')
    parser.add_argument('--output-dir', default='ios/Runner/Assets.xcassets/AppIcon.appiconset',
                       help='Output directory for generated icons')
    parser.add_argument('--create-master', action='store_true',
                       help='Create a new master icon instead of using existing one')
    
    args = parser.parse_args()
    
    try:
        if args.create_master:
            generate_all_icons(None, args.output_dir)
        else:
            generate_all_icons(args.master_icon, args.output_dir)
        
        update_contents_json(args.output_dir)
        
    except ImportError:
        print("Error: PIL (Pillow) library is required.")
        print("Install it with: pip install Pillow")
        sys.exit(1)
    except Exception as e:
        print(f"Error generating icons: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()