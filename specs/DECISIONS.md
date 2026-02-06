# ephenotes - Design Decisions

This document records all design decisions made during the specification process.

---

## Core Behaviors (Round 1)
### Note Grouping by Age
**Decision**: Removed for simplicity
- Age-based grouping (Today, This Week, Older) is no longer part of the app.
- All notes are shown in a single list, with pinned notes at the top.
- Reason: Keeps the app simple and focused on quick note-taking.

### Character Limit Enforcement
**Decision**: Hard block at 140 characters (prevent typing)
- Keyboard input is blocked when 140 characters reached
- `TextField` configured with `maxLength: 140` and `maxLengthEnforcement.enforced`
- Counter displays "X/140" at all times

### Pin + Archive Interaction
**Decision**: Archiving removes pin status
- When a note is archived, it loses its pin status
- If restored from archive, it returns as unpinned
- Reason: Clean separation between active and archived notes

### Search Scope
**Decision**: Active notes only
- Search only searches non-archived notes
- Archived notes excluded from search results
- User must navigate to Archive view to access archived notes

### Grouping Threshold
**Decision**: Start grouping at 11+ notes
- At exactly 10 notes: No grouping
- At 11+ notes: Apply age-based grouping
- Groups: "Today", "This Week", "Older"

---

## User Experience (Round 2)

### Onboarding
**Decision**: Minimal single-screen onboarding
- Single welcome screen explaining basic interactions:
  - Tap + to create note
  - Swipe to archive
  - Tap to edit
- "Get Started" button to dismiss
- "Don't show again" checkbox for future sessions
- **Implementation**: Show on first app launch only

### Paste Behavior
**Decision**: Block paste and show error
- If pasted text > 140 characters, prevent the paste action
- Show SnackBar: "Text is too long. Maximum 140 characters."
- User must shorten text before pasting or paste elsewhere first

### Typography
**Decision**: System fonts only
- iOS: San Francisco (system default)
- Android: Roboto (system default)
- No custom fonts imported
- Benefits: Smaller app size, familiar to users, better accessibility, no licensing concerns

### Analytics & Tracking
**Decision**: No analytics in v1.0
- Zero tracking
- Zero data collection
- Zero crash reporting
- Pure privacy-first approach
- Aligns with app's simplicity philosophy
- Can reconsider for v2.0 based on user feedback

---

## Technical Behaviors (Round 3)

### Storage Full Handling
**Decision**: Prevent creating new notes
- When device storage is full, block note creation
- Show error: "Cannot create note. Device storage is full."
- Existing notes remain fully accessible and editable
- No data loss risk

### Character Counter Display
**Decision**: Always visible in editor
- Show "X/140" counter in bottom-right of note editor
- Visible at all times (not just when typing)
- Gray color (no color changes at different thresholds)
- User always aware of remaining space

### Maximum Note Limit
**Decision**: Hard limit at 1000 notes
- User can create up to 1000 notes total (active + archived)
- When limit reached, show error: "Maximum notes reached (1000). Please delete or archive some notes."
- Reason: Prevents performance issues, forces cleanup, reasonable limit for post-it note use case
- **Implementation**: Check count before allowing creation

### Long-Press Menu
**Decision**: Bottom sheet modal
- Long-press on note shows bottom sheet from bottom
- Options presented:
  - Pin / Unpin
  - Edit
  - Archive
  - Change Priority
  - Change Color
  - Delete (if in Archive view)
- Large touch targets (mobile-friendly)
- Dismissed by tapping outside or dragging down

---

## Development Workflow (Round 4)

### Git Workflow
**Decision**: Simple main-only workflow
- Work directly on `main` branch
- Use tags for version releases (v1.0.0, v1.1.0, etc.)
- Conventional commits for history clarity
- Simplest approach for AI-driven solo development
- Can introduce branching in v2.0 if needed

### Auto-Save Frequency
**Decision**: 500ms debounce
- Save note changes 500ms after user stops typing
- Good balance between data safety and performance
- Standard debounce timing for auto-save
- Prevents excessive writes while ensuring minimal data loss

### Archive Timestamps
**Decision**: Keep original creation date
- Archived notes retain their original "Created: X days ago" timestamp
- No separate "Archived: X days ago" field
- If restored, note maintains its original timeline
- Simpler UI, more informative for user context

### Performance Benchmarking
**Decision**: Before each release only
- Run performance tests as part of pre-release checklist
- Verify no regressions from previous version
- Focus on: app launch time, scroll performance, animation FPS
- Minimal overhead, ensures quality gates

---

## UX Details (Round 5)

### Undo Snackbar
**Decision**: Tap to dismiss (confirmation)
- After archiving, SnackBar appears with "UNDO" action
- User can tap UNDO to restore
- User can tap anywhere else on snackbar to dismiss (confirm archive)
- Auto-dismisses after 3 seconds if no action
- Standard Material Design snackbar behavior

### Rapid Note Creation
**Decision**: Allow unlimited (no throttling)
- No rate limiting on note creation
- User can create as many notes as fast as they want
- Trust system to handle rapid operations
- Aligns with simplicity and user freedom
- Subject to overall 1000-note limit

### Color Selection Timing
**Decision**: Default on create, change when editing
- New notes always start with classic yellow (#FFF59D)
- User opens note editor to change color
- Faster note creation flow (one tap on FAB → start typing)
- Color picker shown in edit screen only

### All Empty State
**Decision**: Show welcome state again
- When user deletes all notes and archive is empty
- Display the same empty state as first-time users
- "Create your first note" message
- Feels like a fresh start, consistent experience

---

## Summary Statistics

**Total Decisions Made**: 20

**By Category**:
- Core Behaviors: 4
- User Experience: 4
- Technical Behaviors: 4
- Development Workflow: 4
- UX Details: 4

**Philosophy**:
- ✅ Simplicity first
- ✅ Privacy first (no tracking)
- ✅ User freedom (within reasonable limits)
- ✅ Mobile-friendly interactions
- ✅ Data safety with auto-save
- ✅ Clear, actionable error messages

---

## Key Principles Reflected in Decisions

1. **Simplicity**: Default colors, system fonts, minimal onboarding
2. **Predictability**: Always-visible counter, standard snackbar behavior
3. **User Respect**: No tracking, unlimited rapid actions, no rate limiting
4. **Safety**: Auto-save, prevent data loss, clear error messages
5. **Mobile-First**: Bottom sheet menus, large touch targets, swipe gestures
6. **Performance**: Hard limits prevent performance degradation

---

**Document Status**: Complete - All decisions documented
**Last Updated**: 2026-02-03
**Ready for Implementation**: ✅ YES
