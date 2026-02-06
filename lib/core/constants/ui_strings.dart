/// Centralized UI string constants for the ephenotes app.
///
/// All user-facing strings are defined here to avoid hardcoded strings
/// throughout the codebase and to support future i18n.
class UiStrings {
  UiStrings._();

  // ── App-wide ──────────────────────────────────────────────────────────
  static const appTitle = 'ephenotes';
  static const ok = 'OK';
  static const cancel = 'Cancel';
  static const save = 'Save';
  static const delete = 'Delete';
  static const undo = 'UNDO';

  // ── Notes List Screen ─────────────────────────────────────────────────
  static const searchNotesLabel = 'Search notes';
  static const searchNotesHint = 'Double tap to open search screen';
  static const settingsLabel = 'Settings';
  static const settingsHint = 'Double tap to open settings screen';
  static const settingsTooltip = 'Settings';
  static const archiveLabel = 'Archive';
  static const archiveHint = 'Double tap to view archived notes';
  static const createNoteHint = 'Double tap to create a new note';
  static const createNoteTooltip = 'Create Note';
  static const noteOptionsMenuLabel = 'Note options menu';

  // ── Empty States ──────────────────────────────────────────────────────
  static const noNotesYet = 'No notes yet';
  static const createFirstNote = 'Tap + to create your first note';
  static const priorityOrganizer =
      'Notes are automatically organized by priority';
  static const priorityOrder = 'High \u2192 Normal \u2192 Low';
  static const noArchivedNotes = 'No archived notes';
  static const swipeToArchive = 'Swipe notes to archive them';
  static const restoreNoteInfo =
      'Restored notes return to their priority position';
  static const searchResultsOrder = 'Search results are ordered by priority';
  static String noNotesFound(String query) => 'No notes found for "$query"';

  // ── Actions ───────────────────────────────────────────────────────────
  static const pin = 'Pin';
  static const unpin = 'Unpin';
  static const archive = 'Archive';
  static const restore = 'Restore';
  static const deletePermanently = 'Delete permanently';
  static const recover = 'Recover';
  static const openSettings = 'Open Settings';

  // ── Snackbar Messages ─────────────────────────────────────────────────
  static const notePinned = 'Note pinned';
  static const noteUnpinned = 'Note unpinned';
  static const noteArchived = 'Note archived';
  static const noteRestored = 'Note restored';
  static const noteDeletedPermanently = 'Note deleted permanently';
  static const attemptingDataRecovery = 'Attempting data recovery...';
  static const checkPermissions =
      'Please check app permissions in device settings';

  // ── Note Editor ───────────────────────────────────────────────────────
  static const newNote = 'New Note';
  static const editNote = 'Edit Note';
  static const saveNoteLabel = 'Save note';
  static const saveNoteHint =
      'Double tap to save the note and return to the main screen';
  static const noteContentFieldLabel = 'Note content text field';
  static const noteContentFieldHint =
      'Enter your note content here. Maximum 140 characters.';
  static const enterNotePlaceholder = 'Enter your note...';
  static const noteCannotBeEmpty = 'Note cannot be empty';

  // ── Text Formatting ───────────────────────────────────────────────────
  static const textFormattingLabel = 'Text formatting options';
  static const textFormattingTitle = 'Text Formatting';
  static const bold = 'Bold';
  static const italic = 'Italic';
  static const underline = 'Underline';
  static String fontSize(String name) => 'Font size: $name';
  static const fontSizeSmall = 'Small';
  static const fontSizeMedium = 'Medium';
  static const fontSizeLarge = 'Large';

  // ── Theme ─────────────────────────────────────────────────────────────
  static const themeSystem = 'Theme: System';
  static const themeLight = 'Theme: Light';
  static const themeDark = 'Theme: Dark';
  static const themeSectionTitle = 'Theme';
  static const themeSystemOption = 'System';
  static const themeLightOption = 'Light';
  static const themeDarkOption = 'Dark';

  // ── Search ────────────────────────────────────────────────────────────
  static const searchNotesPlaceholder = 'Search notes...';

  // ── Settings ──────────────────────────────────────────────────────────
  static const settingsScreenTitle = 'Settings';

  // ── Archive Screen ────────────────────────────────────────────────────
  static const archiveScreenTitle = 'Archive';
  static String errorPrefix(String message) => 'Error: $message';

