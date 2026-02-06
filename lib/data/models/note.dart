import 'package:objectbox/objectbox.dart';
import 'package:equatable/equatable.dart';

/// Represents a virtual post-it note with content, styling, and metadata.
///
/// Notes support text formatting, priority levels, color coding, and icon
/// categorization. They can be pinned and archived.
///
/// Example:
/// ```dart
/// final note = Note(
///   id: uuid.v4(),
///   content: 'Buy groceries',
///   createdAt: DateTime.now(),
///   updatedAt: DateTime.now(),
///   color: NoteColor.classicYellow,
///   priority: NotePriority.high,
/// );
/// ```
@Entity()
// ignore: must_be_immutable
class Note extends Equatable {
  @Id()
  int objectBoxId; // ObjectBox auto-increment ID (not final - ObjectBox sets this)
  
  @Unique()
  final String id; // UUID for app-level identification

  final String content;

  @Property(type: PropertyType.date)
  final DateTime createdAt;

  @Property(type: PropertyType.date)
  final DateTime updatedAt;

  final int colorIndex; // Store enum as int
  final int priorityIndex; // Store enum as int
  final int? iconCategoryIndex; // Store enum as int

  final bool isPinned;
  final bool isArchived;

  final bool isBold;
  final bool isItalic;
  final bool isUnderlined;

  final int fontSizeIndex; // Store enum as int
  final int listTypeIndex; // Store enum as int

  // Transient properties for enum access
  @Transient()
  NoteColor get color => NoteColor.values[colorIndex];
  
  @Transient()
  NotePriority get priority => NotePriority.values[priorityIndex];
  
  @Transient()
  IconCategory? get iconCategory => 
      iconCategoryIndex != null ? IconCategory.values[iconCategoryIndex!] : null;
  
  @Transient()
  FontSize get fontSize => FontSize.values[fontSizeIndex];
  
  @Transient()
  ListType get listType => ListType.values[listTypeIndex];

  Note({
    this.objectBoxId = 0,
    required this.id,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    NoteColor color = NoteColor.classicYellow,
    NotePriority priority = NotePriority.normal,
    IconCategory? iconCategory,
    this.isPinned = false,
    this.isArchived = false,
    this.isBold = false,
    this.isItalic = false,
    this.isUnderlined = false,
    FontSize fontSize = FontSize.medium,
    ListType listType = ListType.none,
  })  : colorIndex = color.index,
        priorityIndex = priority.index,
        iconCategoryIndex = iconCategory?.index,
        fontSizeIndex = fontSize.index,
        listTypeIndex = listType.index;

  /// Creates a copy of this Note with the given fields replaced with new values.
  Note copyWith({
    int? objectBoxId,
    String? id,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
    NoteColor? color,
    NotePriority? priority,
    IconCategory? iconCategory,
    bool? isPinned,
    bool? isArchived,
    bool? isBold,
    bool? isItalic,
    bool? isUnderlined,
    FontSize? fontSize,
    ListType? listType,
  }) {
    return Note(
      objectBoxId: objectBoxId ?? this.objectBoxId,
      id: id ?? this.id,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      color: color ?? this.color,
      priority: priority ?? this.priority,
      iconCategory: iconCategory ?? this.iconCategory,
      isPinned: isPinned ?? this.isPinned,
      isArchived: isArchived ?? this.isArchived,
      isBold: isBold ?? this.isBold,
      isItalic: isItalic ?? this.isItalic,
      isUnderlined: isUnderlined ?? this.isUnderlined,
      fontSize: fontSize ?? this.fontSize,
      listType: listType ?? this.listType,
    );
  }

  @override
  List<Object?> get props => [
        objectBoxId,
        id,
        content,
        createdAt,
        updatedAt,
        colorIndex,
        priorityIndex,
        iconCategoryIndex,
        isPinned,
        isArchived,
        isBold,
        isItalic,
        isUnderlined,
        fontSizeIndex,
        listTypeIndex,
      ];
}

/// Note color options for visual organization (10 colors).
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
  rose,
}

/// Priority levels for notes.
/// 
/// Normal priority is the default and is not displayed visually.
/// Users can set High or Low priority as needed.
enum NotePriority {
  high,
  normal, // Default, not displayed
  low,
}

/// Icon categories for functional organization.
enum IconCategory {
  work,
  personal,
  shopping,
  health,
  finance,
  important,
  ideas,
}

/// Font size options for note content.
enum FontSize {
  small,
  medium,
  large,
}

/// List formatting type for note content.
enum ListType {
  none,
  bullets,
  checkboxes,
}
