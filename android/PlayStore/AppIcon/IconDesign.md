# ephenotes Android App Icon Design Guide

## Overview
This guide provides specifications and guidelines for creating the ephenotes app icon for Google Play Store and Android devices.

## Icon Requirements

### Play Store Icon
**Size:** 512 x 512 pixels  
**Format:** 32-bit PNG with alpha channel  
**Color Space:** sRGB  
**File Size:** < 1 MB  
**Filename:** `icon-512.png`

### Adaptive Icon (Android 8.0+)
**Foreground:** 108 x 108 dp (432 x 432 px @ xxxhdpi)  
**Background:** 108 x 108 dp (432 x 432 px @ xxxhdpi)  
**Safe Zone:** 66 x 66 dp (264 x 264 px @ xxxhdpi) - center circle  
**Format:** PNG or vector drawable (XML)

### Legacy Icon Sizes
- **xxxhdpi (4.0x):** 192 x 192 px
- **xxhdpi (3.0x):** 144 x 144 px
- **xhdpi (2.0x):** 96 x 96 px
- **hdpi (1.5x):** 72 x 72 px
- **mdpi (1.0x):** 48 x 48 px

## Design Principles

### Material Design Guidelines
- **Simple:** Clear, recognizable shape
- **Bold:** Strong visual presence
- **Unique:** Distinctive from competitors
- **Scalable:** Works at all sizes
- **Consistent:** Matches app's visual identity

### ephenotes Brand Identity
- **Privacy-focused:** Conveys security and trust
- **Productivity:** Suggests efficiency and organization
- **Simplicity:** Clean, uncluttered design
- **Modern:** Contemporary, not dated

## Icon Concept

### Primary Concept: Note with Priority Badge

**Visual Elements:**
1. **Note Sheet:** Simplified note paper or card
2. **Priority Indicator:** Star, flag, or badge
3. **Color:** Brand color (primary blue or accent color)
4. **Style:** Flat design with subtle depth

**Symbolism:**
- Note sheet represents note-taking
- Priority badge represents organization
- Clean design represents simplicity
- Solid colors represent privacy/security

### Alternative Concepts

**Concept 2: Stylized "E"**
- Letter "E" formed by note lines
- Priority dots or stars integrated
- Minimalist, modern approach

**Concept 3: Checklist with Star**
- Simplified checklist icon
- Star indicating priority
- Productivity-focused

## Color Palette

### Primary Colors
- **Brand Blue:** #2196F3 (Material Blue 500)
- **Dark Blue:** #1976D2 (Material Blue 700)
- **Light Blue:** #BBDEFB (Material Blue 100)

### Accent Colors
- **Priority Red:** #F44336 (Material Red 500)
- **Priority Orange:** #FF9800 (Material Orange 500)
- **Priority Yellow:** #FFC107 (Material Amber 500)

### Background
- **White:** #FFFFFF (for light backgrounds)
- **Dark:** #212121 (for dark backgrounds)
- **Gradient:** Optional subtle gradient

## Design Specifications

### Safe Zone
- **Circular Mask:** 66dp diameter (center)
- **Critical Content:** Keep within safe zone
- **Padding:** 8dp minimum from edges
- **Bleed:** Design can extend to edges but may be cropped

### Visual Weight
- **Foreground:** Main icon elements
- **Background:** Solid color or subtle pattern
- **Contrast:** Ensure visibility on all backgrounds
- **Depth:** Subtle shadow or elevation (optional)

### Accessibility
- **Contrast Ratio:** Minimum 3:1 against background
- **Color Blindness:** Test with color blindness simulators
- **Recognizability:** Identifiable without color
- **Size:** Readable at 48x48 px

## Adaptive Icon Implementation

### Foreground Layer
```xml
<!-- res/drawable/ic_launcher_foreground.xml -->
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="108dp"
    android:height="108dp"
    android:viewportWidth="108"
    android:viewportHeight="108">
    
    <!-- Icon design goes here -->
    <!-- Keep within 66dp safe zone (21-87 coordinates) -->
    
</vector>
```

### Background Layer
```xml
<!-- res/drawable/ic_launcher_background.xml -->
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="108dp"
    android:height="108dp"
    android:viewportWidth="108"
    android:viewportHeight="108">
    
    <path
        android:fillColor="#2196F3"
        android:pathData="M0,0h108v108h-108z"/>
        
</vector>
```

### Mipmap Configuration
```xml
<!-- res/mipmap-anydpi-v26/ic_launcher.xml -->
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@drawable/ic_launcher_background"/>
    <foreground android:drawable="@drawable/ic_launcher_foreground"/>
</adaptive-icon>
```

## Icon Variations

### Light Theme Icon
- Bright, vibrant colors
- High contrast
- Optimized for light backgrounds

### Dark Theme Icon
- Slightly muted colors
- Adjusted contrast
- Optimized for dark backgrounds

### Monochrome Icon (Android 13+)
- Single color version
- For themed icons
- Follows system theme

## Testing Checklist

### Visual Testing
- [ ] Test at all required sizes (48px to 512px)
- [ ] Test on light and dark backgrounds
- [ ] Test with different launcher shapes (circle, square, rounded square)
- [ ] Test with color blindness simulators
- [ ] Test in grayscale

