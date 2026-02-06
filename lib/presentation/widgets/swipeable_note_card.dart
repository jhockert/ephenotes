import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:ephenotes/core/constants/ui_strings.dart';
import 'package:ephenotes/core/utils/accessibility_helper.dart';
import 'package:ephenotes/data/models/note.dart';
import 'package:ephenotes/presentation/widgets/note_card.dart';

/// A swipeable note card with 50% threshold and visual feedback.
///
/// Implements US-1.3: Archive with Undo Safety requirements:
/// - Requires >50% screen width swipe to trigger archive
/// - Provides visual feedback during swipe (color intensity changes)
/// - Shows progress indicator with icon size changes
/// - Haptic feedback at 50% threshold
/// - Smooth animations for threshold crossing
/// - Accessible gesture with semantic hints
/// - Works on different screen sizes
class SwipeableNoteCard extends StatefulWidget {
  final Note note;
  final VoidCallback onTap;
  final Function(Note) onArchive;
  final bool isRestore;
  final bool showMetadata;

  const SwipeableNoteCard({
    super.key,
    required this.note,
    required this.onTap,
    required this.onArchive,
    this.isRestore = false,
    this.showMetadata = true,
  });

  @override
  State<SwipeableNoteCard> createState() => _SwipeableNoteCardState();
}

class _SwipeableNoteCardState extends State<SwipeableNoteCard>
    with SingleTickerProviderStateMixin {
  bool _hasReachedThreshold = false;
  late AnimationController _thresholdAnimationController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    // Animation controller for threshold crossing pulse effect
    _thresholdAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _thresholdAnimationController,
        curve: Curves.elasticOut,
      ),
    );
  }

  @override
  void dispose() {
    _thresholdAnimationController.dispose();
    super.dispose();
  }

  void _onSwipeUpdate(SlidableController controller) {
    // Calculate progress based on the ratio
    final ratio = controller.ratio.abs();
    final progress = (ratio / 0.5).clamp(0.0, 1.0);

    // Check if threshold is reached (50% = progress 1.0)
    final thresholdReached = progress >= 1.0;

    if (thresholdReached && !_hasReachedThreshold) {
      // Threshold just crossed - trigger haptic feedback and animation
      HapticFeedback.mediumImpact();
      setState(() {
        _hasReachedThreshold = true;
      });
      _thresholdAnimationController.forward(from: 0.0);
    } else if (!thresholdReached && _hasReachedThreshold) {
      // User pulled back below threshold
      setState(() {
        _hasReachedThreshold = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: ValueKey(widget.note.id),
      // Set 50% threshold for archive gesture
      endActionPane: _buildActionPane(isEnd: true),
      startActionPane: _buildActionPane(isEnd: false),
      child: NoteCard(
        note: widget.note,
        onTap: widget.onTap,
        showMetadata: widget.showMetadata,
      ),
    );
  }

  /// Builds the action pane with 50% threshold configuration and progress indicator.
  ///
  /// The [isEnd] parameter determines if this is the end (right) or start (left) action pane.
  ActionPane _buildActionPane({required bool isEnd}) {
    return ActionPane(
      motion: const StretchMotion(), // Changed from DrawerMotion for smoother swipe
      extentRatio: 0.5, // Requires 50% of screen width to trigger
      dismissible: DismissiblePane(
        onDismissed: () {
          widget.onArchive(widget.note);
        },
        dismissThreshold: 0.5, // Must swipe 50% to dismiss
        closeOnCancel: true, // Automatically close if swipe is cancelled
        confirmDismiss: () async {
          return true;
        },
      ),
      children: [
        // Custom slidable action with progress indicator
        Builder(
          builder: (context) {
            // Access the slidable controller to track progress
            final controller = Slidable.of(context);
            if (controller != null) {
              // Update swipe progress
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  _onSwipeUpdate(controller);
                }
              });
            }

            return CustomSlidableAction(
              onPressed: (_) {
                widget.onArchive(widget.note);
              },
              backgroundColor: Colors.transparent,
              child: _buildProgressIndicator(controller),
            );
          },
        ),
      ],
    );
  }

  /// Builds the progress indicator with visual feedback.
  ///
  /// Features:
  /// - Color intensity increases as swipe progresses
  /// - Icon size grows as swipe progresses
  /// - Smooth animation when crossing 50% threshold
  Widget _buildProgressIndicator(SlidableController? controller) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate swipe progress (0.0 to 1.0)
        double progress = 0.0;
        if (controller != null) {
          final ratio = controller.ratio.abs();
          progress = (ratio / 0.5).clamp(0.0, 1.0);
        }

        // Calculate visual feedback values
        final baseColor = widget.isRestore ? Colors.green : Colors.red;
        final colorIntensity = 0.3 + (progress * 0.7);
        final backgroundColor = baseColor.withValues(alpha: colorIntensity);

        // Icon size: from 24 to 40 as swipe progresses
        final baseIconSize = 24.0;
        final maxIconSize = 40.0;
        final iconSize = baseIconSize + (progress * (maxIconSize - baseIconSize));

        // Threshold reached state
        final thresholdReached = progress >= 1.0;

        return AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            // Apply pulse scale when threshold is reached
            final pulseScale = _hasReachedThreshold ? _pulseAnimation.value : 1.0;

            final actionLabel = widget.isRestore
                ? UiStrings.restore
                : UiStrings.archive;

            return Semantics(
              label: widget.isRestore
                  ? 'Restore note'
                  : AccessibilityHelper.getArchiveActionSemanticLabel(),
              hint: thresholdReached
                  ? 'Release to ${actionLabel.toLowerCase()} note'
                  : 'Swipe more than 50% of screen width to ${actionLabel.toLowerCase()}',
              button: true,
              child: Container(
                width: constraints.maxWidth,
                height: constraints.maxHeight,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Animated icon with size and scale changes
                      Transform.scale(
                        scale: pulseScale,
                        child: Icon(
                          widget.isRestore ? Icons.unarchive : Icons.archive,
                          size: iconSize,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: thresholdReached ? 14 : 12,
                          fontWeight: thresholdReached
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                        child: Text(
                          actionLabel.toUpperCase(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
