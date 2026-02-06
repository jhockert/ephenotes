# App Store Screenshots Guide

## Overview
This guide covers creating compelling App Store screenshots for ephenotes across all required device sizes.

## Required Screenshot Sizes

### iPhone Screenshots
- **iPhone 6.7"** (iPhone 14 Pro Max, 15 Pro Max): 1290 x 2796 pixels
- **iPhone 6.5"** (iPhone 11 Pro Max, XS Max): 1242 x 2688 pixels  
- **iPhone 5.5"** (iPhone 8 Plus, 7 Plus): 1242 x 2208 pixels

### iPad Screenshots
- **iPad Pro 12.9"** (6th gen): 2048 x 2732 pixels
- **iPad Pro 11"** (4th gen): 1668 x 2388 pixels

## Screenshot Strategy

### Screenshot Set (5 screenshots per device)

#### Screenshot 1: Main Screen - Note List
**Purpose:** Show the core interface and note organization  
**Content:**
- 6-8 sample notes with different priorities and colors
- Mix of pinned and unpinned notes
- Show priority-based sorting (High → Medium → Low)
- Floating action button visible

**Sample Notes:**
- 📌 "Team meeting at 3pm - discuss Q1 goals" (High, Red, Pinned)
- 📌 "Buy groceries: milk, bread, eggs" (Medium, Blue, Pinned)
- "Call dentist to schedule cleaning" (High, Orange)
- "Research vacation destinations" (Low, Green)
- "Finish project proposal draft" (High, Purple)
- "Water plants in office" (Low, Yellow)

#### Screenshot 2: Note Creation/Editing
**Purpose:** Demonstrate the note creation process  
**Content:**
- Note editor screen open
- Partially typed note showing character count
- Priority selector visible
- Color picker showing available options
- Keyboard visible (if space allows)

**Sample Content:**
- Text: "Prepare presentation for client meeting tomorrow - include Q4 results and new product roadmap"
- Character count: "98/140"
- Priority: High selected
- Color: Blue selected

#### Screenshot 3: Search Functionality
**Purpose:** Show powerful search capabilities  
**Content:**
- Search bar active with query typed
- Filtered results showing matching notes
- Pinned notes appearing first in results
- Search highlighting (if possible)

**Sample Search:**
- Query: "meeting"
- Results showing 3-4 relevant notes
- Mix of priorities and colors in results

#### Screenshot 4: Archive Screen
**Purpose:** Demonstrate archive and restore functionality  
**Content:**
- Archive screen with completed notes
- Restore button visible on notes
- Mix of archived notes with different priorities
- Clear navigation back to main screen

**Sample Archived Notes:**
- "Completed project documentation" (High, Green)
- "Submitted expense report" (Medium, Blue)
- "Finished reading quarterly report" (Low, Purple)

#### Screenshot 5: Priority & Organization
**Purpose:** Highlight the unique priority-based organization  
**Content:**
- Main screen with clear priority groupings
- Visual emphasis on priority badges
- Color coding demonstration
- Pin functionality highlighted

**Visual Elements:**
- Priority badges clearly visible
- Color variety across notes
- Pin icons on pinned notes
- Clean, organized layout

## Screenshot Content Guidelines

### Sample Note Content
Use realistic, relatable content that demonstrates the app's use cases:

**Work/Professional:**
- "Team standup at 9am - discuss sprint progress"
- "Review contract terms before Friday deadline"
- "Prepare Q1 budget presentation slides"
- "Schedule one-on-one meetings with team"

**Personal/Life:**
- "Pick up dry cleaning after work"
- "Call mom to check on weekend plans"
- "Research new coffee maker options"
- "Book dentist appointment for next month"

**Creative/Ideas:**
- "App idea: habit tracker with social features"
- "Blog post topic: productivity tips for remote work"
- "Gift ideas for Sarah's birthday next week"
- "Weekend project: organize home office space"

### Visual Design Principles

#### Clean and Uncluttered
- Use white space effectively
- Don't overcrowd with too many notes
- Ensure text is readable at thumbnail size

#### Consistent Branding
- Use app's color palette
- Maintain consistent typography
- Show app's personality (clean, efficient, friendly)

#### Realistic Usage
- Show genuine use cases
- Avoid Lorem ipsum or placeholder text
- Demonstrate real workflows

#### Accessibility Friendly
- High contrast text
- Readable font sizes
- Clear visual hierarchy

## Screenshot Capture Process