### Device Testing
- [ ] Test on various Android devices
- [ ] Test on different launcher apps
- [ ] Test adaptive icon on Android 8.0+
- [ ] Test monochrome icon on Android 13+
- [ ] Test in app drawer and home screen

### Context Testing
- [ ] Compare with competitor icons
- [ ] Test in Play Store search results
- [ ] Test in Play Store app listing
- [ ] Test in notification shade
- [ ] Test in recent apps screen

## Design Tools

### Recommended Tools
- **Adobe Illustrator:** Vector design
- **Figma:** Collaborative design
- **Sketch:** Mac-based design
- **Inkscape:** Free vector editor
- **Android Studio:** Icon preview and testing

### Useful Resources
- **Material Icons:** https://fonts.google.com/icons
- **Android Asset Studio:** https://romannurik.github.io/AndroidAssetStudio/
- **Adaptive Icon Preview:** Android Studio Image Asset tool
- **Color Palette Generator:** https://material.io/design/color/

## Export Settings

### Play Store Icon (512x512)
- **Format:** PNG
- **Color Mode:** RGB
- **Bit Depth:** 32-bit (with alpha)
- **Compression:** PNG-8 or PNG-24
- **Optimization:** Use ImageOptim or similar

### Adaptive Icon Layers
- **Format:** Vector XML (preferred) or PNG
- **Size:** 432x432 px (xxxhdpi)
- **Safe Zone:** 264x264 px center circle
- **Export:** Use Android Studio Image Asset tool

### Legacy Icons
- **Format:** PNG
- **Sizes:** All density buckets (mdpi to xxxhdpi)
- **Naming:** `ic_launcher.png`
- **Location:** `res/mipmap-{density}/`

## Icon Generation Script

### Python Script for Icon Sizes
```python
# generate_icons.py
from PIL import Image
import os

def generate_android_icons(source_image_path):
    """Generate all required Android icon sizes from source image."""
    
    sizes = {
        'mdpi': 48,
        'hdpi': 72,
        'xhdpi': 96,
        'xxhdpi': 144,
        'xxxhdpi': 192,
    }
    
    # Open source image (should be 512x512 or larger)
    source = Image.open(source_image_path)
    
    # Generate each size
    for density, size in sizes.items():
        # Resize image
        resized = source.resize((size, size), Image.LANCZOS)
        
        # Create output directory
        output_dir = f'../../../android/app/src/main/res/mipmap-{density}'
        os.makedirs(output_dir, exist_ok=True)
        
        # Save icon
        output_path = os.path.join(output_dir, 'ic_launcher.png')
        resized.save(output_path, 'PNG', optimize=True)
        print(f'Generated {density}: {size}x{size}px')
    
    print('All icons generated successfully!')

if __name__ == '__main__':
    # Source image should be 512x512 or larger
    generate_android_icons('icon-512.png')
```

### Usage
```bash
# Install Pillow if needed
pip install Pillow

# Run script
python generate_icons.py
```

## Quality Checklist

### Before Submission
- [ ] Icon is 512x512 pixels
- [ ] Icon has transparent background (if applicable)
- [ ] Icon is recognizable at small sizes
- [ ] Icon follows Material Design guidelines
- [ ] Icon is unique and memorable
- [ ] Icon represents the app's purpose
- [ ] Icon works on light and dark backgrounds
- [ ] Icon has been tested on real devices
- [ ] All required sizes generated
- [ ] Files are optimized for size

### Play Store Requirements
- [ ] 512x512 PNG with alpha
- [ ] File size under 1 MB
- [ ] High quality, no pixelation
- [ ] No white or transparent borders
- [ ] Follows content policy
- [ ] Not misleading or deceptive
- [ ] Appropriate for all ages

## Common Mistakes to Avoid

### Design Mistakes
- ❌ Too complex or detailed
- ❌ Text that's unreadable at small sizes
- ❌ Too many colors or gradients
- ❌ Looks like another app's icon
- ❌ Doesn't work in monochrome
- ❌ Critical elements outside safe zone

### Technical Mistakes
- ❌ Wrong dimensions or aspect ratio
- ❌ Low resolution or pixelated
- ❌ Wrong file format
- ❌ Excessive file size
- ❌ Missing alpha channel
- ❌ Incorrect color space

## Iteration and Feedback

### Design Process
1. **Concept Sketches:** Multiple rough ideas
2. **Digital Mockups:** Refined concepts
3. **Size Testing:** Test at all sizes
4. **Feedback:** Get team and user feedback
5. **Refinement:** Iterate based on feedback
6. **Final Testing:** Comprehensive testing
7. **Approval:** Final sign-off

### Feedback Questions
- Is the icon recognizable?
- Does it represent the app well?
- Is it unique and memorable?
- Does it work at all sizes?
- Is it appropriate for the target audience?
- Does it stand out in the Play Store?

## Version History

### Version 1.0 (Current)
- Initial icon design
- Material Design 3 style
- Adaptive icon support
- Monochrome variant

### Future Versions
- Seasonal variations (optional)
- Special event icons (optional)
- A/B testing variants
- Localized versions (if needed)

---

**Status:** 📋 Design Specifications Ready  
**Next Step:** Create icon design  
**Designer:** [To be assigned]  
**Review Date:** Before Play Store submission  

**Last Updated:** February 4, 2026