  // ── Delete Confirmation ───────────────────────────────────────────────
  static const deleteNoteTitle = 'Delete Note?';
  static const deleteNoteContent =
      'This note will be permanently deleted. This action cannot be undone.';

  // ── Data Recovery Dialog ──────────────────────────────────────────────
  static const dataRecoveryTitle = 'Data Recovery';
  static const dataRecoveryContent =
      'We\'ll attempt to recover your notes from the corrupted database. '
      'This may take a few moments and some recent changes might be lost.';

  // ── Storage Permission Dialog ─────────────────────────────────────────
  static const storagePermissionTitle = 'Storage Permission';
  static const storagePermissionContent =
      'ephenotes needs storage permission to save your notes. '
      'Please go to your device settings and grant storage permission to this app.';

  // ── Help Dialog ───────────────────────────────────────────────────────
  static const needHelpTitle = 'Need Help?';
  static const tryTheseSteps = 'Try these steps:';
  static const helpRestartApp = '\u2022 Restart the app';
  static const helpCheckStorage = '\u2022 Check available storage space';
  static const helpUpdateApp = '\u2022 Update the app if available';
  static const helpAutoResolve =
      'If the problem persists, the issue may resolve itself automatically.';

  // ── Error Display ─────────────────────────────────────────────────────
  static const whatWouldYouLikeToDo = 'What would you like to do?';
  static const technicalDetails = 'Technical Details';
  static String errorType(String name) => 'Error Type: $name';
  static String details(String detail) => 'Details: $detail';
  static const storageIssueTitle = 'Storage Issue';
  static const inputErrorTitle = 'Input Error';
  static const connectionProblemTitle = 'Connection Problem';
  static const somethingWentWrongTitle = 'Something Went Wrong';
  static const storageHelpText =
      'This usually happens when there\'s not enough storage space or the database needs repair.';
  static const validationHelpText =
      'Please check your input and make sure it meets the requirements.';
  static const networkHelpText =
      'Check your internet connection and try again.';
  static const unknownErrorHelpText =
      'If this problem persists, try restarting the app.';

  // ── Note Card ─────────────────────────────────────────────────────────
  static const thisNoteIsPinned = 'This note is pinned';
  static String noteContent(String content) => 'Note content: $content';
  static const priorityHighBadge = 'HIGH';
  static const priorityNormalBadge = 'NORMAL'; // Not displayed, but kept for consistency
  static const priorityLowBadge = 'LOW';
  static const timestampJustNow = 'Just now';
  static String timestampMinutesAgo(int minutes) => '${minutes}m ago';
  static String timestampHoursAgo(int hours) => '${hours}h ago';
  static String timestampDaysAgo(int days) => '${days}d ago';

  // ── Color Picker ──────────────────────────────────────────────────────
  static const colorPickerLabel = 'Color picker';
  static const colorSectionTitle = 'Color';
  static const colorOptionsLabel = 'Color options';
  static String selectedColor(String name) => 'Selected color: $name';
  static const colorClassicYellow = 'Classic Yellow';
  static const colorCoralPink = 'Coral Pink';
  static const colorSkyBlue = 'Sky Blue';
  static const colorMintGreen = 'Mint Green';
  static const colorLavender = 'Lavender';
  static const colorPeach = 'Peach';
  static const colorTeal = 'Teal';
  static const colorLightGray = 'Light Gray';
  static const colorLemon = 'Lemon';
  static const colorRose = 'Rose';

  // ── Priority Selector ─────────────────────────────────────────────────
  static const prioritySelectorLabel = 'Priority selector';
  static const prioritySectionTitle = 'Priority';
  static const priorityOptionsLabel = 'Priority options';
  static const priorityHigh = 'High';
  static const priorityNormal = 'Normal';
  static const priorityLow = 'Low';

  // ── Icon Selector ─────────────────────────────────────────────────────
  static const iconSelectorLabel = 'Icon category selector';
  static const categoryIconTitle = 'Category Icon';
  static const iconOptionsLabel = 'Icon category options';
  static const iconNone = 'None';
  static const iconWork = 'Work';
  static const iconPersonal = 'Personal';
  static const iconShopping = 'Shopping';
  static const iconHealth = 'Health';
  static const iconFinance = 'Finance';
  static const iconImportant = 'Important';
  static const iconIdeas = 'Ideas';
}
