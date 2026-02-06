# ephenotes - Technical Specification

## Project Overview

**App Name**: ephenotes
**Version**: 1.0.0
**Platform**: iOS & Android
**Framework**: Flutter
**Purpose**: A modern, user-friendly virtual post-it notes app for quick note-taking without organizational overhead

### Core Value Proposition
ephenotes provides smartphone users with a frictionless way to capture and manage quick notes throughout their busy day. Unlike traditional note-taking apps that require folder structures and organization, ephenotes embraces simplicity with visual post-it notes that can be quickly added, categorized by color/icon, and archived when complete.

### Target Audience
Smartphone users (iOS and Android) who need quick, on-the-go note capture without the complexity of traditional note-taking applications.

---

## Technical Stack

### Framework & Language
- **Flutter** (Dart)
- Minimum SDK: Flutter 3.16+
- Dart 3.0+

### Architecture Pattern
- **BLoC (Business Logic Component)** pattern for state management
- **Repository Pattern** for data layer abstraction
- **Clean Architecture** principles

### Local Storage
- **Hive** or **sqflite** for local database
- **shared_preferences** for app settings
- No backend services required (v1.0)

### Key Dependencies (Proposed)
```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_bloc: ^8.1.3
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  uuid: ^4.0.0
  intl: ^0.18.0
  flutter_slidable: ^3.0.0
  reorderable_list: ^1.0.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
  bloc_test: ^9.1.0
  mocktail: ^1.0.0
  hive_generator: ^2.0.0
  build_runner: ^2.4.0
```

---

## Feature Specifications

### 1. Note Management

