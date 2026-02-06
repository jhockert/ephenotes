# ephenotes - Requirements Specification

**Version:** 1.0
**Last Updated:** 2026-02-03
**Status:** Approved for Development

---

## Table of Contents

1. [Functional Requirements](#1-functional-requirements)
2. [Non-Functional Requirements](#2-non-functional-requirements)
3. [Constraints](#3-constraints)
4. [Acceptance Criteria](#4-acceptance-criteria)
5. [Traceability Matrix](#5-traceability-matrix)

---

## 1. FUNCTIONAL REQUIREMENTS

### 1.1 Note Management

#### FR-1.1: Create Note
**Priority:** Critical
**Description:** Users shall be able to create new notes with a 140-character limit.

**Requirements:**
- FR-1.1.1: System shall provide a floating "+" button for note creation
- FR-1.1.2: System shall enforce a hard limit of 140 characters
- FR-1.1.3: System shall block keyboard input at 140 characters
- FR-1.1.4: System shall block paste operations exceeding 140 characters
- FR-1.1.5: System shall display character counter (gray at <130, yellow at 130-134, orange at 135-139, red at 140)
- FR-1.1.6: System shall assign default values: yellow color, medium priority, no icon
- FR-1.1.7: System shall auto-generate createdAt and updatedAt timestamps
- FR-1.1.8: System shall provide light haptic feedback when character limit reached

**Acceptance Criteria:** See [features/note_creation.feature](features/note_creation.feature)

#### FR-1.2: Edit Note
**Priority:** Critical
**Description:** Users shall be able to edit existing notes.

**Requirements:**
- FR-1.2.1: System shall open note editor on tap
- FR-1.2.2: System shall allow editing: content, color, icon, priority, formatting
- FR-1.2.3: System shall enforce 140-character limit during editing
- FR-1.2.4: System shall auto-save changes with 500ms debounce
- FR-1.2.5: System shall update updatedAt timestamp on each save
- FR-1.2.6: System shall preserve createdAt timestamp

#### FR-1.3: Delete Note
**Priority:** Critical
**Description:** Users shall be able to permanently delete notes.

**Requirements:**
- FR-1.3.1: System shall only allow permanent deletion from archive
- FR-1.3.2: System shall show confirmation dialog: "Delete Note?" with message "This note will be permanently deleted. This action cannot be undone."
- FR-1.3.3: System shall provide "Cancel" and "Delete" (destructive style) buttons
- FR-1.3.4: System shall remove note from database on confirmation
- FR-1.3.5: System shall show snackbar "Note deleted permanently"

#### FR-1.4: Archive Note
**Priority:** Critical
**Description:** Users shall be able to archive notes with undo capability.

**Requirements:**
- FR-1.4.1: System shall archive notes via swipe gesture (left or right)
- FR-1.4.2: System shall animate note slide-off (200ms duration)
- FR-1.4.3: System shall show snackbar "Note archived. UNDO" for 3 seconds
- FR-1.4.4: System shall allow undo within 3-second window
- FR-1.4.5: System shall remove pin status when archiving (isPinned = false)
- FR-1.4.6: System shall restore note with elastic bounce animation on undo
- FR-1.4.7: System shall provide medium haptic feedback on undo
- FR-1.4.8: System shall confirm archive if snackbar tapped or 3 seconds elapse

**Acceptance Criteria:** See [features/archive_and_undo.feature](features/archive_and_undo.feature)

### 1.2 Organization Features

#### FR-2.1: Priority System
**Priority:** High
**Description:** Users shall be able to assign priority levels to notes.

**Requirements:**
- FR-2.1.1: System shall support three priority levels: High, Medium, Low
- FR-2.1.2: System shall display "HIGH" (red), "MEDIUM" (orange), "LOW" (green) labels
- FR-2.1.3: System shall allow sorting by priority
- FR-2.1.4: System shall default new notes to Medium priority

#### FR-2.2: Color Coding
**Priority:** High
**Description:** Users shall be able to assign colors to notes.

**Requirements:**
- FR-2.2.1: System shall provide 10 predefined colors
- FR-2.2.2: System shall support light and dark mode color variants
- FR-2.2.3: System shall default new notes to Classic Yellow (#FFF59D light, #FFE082 dark)
- FR-2.2.4: System shall maintain WCAG AA contrast ratios (4.5:1 minimum)

#### FR-2.3: Icon Categories
**Priority:** Medium
**Description:** Users shall be able to assign icon categories to notes.

**Requirements:**
- FR-2.3.1: System shall provide 7 categories: Work, Personal, Shopping, Health, Finance, Important, Ideas
- FR-2.3.2: System shall use Material Icons (briefcase, home, cart, heart, dollar, star, lightbulb)
- FR-2.3.3: System shall render icons at 20px size
- FR-2.3.4: System shall allow "None" option (no icon)

#### FR-2.4: Grouping by Age
**Priority:** Medium
**Description:** System shall group notes by age when user has 11+ notes.

**Requirements:**
- FR-2.4.1: System shall activate grouping at 11 or more notes
- FR-2.4.2: System shall create three groups: "Today", "This Week", "Older"
- FR-2.4.3: System shall define "Today" as notes created in last 24 hours
- FR-2.4.4: System shall define "This Week" as notes created in last 7 days (excluding today)
- FR-2.4.5: System shall define "Older" as notes created more than 7 days ago
- FR-2.4.6: System shall expand all groups by default on first view
- FR-2.4.7: System shall persist expand/collapse state per session
- FR-2.4.8: System shall show note count in collapsed group headers: "Older (8)"
- FR-2.4.9: System shall animate group expand/collapse (300ms, 50ms stagger)
- FR-2.4.10: System shall exclude pinned notes from grouping
- FR-2.4.11: System shall hide empty groups

**Acceptance Criteria:** See [features/grouping_by_age.feature](features/grouping_by_age.feature)

#### FR-2.5: Sorting Options
**Priority:** Medium
**Description:** Users shall be able to sort notes by multiple criteria.

**Requirements:**
- FR-2.5.1: System shall provide 5 sort options: Creation Date (Newest/Oldest), Updated Date (Newest/Oldest), Priority (High to Low), Manual
- FR-2.5.2: System shall persist sort preference across sessions
- FR-2.5.3: System shall keep pinned notes at top regardless of sort
- FR-2.5.4: System shall disable drag-and-drop when not in Manual sort mode

### 1.3 Text Formatting

#### FR-3.1: Basic Formatting
**Priority:** Medium
**Description:** Users shall be able to format note text.

**Requirements:**
- FR-3.1.1: System shall support bold, italic, and underline formatting
- FR-3.1.2: System shall allow combining multiple text styles
- FR-3.1.3: System shall provide toggle buttons in editor toolbar
- FR-3.1.4: System shall persist formatting in note content
- FR-3.1.5: System shall support three font sizes: Small (12pt), Medium (14pt), Large (16pt)
- FR-3.1.6: System shall default to Medium font size

#### FR-3.2: List Formatting
**Priority:** Low
**Description:** Users shall be able to create bulleted and checkbox lists.

**Requirements:**
- FR-3.2.1: System shall support bullet points and checkboxes
- FR-3.2.2: System shall allow toggling checkbox state
- FR-3.2.3: System shall persist checkbox states
- FR-3.2.4: System shall apply list formatting to entire note content
- FR-3.2.5: System shall not allow mixing regular text with lists

### 1.4 Search Functionality

#### FR-4.1: Search Interface
**Priority:** High
**Description:** Users shall be able to search notes by content.

**Requirements:**
- FR-4.1.1: System shall provide search icon in app bar
- FR-4.1.2: System shall slide down search bar (250ms animation)
- FR-4.1.3: System shall auto-focus search input and show keyboard
- FR-4.1.4: System shall search in real-time with 200ms debounce
- FR-4.1.5: System shall search only active (non-archived) notes
- FR-4.1.6: System shall perform case-insensitive matching
- FR-4.1.7: System shall match partial words
- FR-4.1.8: System shall search note content and icon category names
- FR-4.1.9: System shall highlight search terms in yellow
- FR-4.1.10: System shall order results by: pinned status, then match relevance, then creation date

**Acceptance Criteria:** See [features/search_functionality.feature](features/search_functionality.feature)

#### FR-4.2: Search Results
**Priority:** High
**Description:** System shall display search results appropriately.

**Requirements:**
- FR-4.2.1: System shall use same card layout as main view
- FR-4.2.2: System shall show "No notes found for '[query]'" when no matches
- FR-4.2.3: System shall provide clear/close search buttons
- FR-4.2.4: System shall disable grouping during search
- FR-4.2.5: System shall restore grouping when search cleared

### 1.5 Pin Functionality

#### FR-5.1: Pin Notes
**Priority:** High
**Description:** Users shall be able to pin important notes to the top.

**Requirements:**
- FR-5.1.1: System shall provide "Pin" option in long-press menu
- FR-5.1.2: System shall move pinned notes to top of list
- FR-5.1.3: System shall display pin icon (24px) in top-right corner
- FR-5.1.4: System shall show snackbar "Note pinned"
- FR-5.1.5: System shall provide selection haptic feedback
- FR-5.1.6: System shall maintain pinned notes at top during all sorting
- FR-5.1.7: System shall preserve relative order of pinned notes
- FR-5.1.8: System shall allow reordering within pinned section
- FR-5.1.9: System shall provide "Unpin" option for pinned notes
- FR-5.1.10: System shall remove pin status when archived (isPinned = false)

**Acceptance Criteria:** See [features/pin_functionality.feature](features/pin_functionality.feature)

### 1.6 Archive View

#### FR-6.1: Archive Navigation
**Priority:** Medium
**Description:** Users shall be able to view and manage archived notes.

**Requirements:**
- FR-6.1.1: System shall provide "Archive" menu option
- FR-6.1.2: System shall display separate archive screen
- FR-6.1.3: System shall show all archived notes
- FR-6.1.4: System shall provide back button to return

#### FR-6.2: Archive Actions
**Priority:** Medium
**Description:** Users shall be able to restore or permanently delete archived notes.

**Requirements:**
- FR-6.2.1: System shall provide "Restore" option in long-press menu
- FR-6.2.2: System shall move restored note to main screen bottom
- FR-6.2.3: System shall set isArchived = false on restore
- FR-6.2.4: System shall show snackbar "Note restored"
- FR-6.2.5: System shall provide "Delete permanently" option
- FR-6.2.6: System shall show confirmation dialog before permanent deletion

#### FR-6.3: Bulk Actions
**Priority:** Low
**Description:** Users shall be able to perform bulk operations on archived notes.

**Requirements:**
- FR-6.3.1: System shall enter selection mode on long-press
- FR-6.3.2: System shall display checkboxes on all archived notes
- FR-6.3.3: System shall provide "Select All" action
- FR-6.3.4: System shall show action bar with "Restore" and "Delete" options
- FR-6.3.5: System shall confirm bulk delete with count: "Delete 5 notes permanently?"
- FR-6.3.6: System shall exit selection mode on back button

### 1.7 Dark Mode

#### FR-7.1: Theme Support
**Priority:** Medium
**Description:** System shall support light, dark, and system themes.

**Requirements:**
- FR-7.1.1: System shall provide three theme modes: Light, Dark, System
- FR-7.1.2: System shall persist theme preference
- FR-7.1.3: System shall switch theme with <50ms latency
- FR-7.1.4: System shall maintain WCAG AA contrast in both modes
- FR-7.1.5: System shall adjust all 10 note colors for dark mode

---

## 2. NON-FUNCTIONAL REQUIREMENTS

### 2.1 Performance Requirements

#### NFR-1.1: Responsiveness
**Priority:** Critical

| Metric | Target | Measurement |
|--------|--------|-------------|
| Cold start time | < 2 seconds | Time from app launch to interactive main screen |
| Note creation save | < 100ms | Time from save button tap to persistence complete |
| List scrolling | 60 FPS | Frame rate during scroll with 1000 notes |
| Search response | < 200ms | Debounce delay before search executes |
| Animation frame rate | 60 FPS | All animations maintain 60 FPS |
| Theme switch | < 50ms | Time from theme toggle to UI update |

#### NFR-1.2: Scalability
**Priority:** High

- NFR-1.2.1: System shall support up to 1000 notes without performance degradation
- NFR-1.2.2: System shall load maximum 50 notes in memory at once (lazy loading)
- NFR-1.2.3: System shall maintain <100MB memory usage with 1000 notes
- NFR-1.2.4: System shall implement virtual scrolling for lists >100 notes

### 2.2 Accessibility Requirements

#### NFR-2.1: Screen Reader Support
**Priority:** Critical

- NFR-2.1.1: System shall support VoiceOver (iOS)
- NFR-2.1.2: System shall support TalkBack (Android)
- NFR-2.1.3: System shall announce all button actions
- NFR-2.1.4: System shall read note content in full
- NFR-2.1.5: System shall announce priority, color, and pin status
- NFR-2.1.6: System shall provide semantic labels for all interactive elements

#### NFR-2.2: Visual Accessibility
**Priority:** Critical

- NFR-2.2.1: System shall meet WCAG AA contrast requirements (4.5:1 for normal text, 3:1 for large text)
- NFR-2.2.2: System shall support system font scaling (50%-200%)
- NFR-2.2.3: System shall provide minimum 44x44pt touch targets
- NFR-2.2.4: System shall not use color as sole information indicator
- NFR-2.2.5: System shall provide visible focus indicators

#### NFR-2.3: Motor Accessibility
**Priority:** High

- NFR-2.3.1: System shall support keyboard navigation (future enhancement)
- NFR-2.3.2: System shall provide alternative to swipe gestures (long-press menu)
- NFR-2.3.3: System shall allow 500ms long-press threshold configuration

### 2.3 Security Requirements

#### NFR-3.1: Data Protection
**Priority:** High

- NFR-3.1.1: System shall store notes using Flutter's Hive (encrypted box)
- NFR-3.1.2: System shall integrate with device security (lock screen)
- NFR-3.1.3: System shall not transmit data over network (offline-first)
- NFR-3.1.4: System shall clear clipboard after 60 seconds (when note content copied)

#### NFR-3.2: Privacy
**Priority:** Critical

- NFR-3.2.1: System shall collect zero analytics in v1.0
- NFR-3.2.2: System shall not require user account
- NFR-3.2.3: System shall not access network permissions
- NFR-3.2.4: System shall store all data locally on device

### 2.4 Reliability Requirements

#### NFR-4.1: Data Integrity
**Priority:** Critical

- NFR-4.1.1: System shall auto-save with 500ms debounce
- NFR-4.1.2: System shall persist all changes before app termination
- NFR-4.1.3: System shall restore state on app resume
- NFR-4.1.4: System shall detect database corruption on startup
- NFR-4.1.5: System shall recover from corruption by exporting valid notes and resetting database

#### NFR-4.2: Error Handling
**Priority:** High

- NFR-4.2.1: System shall display user-friendly error messages
- NFR-4.2.2: System shall distinguish between validation, storage, and unknown errors
- NFR-4.2.3: System shall log errors for debugging (local only, not transmitted)
- NFR-4.2.4: System shall prevent data loss during errors

### 2.5 Maintainability Requirements

#### NFR-5.1: Code Quality
**Priority:** High

- NFR-5.1.1: System shall follow Clean Architecture pattern
- NFR-5.1.2: System shall use BLoC pattern for state management
- NFR-5.1.3: System shall achieve ≥80% test coverage
- NFR-5.1.4: System shall pass flutter analyze with 0 issues
- NFR-5.1.5: System shall follow Dart style guide
- NFR-5.1.6: System shall use conventional commit messages

#### NFR-5.2: Documentation
**Priority:** Medium

- NFR-5.2.1: System shall document all public APIs
- NFR-5.2.2: System shall provide inline comments for complex logic
- NFR-5.2.3: System shall maintain up-to-date README
- NFR-5.2.4: System shall document all design decisions
- NFR-5.2.5: System shall provide Gherkin scenarios for all major features

### 2.6 Usability Requirements

#### NFR-6.1: Learnability
**Priority:** Medium

- NFR-6.1.1: System shall provide minimal onboarding (single screen)
- NFR-6.1.2: System shall show empty state guidance for first-time users
- NFR-6.1.3: System shall use standard Material Design patterns
- NFR-6.1.4: System shall provide tooltips for non-obvious actions

#### NFR-6.2: Efficiency
**Priority:** High

- NFR-6.2.1: System shall allow note creation in ≤3 taps
- NFR-6.2.2: System shall allow note editing in 1 tap
- NFR-6.2.3: System shall support rapid note creation (no throttling)
- NFR-6.2.4: System shall remember user preferences (sort, theme)

### 2.7 Compatibility Requirements

#### NFR-7.1: Platform Support
**Priority:** Critical

- NFR-7.1.1: System shall support iOS 13.0+
- NFR-7.1.2: System shall support Android 6.0+ (API 23+)
- NFR-7.1.3: System shall support phones and tablets
- NFR-7.1.4: System shall require Flutter 3.16+
- NFR-7.1.5: System shall require Dart 3.0+

#### NFR-7.2: Device Compatibility
**Priority:** High

- NFR-7.2.1: System shall support screen sizes from 4" to 12.9"
- NFR-7.2.2: System shall support portrait and landscape orientations
- NFR-7.2.3: System shall adapt to notched displays
- NFR-7.2.4: System shall support both gestures and button navigation

---

## 3. CONSTRAINTS

### 3.1 Technical Constraints

- TC-1: Must use Flutter framework
- TC-2: Must use Hive for local storage
- TC-3: Must use BLoC for state management
- TC-4: Must support offline-only operation (no network)
- TC-5: Must use Material Icons (no custom icon sets)
- TC-6: Must use system fonts (San Francisco/Roboto)

### 3.2 Business Constraints

- BC-1: Maximum 1000 notes per user (hard limit)
- BC-2: Maximum 140 characters per note (hard limit)
- BC-3: No cloud storage in v1.0
- BC-4: No user accounts in v1.0
- BC-5: No analytics in v1.0 (privacy-first)

### 3.3 Regulatory Constraints

- RC-1: Must comply with WCAG AA accessibility standards
- RC-2: Must not collect personal data (GDPR/CCPA compliant by design)
- RC-3: Must store data locally (no third-party data sharing)

---

## 4. ACCEPTANCE CRITERIA

### 4.1 Feature Acceptance

Each feature is considered complete when:
1. All functional requirements are implemented
2. All Gherkin scenarios pass
3. Unit tests achieve ≥80% coverage for that feature
4. Flutter analyze shows 0 issues
5. Manual testing on both iOS and Android succeeds
6. Accessibility testing passes (VoiceOver + TalkBack)

### 4.2 Release Acceptance

Version 1.0 is ready for release when:
1. All critical and high priority requirements are implemented
2. All 61+ tests pass
3. Overall code coverage ≥80%
4. Performance benchmarks met (see NFR-1.1)
5. No critical or high severity bugs
6. Documentation is complete
7. App builds successfully on iOS and Android
8. Manual testing checklist complete

---

## 5. TRACEABILITY MATRIX

### 5.1 Requirements to Features

| Requirement | Feature File | Test File |
|-------------|--------------|-----------|
| FR-1.1 | note_creation.feature | notes_bloc_test.dart (CreateNote) |
| FR-1.4 | archive_and_undo.feature | notes_bloc_test.dart (ArchiveNote, UnarchiveNote) |
| FR-2.4 | grouping_by_age.feature | (UI tests - future) |
| FR-4.1 | search_functionality.feature | notes_bloc_test.dart (SearchNotes) |
| FR-5.1 | pin_functionality.feature | notes_bloc_test.dart (PinNote, UnpinNote) |

### 5.2 Requirements to Tests

| Requirement | Unit Tests | Integration Tests | Gherkin Scenarios |
|-------------|------------|-------------------|-------------------|
| FR-1.1 | ✅ 3 tests | ⏸️ Pending UI | ✅ 7 scenarios |
| FR-1.2 | ✅ 2 tests | ⏸️ Pending UI | ⏸️ Pending |
| FR-1.3 | ✅ 2 tests | ⏸️ Pending UI | ✅ 2 scenarios |
| FR-1.4 | ✅ 4 tests | ⏸️ Pending UI | ✅ 7 scenarios |
| FR-2.4 | ⏸️ Pending UI | ⏸️ Pending UI | ✅ 9 scenarios |
| FR-4.1 | ✅ 5 tests | ⏸️ Pending UI | ✅ 13 scenarios |
| FR-5.1 | ✅ 4 tests | ⏸️ Pending UI | ✅ 10 scenarios |
| FR-6.2 | ✅ 2 tests | ⏸️ Pending UI | ✅ 15 scenarios |

### 5.3 Tests to Documentation

| Test Type | Location | Coverage |
|-----------|----------|----------|
| Unit Tests | test/unit/ | Data + BLoC layers |
| Widget Tests | test/widget/ | UI components (pending) |
| Integration Tests | test/integration/ | End-to-end flows (pending) |
| Gherkin Scenarios | features/ | User acceptance criteria |
| Performance Tests | test/performance/ | Benchmarks (pending) |

---

## Appendix A: Glossary

- **Active Note**: A note that is not archived (isArchived = false)
- **Archived Note**: A note hidden from main view (isArchived = true)
- **Pinned Note**: A note that appears at the top (isPinned = true)
- **Manual Order**: User-defined ordering via drag-and-drop (manualOrder field)
- **Debounce**: Delay before action executes to reduce redundant operations
- **Haptic Feedback**: Vibration feedback for touch interactions
- **Sticking Animation**: Elastic bounce effect when dropping reordered notes
- **WCAG AA**: Web Content Accessibility Guidelines Level AA

---

## Appendix B: Change Log

| Version | Date | Changes | Author |
|---------|------|---------|--------|
| 1.0 | 2026-02-03 | Initial requirements specification | AI Development Team |

---

**Document Status:** ✅ Approved for Development
**Next Review:** After v1.0 Release