### Device Setup
1. **Clean Install:** Fresh app installation
2. **Sample Data:** Pre-populate with realistic notes
3. **Settings:** Ensure proper display settings
4. **Status Bar:** Clean status bar (full battery, good signal)

### Capture Settings
- **Format:** PNG (highest quality)
- **Orientation:** Portrait for iPhone, both orientations for iPad
- **Resolution:** Native device resolution
- **Color Space:** sRGB

### Tools and Methods

#### iOS Simulator (Recommended)
```bash
# Launch specific device simulators
xcrun simctl list devices
xcrun simctl boot "iPhone 14 Pro Max"
xcrun simctl boot "iPad Pro (12.9-inch) (6th generation)"

# Capture screenshots
xcrun simctl io booted screenshot screenshot.png
```

#### Physical Devices
- Use built-in screenshot functionality
- Ensure clean status bar
- Transfer via AirDrop or cable

#### Third-Party Tools
- **Screenshot Path:** Automated screenshot generation
- **Fastlane:** Command-line screenshot automation
- **App Store Screenshot:** Specialized tools

## Screenshot Optimization

### File Optimization
- **Format:** PNG (required by App Store)
- **Compression:** Optimize file size without quality loss
- **Naming:** Descriptive filenames with device info

### Quality Checklist
- [ ] Sharp, high-resolution images
- [ ] Accurate colors matching app design
- [ ] No pixelation or artifacts
- [ ] Proper aspect ratios
- [ ] Clean status bars

### App Store Requirements
- [ ] Minimum 3 screenshots per device size
- [ ] Maximum 10 screenshots per device size
- [ ] Portrait orientation for iPhone
- [ ] Both orientations acceptable for iPad
- [ ] No overlaid text or graphics
- [ ] Show actual app interface

## Localization Considerations

### Text Content
- Use English for initial release
- Plan for future localization
- Avoid culture-specific references
- Keep text concise and clear

### Visual Elements
- Universal icons and symbols
- Consistent color meanings
- Accessible design patterns

## Screenshot File Organization

```
ios/AppStore/Screenshots/
├── iPhone_6.7/
│   ├── 01_main_screen.png
│   ├── 02_note_editor.png
│   ├── 03_search.png
│   ├── 04_archive.png
│   └── 05_priority_organization.png
├── iPhone_6.5/
│   └── [same 5 screenshots]
├── iPhone_5.5/
│   └── [same 5 screenshots]
├── iPad_12.9/
│   └── [same 5 screenshots]
└── iPad_11/
    └── [same 5 screenshots]
```

## Testing Screenshots

### Preview Testing
- [ ] View at thumbnail size (App Store search results)
- [ ] Check readability on different backgrounds
- [ ] Verify visual hierarchy is clear
- [ ] Test on various display settings

### Feedback Collection
- [ ] Internal team review
- [ ] Target user feedback
- [ ] A/B testing different approaches
- [ ] Competitor comparison

## Screenshot Automation Script

Create a script to automate screenshot capture:

```bash
#!/bin/bash
# screenshot_capture.sh

DEVICES=("iPhone 14 Pro Max" "iPhone 11 Pro Max" "iPhone 8 Plus" "iPad Pro (12.9-inch) (6th generation)" "iPad Pro (11-inch) (4th generation)")
SCREENSHOTS=("main_screen" "note_editor" "search" "archive" "priority_organization")

for device in "${DEVICES[@]}"; do
    echo "Capturing screenshots for $device"
    xcrun simctl boot "$device"
    
    # Wait for boot
    sleep 10
    
    # Launch app and capture screenshots
    # (This would need to be customized based on your testing setup)
    
    xcrun simctl shutdown "$device"
done
```

## Final Checklist

### Before Upload
- [ ] All required device sizes captured
- [ ] 5 screenshots per device minimum
- [ ] High quality, sharp images
- [ ] Realistic, compelling content
- [ ] Consistent visual branding
- [ ] No placeholder or test content
- [ ] Proper file naming and organization
- [ ] Optimized file sizes
- [ ] Preview tested at various sizes

### App Store Connect Upload
- [ ] Screenshots uploaded to correct device categories
- [ ] Preview looks good in App Store Connect
- [ ] Screenshots display properly in preview
- [ ] All device sizes have complete sets
- [ ] Ready for App Store review

---

**Status:** Ready for screenshot capture  
**Next Step:** Set up sample data and begin capturing screenshots  
**Tools Needed:** iOS Simulator, image optimization software