#### 1.1 Create Note
- **Trigger**: Tap floating "+" button (always visible)
- **Character Limit**: 140 characters (configurable for future versions)
- **Required Fields**: Note text content
- **Optional Fields**: Color, icon category, priority level
- **Defaults**:
  - Color: Classic yellow (#FFF59D)
  - Priority: Medium
  - Icon: None
  - Created timestamp: Auto-generated

#### 1.2 Edit Note
- **Trigger**: Tap on note card
- **Editable Fields**:
  - Text content
  - Color selection (10 options)
  - Icon category
  - Priority level (High/Medium/Low)
  - Text formatting (bold, italic, underline)
  - Font size (Small/Medium/Large)
  - List type (none, bullet points, checkboxes)

#### 1.3 Delete/Archive Note
- **Archive**: Swipe left/right on note card
  - Moves note to Archive view
  - Recoverable
  - Shows undo snackbar (3 second window)
  - Removes pin status (isPinned = false)
- **Permanent Delete**: Only available from Archive view
  - Requires confirmation dialog:
    - **Title**: "Delete Note?"
    - **Message**: "This note will be permanently deleted. This action cannot be undone."
    - **Buttons**: "Cancel" | "Delete" (red/destructive style)
  - Irreversible action

#### 1.4 Reorder Notes
- **Trigger**: Long-press and drag note card
- **Visual Feedback**:
  - Note lifts with shadow
  - Other notes shift with animation
  - "Sticking" animation when dropped
- **Persistence**: Manual order saved to local storage

### 2. Note Organization

#### 2.1 Priority System
- **Levels**: High, Medium, Low
- **Visual Indicator**: Text label on note card
  - High: Red text "HIGH"
  - Medium: Orange text "MED"
  - Low: Green text "LOW"
- **Sorting**: Notes can be sorted by priority (High → Low)

#### 2.2 Color Coding
- **Purpose**: Visual categorization
- **Color Palette** (10 colors):
  1. Classic Yellow: #FFF59D
  2. Coral Pink: #FF8A80
  3. Sky Blue: #82B1FF
  4. Mint Green: #B9F6CA
  5. Lavender: #E1BEE7
  6. Peach: #FFCCBC
  7. Teal: #A7FFEB
  8. Light Gray: #CFD8DC
  9. Lemon: #F4FF81
  10. Rose: #F8BBD0

#### 2.3 Icon Categories
- **Purpose**: Functional categorization
- **Categories**:
  - Work: Briefcase icon
  - Personal: Home icon
  - Shopping: Cart icon
  - Health: Heart icon
  - Finance: Dollar icon
  - Important: Star icon
  - Ideas: Lightbulb icon
  - None: No icon (default)

#### 2.5 Sorting Options
- **Manual**: User-defined order (via drag & drop)
- **By Priority**: High → Medium → Low
- **By Age**: Newest first or Oldest first
- **By Color**: Grouped by color value
- **Persistence**: Last selected sort preference saved

### 3. Text Formatting

#### 3.1 Basic Formatting
- **Bold**: Toggle button in editor
- **Italic**: Toggle button in editor
- **Underline**: Toggle button in editor
- **Font Size**: Small (12pt), Medium (14pt), Large (16pt)
- **Combining Styles**: Bold, italic, and underline can be combined
- **Persistence**: All formatting persisted in note content

#### 3.2 List Formatting
- **Bullet Points**: Unordered list items
- **Checkboxes**: Interactive checkboxes that can be marked complete
  - Checked items shown with strikethrough
  - Checkbox state persisted
- **List Scope**: List formatting applies to entire note content
- **Text Mixing**: Cannot mix regular text with list items (one mode per note)
- **Formatting in Lists**: Bold/italic/underline can be applied to individual list items

### 4. Search Functionality

#### 4.1 Search Interface
- **Trigger**: Search icon in app bar
- **Search Bar**: Appears at top, slides down with animation (250ms)
- **Real-time Search**: Results filter as user types (200ms debounce)
- **Search Scope**:
  - Note text content
  - Icon category names
- **Search Behavior**:
  - **Case-insensitive**: "buy" matches "Buy", "BUY", "buy"
  - **Partial matching**: Matches substring anywhere in text
  - **Active notes only**: Archived notes excluded from search
- **No Results State**: "No notes found for '[query]'" with clear search button

#### 4.2 Search Results
- **Display**: Same card layout as main view
- **Highlighting**: Search term highlighted in yellow
- **Clear Search**: X button to exit search mode
- **Result Ordering**:
  1. Pinned notes first (matching query)
  2. Unpinned notes by relevance (exact match before partial)
  3. Then by creation date (newest first)
- **Grouping**: Disabled during search (flat list)

### 5. Pin Functionality

#### 5.1 Pin Notes
- **Trigger**: Pin icon in note options (long-press menu)
- **Behavior**: Pinned notes always appear at top of list
- **Visual Indicator**: Small pin icon in top-right corner of note
- **Multiple Pins**: All pinned notes appear before unpinned
- **Order**: Pinned notes maintain their relative order

### 6. Archive View

#### 6.1 Navigation
- **Access**: Archive icon/button in main app bar
- **View**: Separate screen showing archived notes
- **Layout**: Same list view as main screen

#### 6.2 Archive Actions
- **Restore**: Long-press menu option to move back to main view
  - Moves note to bottom of main screen
  - Sets isArchived = false
  - Shows snackbar "Note restored"
- **Permanent Delete**: Long-press menu option with confirmation dialog (see 1.3)
- **Bulk Actions**: Select multiple notes for restore/delete
  - **Trigger**: Long-press on archived note enters selection mode
  - **UI Changes**:
    - Checkboxes appear on all archived notes
    - Action bar shows "Restore" and "Delete" buttons
    - Select All option in app bar
  - **Bulk Delete Confirmation**:
    - Title: "Delete Notes?"
    - Message: "Delete [N] notes permanently? This action cannot be undone."
    - Buttons: "Cancel" | "Delete" (red/destructive)
  - **Exit**: Back button or tap outside selection

### 7. Dark Mode

#### 7.1 Theme Support
- **Modes**: Light, Dark, System (follow device setting)
- **Persistence**: User preference saved
- **Implementation**: Flutter ThemeData with dark variant

#### 7.2 Dark Mode Colors
- Adjusted color palette for dark backgrounds
- Sufficient contrast ratios (WCAG AA compliance)
- Note colors remain distinguishable

---

## Edge Cases & Behavior Clarifications

### Character Limit Enforcement
- **Limit**: 140 characters maximum
- **Behavior**: Keyboard input is blocked at 140 characters
- **Implementation**: TextField `maxLength: 140` with `maxLengthEnforcement: MaxLengthEnforcement.enforced`
- **Counter Display**: Show "X/140" at all times in editor
- **Visual Feedback**: Counter remains gray throughout (no color changes)

### Pin + Archive Interaction
- **Rule**: Archiving a note removes its pin status
- **Reason**: Archived notes are separate from active notes; pin status only applies to active notes
- **Restoration**: If archived note is restored, it returns as unpinned
- **User can re-pin after restoring if desired**

### Search Scope
- **Scope**: Search only searches active (non-archived) notes
- **Exclusion**: Archived notes are not included in search results
- **Access**: User must navigate to Archive view to see archived notes
- **Reason**: Keep active and archived notes clearly separated



### Reordering with Pinned Notes
- **Rule**: Unpinned notes cannot be dragged above pinned notes
- **Pinned Section**: Always at the top, separated visually
- **Reorder Scope**:
  - Pinned notes can be reordered among themselves
  - Unpinned notes can be reordered among themselves
  - But the two sections remain separate

### Empty States

#### No Notes Created
- **Display**: Friendly illustration or icon (optional)
- **Message**: "Create your first note"
- **Subtext**: "Tap the + button to get started"
- **Highlight**: Subtle animation/pulse on FAB (optional)

#### No Search Results
- **Display**: "No notes found for '[search query]'"
- **Action**: "Clear search" button or tap X to close search
- **No fallback suggestions** (keep it simple)

#### Empty Archive
- **Display**: "No archived notes"
- **Message**: "Archived notes will appear here"
- **Action**: Navigation back to main screen

### Auto-Save Behavior
- **Note Content**: Auto-save on text change with 500ms debounce
- **Note Metadata**: Save immediately (color, priority, pin, icon)
- **Note Order**: Save after drag-and-drop completes
- **App Lifecycle**: Flush all pending saves on app pause/terminate

### State Restoration
- **On App Resume**: Reload notes from Hive
- **After Crash**: All changes saved (due to auto-save)
- **Search State**: Not persisted (reset on app close)
- **Editor State**: Not persisted if app closed mid-edit

### Animation Specifications

#### Sticking Animation (Note Drop)
- **Duration**: 300ms
- **Curve**: `Curves.elasticOut`
- **Effect**: Scale from 1.0 → 1.05 → 1.0 (slight bounce)
- **Haptic**: Medium impact on drop

#### Note Creation
- **Duration**: 250ms
- **Curve**: `Curves.easeOut`
- **Effect**: Fade in (0 → 1) + Scale (0.8 → 1.0) + Slide from bottom (50px)

#### Archive Swipe
- **Duration**: 200ms
- **Curve**: `Curves.easeInOut`
- **Effect**: Slide out with fade
- **Undo Window**: 3 seconds
- **Undo Animation**: Reverse with `Curves.elasticOut`

#### Group Expand/Collapse
- **Duration**: 300ms
- **Curve**: `Curves.easeInOut`
- **Effect**: Height animation with stagger (50ms delay per item)

#### Search Bar
- **Duration**: 250ms
- **Curve**: `Curves.easeOut`
- **Effect**: Slide down from top with fade

### Error Handling

#### User Errors (Show friendly message via SnackBar)
- Character limit exceeded (should not occur with input blocking)
- Storage full: "Cannot create more notes. Storage is full."
- Invalid input: "Please enter some text for your note."

#### System Errors (Log + show generic message)
- Database error: "Something went wrong. Please try again."
- Unexpected errors: "An error occurred. Please restart the app."

#### Error Recovery
- Auto-save ensures minimal data loss
- App should gracefully degrade if storage has issues
- Provide actionable guidance when possible

### Additional Clarifications

#### Onboarding Experience
- **Type**: Minimal single-screen onboarding
- **Content**: Explain basic interactions (tap + to create, swipe to archive, tap to edit)
- **Dismissal**: "Get Started" button
- **Persistence**: "Don't show again" checkbox
- **Trigger**: Show only on first app launch

#### Paste Behavior (> 140 chars)
- **Action**: Block paste operation
- **Feedback**: Show SnackBar: "Text is too long. Maximum 140 characters."
- **User Action**: Must shorten text before pasting

#### Typography
- **Font Family**: System fonts only (San Francisco on iOS, Roboto on Android)
- **No Custom Fonts**: Keeps app size small, better accessibility
- **Benefits**: Familiar to users, no licensing, optimal rendering

#### Privacy & Analytics
- **v1.0**: Zero tracking, zero analytics, zero crash reporting
- **Philosophy**: Privacy-first approach
- **Future**: Can reconsider opt-in analytics for v2.0

#### Storage Full Handling
- **Behavior**: Prevent creating new notes when storage full
- **Message**: "Cannot create note. Device storage is full."
- **Existing Notes**: Remain accessible and editable

#### Character Counter Display
- **Visibility**: Always visible in note editor
- **Location**: Bottom-right corner
- **Format**: "X/140"
- **Style**: Gray color at all times (no color changes)

#### Maximum Note Limit
- **Limit**: 1000 notes total (active + archived combined)
- **Enforcement**: Check count before allowing creation
- **Error Message**: "Maximum notes reached (1000). Please delete or archive some notes."
- **Reason**: Prevents performance degradation, encourages cleanup

#### Long-Press Menu
- **Type**: Bottom sheet modal (Material Design)
- **Options**: Pin/Unpin, Edit, Archive, Change Priority, Change Color
- **Archive View Additional**: Delete option (permanent)
- **Dismissal**: Tap outside, drag down, or select option
- **Benefits**: Large touch targets, mobile-friendly, standard pattern

#### Git Workflow
- **Strategy**: Simple main-only workflow
- **Versioning**: Use tags (v1.0.0, v1.1.0, etc.)
- **Commits**: Conventional commit format
- **Branching**: Not required for v1.0; can add in v2.0 if needed

#### Auto-Save Debounce
- **Timing**: 500ms after user stops typing
- **Metadata**: Save immediately (no debounce)
- **Reason**: Balance between data safety and performance

#### Archive Timestamps
- **Behavior**: Keep original creation date
- **Display**: "Created: X days ago" (unchanged when archived)
- **Restoration**: Maintains original timeline when restored
- **No Archive Date**: Don't show separate "Archived: X days ago"

#### Performance Benchmarking
- **Frequency**: Before each release only
- **Metrics**: App launch time, scroll FPS, animation smoothness
- **Purpose**: Ensure no regressions between versions

#### Undo Snackbar Interaction
- **Behavior**: Tappable to dismiss (confirms archive)
- **UNDO Action**: Restores note when tapped
- **Auto-Dismiss**: After 3 seconds if no action
- **Standard**: Material Design snackbar pattern

#### Rapid Note Creation
- **Throttling**: None (unlimited creation speed)
- **Trust**: System can handle rapid operations
- **Limit**: Subject to overall 1000-note maximum
- **Philosophy**: User freedom within reasonable bounds

#### Color Selection Timing
- **On Creation**: Default to classic yellow (#FFF59D)
- **On Editing**: Show color picker in note editor
- **Benefits**: Faster creation flow, one-tap to start typing

#### All Empty State
- **Condition**: All notes deleted AND archive is empty
- **Display**: Same welcome state as first-time user
- **Message**: "Create your first note"
- **Philosophy**: Fresh start experience, consistency

---

## Data Models

### Note Model
```dart
class Note {
  final String id;              // UUID
  final String content;         // Max 140 chars
  final DateTime createdAt;
  final DateTime updatedAt;
  final NoteColor color;        // Enum of 10 colors
  final NotePriority priority;  // High/Medium/Low
  final IconCategory? iconCategory;
  final bool isPinned;
  final bool isArchived;
  final int manualOrder;        // For custom sorting
  final TextFormatting formatting;
  final List<ChecklistItem>? checklistItems;
}

class TextFormatting {
  final bool isBold;
  final bool isItalic;
  final bool isUnderlined;
  final FontSize fontSize;      // Small/Medium/Large
  final ListType listType;      // None/Bullets/Checkboxes
}

class ChecklistItem {
  final String id;
  final String text;
  final bool isCompleted;
}

enum NoteColor {
  classicYellow,
  coralPink,
  skyBlue,
  mintGreen,
  lavender,
  peach,
  teal,
  lightGray,
  lemon,
  rose
}

enum NotePriority { high, medium, low }

enum IconCategory { work, personal, shopping, health, finance, important, ideas }

enum FontSize { small, medium, large }

enum ListType { none, bullets, checkboxes }
```

### App Settings Model
```dart
class AppSettings {
  final ThemeMode themeMode;           // Light/Dark/System
  final SortPreference sortPreference; // Manual/Priority/Age/Color
  final bool isGroupingEnabled;        // For 10+ notes
  final GroupingType groupingType;     // Age/Color/Category
}

enum SortPreference { manual, priority, ageNewest, ageOldest, color }

enum GroupingType { age, color, category }
```

---

## Design System

### Icons

#### Icon Library
**Material Icons** (included with Flutter by default)

#### Category Icons
| Category | Icon | Material Icon Code |
|----------|------|-------------------|
| Work | Briefcase | `Icons.work` |
| Personal | House | `Icons.home` |
| Shopping | Cart | `Icons.shopping_cart` |
| Health | Heart | `Icons.favorite` |
| Finance | Dollar | `Icons.attach_money` |
| Important | Star | `Icons.star` |
| Ideas | Lightbulb | `Icons.lightbulb` |

#### System Icons
| Purpose | Icon | Material Icon Code |
|---------|------|-------------------|
| Add Note | Plus | `Icons.add` |
| Search | Magnifying Glass | `Icons.search` |
| Archive | Archive Box | `Icons.archive` |
| Delete | Trash | `Icons.delete` |
| Pin | Push Pin (filled) | `Icons.push_pin` |
| Unpin | Push Pin (outline) | `Icons.push_pin_outlined` |
| Menu | Vertical Dots | `Icons.more_vert` |
| Close | X | `Icons.close` |
| Check | Checkmark | `Icons.check` |
| Edit | Pencil | `Icons.edit` |

#### Icon Sizes
- Note category icon: 20px
- Action buttons: 24px
- FAB icon: 24px
- App bar icons: 24px

### Typography

#### Font Family
- **Default**: System font
  - iOS: San Francisco
  - Android: Roboto
- **Fallback**: Flutter default

#### Text Styles

##### Note Content
| Size | Font Size | Weight | Usage |
|------|-----------|--------|-------|
| Small | 12pt | Regular (400) | Compact notes |
| Medium | 14pt | Regular (400) | Default note text |
| Large | 16pt | Regular (400) | Emphasis notes |

##### UI Elements
| Element | Font Size | Weight | Notes |
|---------|-----------|--------|-------|
| App Bar Title | 20pt | Medium (500) | "ephenotes" |
| Note Priority | 10pt | Bold (700) | Uppercase, e.g., "HIGH" |
| Timestamp | 12pt | Regular (400) | 60% opacity |
| Button Text | 14pt | Medium (500) | All buttons |
| Search Placeholder | 14pt | Regular (400) | 40% opacity |
| Character Counter | 12pt | Regular (400) | "140/140" |
| Empty State Title | 16pt | Medium (500) | Empty state messages |
| Empty State Body | 14pt | Regular (400) | Supporting text |

#### Line Height
- Note content: 1.5x font size
- UI text: 1.2x font size

#### Accessibility
- Support Dynamic Type (iOS system font scaling)
- Support system font scaling (Android)
- Maximum scale: 200%
- Minimum scale: 50%
- Maintain layout integrity at all scales

### Color Specifications

#### Note Colors

##### Light Mode
| Color Name | Hex Code | Usage |
|------------|----------|-------|
| Classic Yellow | #FFF59D | Default note color |
| Coral Pink | #FF8A80 | Alternative |
| Sky Blue | #82B1FF | Alternative |
| Mint Green | #B9F6CA | Alternative |
| Lavender | #E1BEE7 | Alternative |
| Peach | #FFCCBC | Alternative |
| Teal | #A7FFEB | Alternative |
| Light Gray | #CFD8DC | Alternative |
| Lemon | #F4FF81 | Alternative |
| Rose | #F8BBD0 | Alternative |

##### Dark Mode (Adjusted)
| Color Name | Hex Code | Adjusted From Light |
|------------|----------|---------------------|
| Classic Yellow | #FFE082 | Darkened |
| Coral Pink | #FF6F60 | Darkened |
| Sky Blue | #6699FF | Darkened |
| Mint Green | #81C784 | Darkened |
| Lavender | #CE93D8 | Darkened |
| Peach | #FFAB91 | Darkened |
| Teal | #64FFDA | Darkened |
| Light Gray | #90A4AE | Darkened |
| Lemon | #E6EE9C | Darkened |
| Rose | #F48FB1 | Darkened |

#### Background Colors
| Element | Light Mode | Dark Mode |
|---------|------------|-----------|
| Scaffold | #FFFFFF | #121212 |
| Surface | #F5F5F5 | #1E1E1E |
| Card | Note color | Note color (adjusted) |

| Element | Light Mode | Dark Mode |
|---------|------------|-----------|
| Primary Text | #000000 (87%) | #FFFFFF (87%) |
| Secondary Text | #000000 (60%) | #FFFFFF (60%) |
| Disabled Text | #000000 (38%) | #FFFFFF (38%) |

#### Text Visibility on Notes
**Requirement**: Text must always be readable against note background color in both light and dark mode.
- In dark mode, if a note color is too light (e.g., Classic Yellow, Lemon, Mint Green, etc.), use dark text (#212121, 87% opacity).
- If a note color is dark (e.g., Teal, Sky Blue, Lavender, etc.), use light text (#FFFFFF, 87% opacity).
- Use WCAG AA contrast ratio (≥ 4.5:1) for all note text.
- Text color should be dynamically selected based on note color and theme.
- Applies to note content, priority label, timestamp, and icons.

#### Priority Colors
| Priority | Color | Hex Code |
|----------|-------|----------|
| High | Red | #D32F2F |
| Medium | Orange | #F57C00 |
| Low | Green | #388E3C |

#### Contrast Requirements
- All text must meet WCAG AA standards
- Normal text: 4.5:1 contrast ratio minimum
- Large text: 3:1 contrast ratio minimum
- Note colors tested for readability on both backgrounds

### Spacing

#### Padding
- Screen edge padding: 16px
- Note card padding: 12px
- Between notes: 8px
- Group header padding: 16px vertical, 16px horizontal

#### Margins
- FAB from edge: 16px
- App bar icon spacing: 8px
- Section spacing: 24px

#### Border Radius
- Note cards: 12px
- Buttons: 8px
- Search bar: 24px (pill shape)

### Elevation (Shadows)
- Note cards: elevation 2
- Pinned notes: elevation 3
- Dragging note: elevation 8
- FAB: elevation 6
- App bar: elevation 0 (flat)

---

## User Interface Specifications

### 1. Main Screen (Note List)

#### Layout Structure
```
┌─────────────────────────────────┐
│  ephenotes        🔍 📦 ⋮      │ ← App Bar
├─────────────────────────────────┤
│  📌 [Pinned Note 1]             │ ← Pinned Section
│  📌 [Pinned Note 2]             │
├─────────────────────────────────┤
│  [Note Card 1]                  │
│  [Note Card 2]                  │ ← Scrollable List
│  [Note Card 3]                  │
│  ...                            │
│  [Grouped Stack - Older] ▼      │ ← Group (if >10)
│                                 │
│                                 │
│                         ( + )   │ ← Floating Action Button
└─────────────────────────────────┘
```

#### Note Card Design
```
┌─────────────────────────────────┐
│ 🏠 HIGH                     📌  │ ← Icon, Priority, Pin
│                                 │
│  Note content text here...      │ ← Note content
│  • Bullet point                 │
│  ☑ Completed task              │
│                                 │
│  2h ago                         │ ← Timestamp
└─────────────────────────────────┘
   ↑ Background color varies
```

#### Interactions
- **Tap**: Open note editor
- **Long-press**: Show options menu (Pin, Edit, Archive, Change Priority)
- **Swipe Left/Right**: Archive with undo snackbar
- **Long-press + Drag**: Reorder with sticking animation

### 2. Note Editor Screen

#### Layout
```
┌─────────────────────────────────┐
│  ←  Note                   ✓    │ ← Back / Save
├─────────────────────────────────┤
│  ┌───────────────────────────┐ │
│  │                           │ │
│  │  Enter your note...       │ │ ← Text Input Area
│  │                           │ │
│  │  140/140                  │ │ ← Character counter
│  └───────────────────────────┘ │
├─────────────────────────────────┤
│  [B] [I] [U] [••] [☑] [Tt]    │ ← Formatting toolbar
├─────────────────────────────────┤
│  Priority: [High][Med][Low]    │ ← Priority selector
│  Color: [⬤⬤⬤⬤⬤⬤⬤⬤⬤⬤]          │ ← Color picker
│  Icon: [💼🏠🛒❤️💰⭐💡]         │ ← Icon selector
└─────────────────────────────────┘
```

### 3. Archive Screen

```
┌─────────────────────────────────┐
│  ← Archive            Select All │
├─────────────────────────────────┤
│  [Archived Note 1]         🗑    │ ← Swipe for restore/delete
│  [Archived Note 2]         🗑    │
│  [Archived Note 3]         🗑    │
│                                 │
│  (Empty state if no archives)   │
└─────────────────────────────────┘
```

### 4. Search Interface

```
┌─────────────────────────────────┐
│  🔍 Search notes...          ✕  │ ← Search bar
├─────────────────────────────────┤
│  [Matching Note 1]              │ ← Filtered results
│  [Matching Note 2]              │
│  [Matching Note 3]              │
│                                 │
│  (No results state)             │
└─────────────────────────────────┘
```

---

## User Flows

### Flow 1: Create New Note
1. User taps floating "+" button
2. Note editor screen opens
3. User types note content (max 140 chars)
4. User optionally selects color, icon, priority
5. User optionally applies text formatting
6. User taps "✓" save button
7. App returns to main screen with new note visible
8. Success snackbar: "Note created"

### Flow 2: Archive Note
1. User swipes note left or right
2. Note animates off screen
3. Undo snackbar appears (3 seconds): "Note archived. UNDO"
4. If no action, note moves to archive
5. If UNDO tapped, note slides back into position

### Flow 3: Search Notes
1. User taps search icon
2. Search bar slides down from top
3. User types search query
4. Results filter in real-time
5. User taps result to open note editor
6. User taps "✕" to exit search

### Flow 4: Reorder Notes
1. User long-presses note card
2. Haptic feedback + note lifts with shadow
3. User drags note to new position
4. Other notes shift with animation
5. User releases note
6. "Sticking" animation plays
7. New order persisted

### Flow 5: Pin Note
1. User long-presses note card
2. Options menu appears
3. User taps "Pin" option
4. Note animates to pinned section at top
5. Pin icon appears on note
6. Success snackbar: "Note pinned"

---

## Non-Functional Requirements

### Performance
- **App Launch**: < 2 seconds cold start
- **Note Creation**: Instant feedback, < 100ms save time
- **List Scrolling**: 60 FPS smooth scrolling
- **Search**: Real-time results with < 200ms debounce
- **Animations**: 60 FPS for all transitions

### Accessibility
- **Screen Reader**: Full VoiceOver (iOS) and TalkBack (Android) support
- **Contrast Ratios**: WCAG AA compliance (4.5:1 minimum)
- **Touch Targets**: Minimum 44x44pt tap areas
- **Font Scaling**: Support system font size settings

### Localization
- **v1.0**: English only
- **Future**: Support for additional languages (strings externalized from v1.0)

### Data & Privacy
- **Storage**: All data stored locally on device
- **No Analytics**: No tracking or data collection
- **No Network**: App functions fully offline
- **Data Export**: (Future) Export notes as JSON/CSV

### Platform Requirements
- **iOS**: iOS 13.0+
- **Android**: Android 6.0+ (API level 23+)
- **Screen Sizes**: Support for phones and tablets

---

## Testing Requirements

### Unit Tests
- **Coverage Target**: Minimum 80%
- **Focus Areas**:
  - BLoC logic (note CRUD operations)
  - Data models and serialization
  - Repository layer
  - Sorting and filtering logic
  - Search functionality

### Widget Tests
- **Coverage Target**: Critical user flows
- **Focus Areas**:
  - Note card interactions
  - Note editor form validation
  - Search interface
  - Archive screen
  - Theme switching

### Integration Tests
- **Coverage Target**: End-to-end user flows
- **Focus Areas**:
  - Create → Edit → Archive → Restore flow
  - Create → Pin → Reorder flow
  - Search → Edit → Save flow
  - Color/Icon categorization flow

### Platform Testing
- **iOS**: Test on simulators + physical devices (iPhone 12+, iPad)
- **Android**: Test on emulators + physical devices (Various manufacturers, screen sizes)
- **Dark Mode**: Test all screens in both themes
- **Accessibility**: VoiceOver and TalkBack testing

---

## Version Control & Quality Gates

### Commit Standards
- **Conventional Commits**: Required format
  - `feat:` New features
  - `fix:` Bug fixes
  - `docs:` Documentation changes
  - `test:` Test additions/changes
  - `refactor:` Code refactoring
  - `style:` Code style changes
  - `chore:` Build/config changes

### Pre-Commit Checks
1. Code formatting (`dart format`)
2. Linting (`flutter analyze`)
3. Unit tests pass
4. No debug code or console logs

### Pre-Release Checks
1. All tests passing (unit, widget, integration)
2. Manual testing on iOS and Android
3. Dark mode verification
4. Performance profiling
5. Documentation updated
6. Version number bumped

---

## Future Considerations (Post v1.0)

### Phase 2 Features
- Cloud sync (optional, user-controlled)
- Export/Import notes (JSON, CSV, PDF)
- Note templates
- Recurring notes/reminders
- Voice-to-text note creation
- Image attachments to notes
- Collaborative notes (shared with contacts)
- Widget for home screen
- Apple Watch / Wear OS companion app

### Phase 2 Technical Enhancements
- Backend API (Firebase or custom)
- User authentication
- End-to-end encryption
- Backup & restore
- Analytics (opt-in)
- A/B testing framework
- Crash reporting (Firebase Crashlytics)

---

## File Structure

```
ephenotes/
├── lib/
│   ├── main.dart
│   ├── app.dart
│   │
│   ├── core/
│   │   ├── constants/
│   │   │   ├── colors.dart
│   │   │   ├── dimensions.dart
│   │   │   └── strings.dart
│   │   ├── theme/
│   │   │   ├── app_theme.dart
│   │   │   └── dark_theme.dart
│   │   ├── utils/
│   │   │   ├── date_formatter.dart
│   │   │   └── validators.dart
│   │   └── extensions/
│   │       └── context_extensions.dart
│   │
│   ├── data/
│   │   ├── models/
│   │   │   ├── note.dart
│   │   │   ├── app_settings.dart
│   │   │   └── checklist_item.dart
│   │   ├── repositories/
│   │   │   ├── note_repository.dart
│   │   │   └── settings_repository.dart
│   │   └── datasources/
│   │       ├── local/
│   │       │   ├── note_local_datasource.dart
│   │       │   └── settings_local_datasource.dart
│   │       └── hive_adapters/
│   │           └── note_adapter.dart
│   │
│   ├── domain/
│   │   ├── entities/
│   │   │   └── (if needed for clean architecture)
│   │   └── usecases/
│   │       ├── create_note.dart
│   │       ├── update_note.dart
│   │       ├── delete_note.dart
│   │       ├── archive_note.dart
│   │       ├── search_notes.dart
│   │       └── reorder_notes.dart
│   │
│   ├── presentation/
│   │   ├── bloc/
│   │   │   ├── notes/
│   │   │   │   ├── notes_bloc.dart
│   │   │   │   ├── notes_event.dart
│   │   │   │   └── notes_state.dart
│   │   │   ├── settings/
│   │   │   │   ├── settings_bloc.dart
│   │   │   │   ├── settings_event.dart
│   │   │   │   └── settings_state.dart
│   │   │   └── search/
│   │   │       ├── search_bloc.dart
│   │   │       ├── search_event.dart
│   │   │       └── search_state.dart
│   │   │
│   │   ├── screens/
│   │   │   ├── main_screen.dart
│   │   │   ├── note_editor_screen.dart
│   │   │   ├── archive_screen.dart
│   │   │   └── settings_screen.dart
│   │   │
│   │   └── widgets/
│   │       ├── note_card.dart
│   │       ├── note_editor_toolbar.dart
│   │       ├── color_picker.dart
│   │       ├── icon_selector.dart
│   │       ├── priority_selector.dart
│   │       ├── grouped_note_stack.dart
│   │       └── search_bar.dart
│   │
│   └── injection.dart (dependency injection)
│
├── test/
│   ├── unit/
│   ├── widget/
│   └── integration/
│
├── assets/
│   ├── icons/
│   └── fonts/ (if custom fonts)
│
├── android/
├── ios/
├── pubspec.yaml
├── analysis_options.yaml
├── SPEC.md (this file)
├── AGENTS.md
└── README.md
```

---

## Success Metrics (Post-Launch)

### User Engagement
- Daily Active Users (DAU)
- Average notes created per user per day
- Note completion rate (archived/deleted)
- Feature adoption (colors, icons, pinning, search)

### Technical Health
- Crash-free rate: > 99.5%
- App performance score: > 90 (Firebase Performance)
- Average app rating: > 4.5 stars
- Load time: < 2 seconds

### Development Velocity
- Sprint velocity consistency
- Bug resolution time: < 2 days
- Code review turnaround: < 4 hours
- Test coverage maintained at 80%+

---

## Glossary

- **Post-it**: A sticky note, the inspiration for the app's note cards
- **Archive**: A storage area for completed/old notes that aren't permanently deleted
- **Pin**: Marking a note to always appear at the top of the list
- **Priority**: User-assigned importance level (High/Medium/Low)
- **Grouping**: Visual stacking of notes when count exceeds 10
- **Sticking Animation**: Visual effect when dropping a dragged note, simulating paper sticking to surface
- **Character Limit**: Maximum 140 characters per note (similar to early Twitter)
- **Local Storage**: Data stored on device only, no cloud/backend

---

**Document Version**: 1.0
**Last Updated**: 2026-02-03
**Author**: AI-Generated based on user requirements
**Status**: Ready for Development
