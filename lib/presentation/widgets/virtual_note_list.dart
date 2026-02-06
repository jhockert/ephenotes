import 'package:flutter/material.dart';
import 'package:ephenotes/data/models/note.dart';
import 'package:ephenotes/presentation/widgets/note_card.dart';

/// A virtual scrolling list widget optimized for large note collections.
///
/// Features:
/// - Virtual scrolling for >100 notes
/// - Memory-efficient rendering (only visible items)
/// - Smooth 60 FPS scrolling performance
/// - Configurable item height estimation
/// - Support for custom item builders
class VirtualNoteList extends StatefulWidget {
  final List<Note> notes;
  final Function(Note) onNoteTap;
  final Function(Note)? onNoteLongPress;
  final Widget Function(Note)? customItemBuilder;
  final double estimatedItemHeight;
  final EdgeInsets? padding;
  final ScrollController? controller;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const VirtualNoteList({
    super.key,
    required this.notes,
    required this.onNoteTap,
    this.onNoteLongPress,
    this.customItemBuilder,
    this.estimatedItemHeight = 120.0, // Estimated height for note cards
    this.padding,
    this.controller,
    this.shrinkWrap = false,
    this.physics,
  });

  @override
  State<VirtualNoteList> createState() => _VirtualNoteListState();
}

class _VirtualNoteListState extends State<VirtualNoteList> {
  late ScrollController _scrollController;
  final Map<int, double> _itemHeights = {};
  final GlobalKey _listKey = GlobalKey();

  // Performance optimization: cache visible range
  int _firstVisibleIndex = 0;
  int _lastVisibleIndex = 0;

  // Memory optimization: limit rendered items
  static const int _maxRenderedItems = 50;
  static const int _bufferItems = 10;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.controller ?? ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _scrollController.dispose();
    } else {
      _scrollController.removeListener(_onScroll);
    }
    super.dispose();
  }

  void _onScroll() {
    _updateVisibleRange();
  }

  void _updateVisibleRange() {
    if (!_scrollController.hasClients || widget.notes.isEmpty) return;

    final scrollOffset = _scrollController.offset;
    final viewportHeight = _scrollController.position.viewportDimension;

    // Calculate visible range based on estimated heights
    int firstVisible = 0;
    int lastVisible = widget.notes.length - 1;

    double currentOffset = 0;
    for (int i = 0; i < widget.notes.length; i++) {
      final itemHeight = _itemHeights[i] ?? widget.estimatedItemHeight;

      if (currentOffset + itemHeight >= scrollOffset && firstVisible == 0) {
        firstVisible = i;
      }

      if (currentOffset <= scrollOffset + viewportHeight) {
        lastVisible = i;
      }

      currentOffset += itemHeight;

      if (currentOffset > scrollOffset + viewportHeight && lastVisible < i) {
        break;
      }
    }

    // Add buffer items for smooth scrolling
    firstVisible =
        (firstVisible - _bufferItems).clamp(0, widget.notes.length - 1);
    lastVisible =
        (lastVisible + _bufferItems).clamp(0, widget.notes.length - 1);

    // Limit total rendered items for memory efficiency
    if (lastVisible - firstVisible > _maxRenderedItems) {
      lastVisible = firstVisible + _maxRenderedItems;
    }

    if (firstVisible != _firstVisibleIndex ||
        lastVisible != _lastVisibleIndex) {
      setState(() {
        _firstVisibleIndex = firstVisible;
        _lastVisibleIndex = lastVisible;
      });
    }
  }

  double _getItemOffset(int index) {
    double offset = 0;
    for (int i = 0; i < index; i++) {
      offset += _itemHeights[i] ?? widget.estimatedItemHeight;
    }
    return offset;
  }

  double _getTotalHeight() {
    double height = 0;
    for (int i = 0; i < widget.notes.length; i++) {
      height += _itemHeights[i] ?? widget.estimatedItemHeight;
    }
    return height;
  }

  void _measureItem(int index, double height) {
    if (_itemHeights[index] != height) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _itemHeights[index] = height;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.notes.isEmpty) {
      return const SizedBox.shrink();
    }

    // For small lists, use regular ListView for simplicity
    if (widget.notes.length <= 100) {
      return _buildRegularList();
    }

    return _buildVirtualList();
  }

  Widget _buildRegularList() {
    return ListView.builder(
      key: _listKey,
      controller: _scrollController,
      padding: widget.padding ?? const EdgeInsets.all(8.0),
      shrinkWrap: widget.shrinkWrap,
      physics: widget.physics,
      itemCount: widget.notes.length,
      itemBuilder: (context, index) {
        return _buildNoteItem(widget.notes[index], index);
      },
    );
  }

  Widget _buildVirtualList() {
    // Update visible range on first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateVisibleRange();
    });

    return CustomScrollView(
      key: _listKey,
      controller: _scrollController,
      shrinkWrap: widget.shrinkWrap,
      physics: widget.physics,
      slivers: [
        if (widget.padding != null)
          SliverPadding(
            padding: widget.padding!,
            sliver: _buildVirtualSliver(),
          )
        else
          _buildVirtualSliver(),
      ],
    );
  }

  Widget _buildVirtualSliver() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          // Add spacer before visible items
          if (index == 0 && _firstVisibleIndex > 0) {
            final spacerHeight = _getItemOffset(_firstVisibleIndex);
            return SizedBox(height: spacerHeight);
          }

          // Adjust index for visible range
          final noteIndex = index == 0 && _firstVisibleIndex > 0
              ? _firstVisibleIndex
              : _firstVisibleIndex + index - (_firstVisibleIndex > 0 ? 1 : 0);

          // Add spacer after visible items
          if (noteIndex > _lastVisibleIndex) {
            final remainingHeight =
                _getTotalHeight() - _getItemOffset(_lastVisibleIndex + 1);
            return SizedBox(height: remainingHeight);
          }

          if (noteIndex >= widget.notes.length) {
            return null;
          }

          return _buildNoteItem(widget.notes[noteIndex], noteIndex);
        },
        childCount: _calculateChildCount(),
      ),
    );
  }

  int _calculateChildCount() {
    int count = _lastVisibleIndex - _firstVisibleIndex + 1;

    // Add spacer items
    if (_firstVisibleIndex > 0) count++; // Top spacer
    if (_lastVisibleIndex < widget.notes.length - 1) count++; // Bottom spacer

    return count;
  }

  Widget _buildNoteItem(Note note, int index) {
    Widget child;

    if (widget.customItemBuilder != null) {
      child = widget.customItemBuilder!(note);
    } else {
      child = NoteCard(
        note: note,
        onTap: () => widget.onNoteTap(note),
      );
    }

    // Wrap with gesture detector for long press if provided
    if (widget.onNoteLongPress != null) {
      child = GestureDetector(
        onLongPress: () => widget.onNoteLongPress!(note),
        child: child,
      );
    }

    // Wrap with measurement widget to track item heights
    return _MeasurableItem(
      index: index,
      onMeasured: _measureItem,
      child: child,
    );
  }
}

/// Widget that measures its height and reports it back to the parent.
class _MeasurableItem extends StatefulWidget {
  final int index;
  final Function(int index, double height) onMeasured;
  final Widget child;

  const _MeasurableItem({
    required this.index,
    required this.onMeasured,
    required this.child,
  });

  @override
  State<_MeasurableItem> createState() => _MeasurableItemState();
}

class _MeasurableItemState extends State<_MeasurableItem> {
  final GlobalKey _key = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(_measureHeight);
  }

  @override
  void didUpdateWidget(_MeasurableItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.index != widget.index) {
      WidgetsBinding.instance.addPostFrameCallback(_measureHeight);
    }
  }

  void _measureHeight(dynamic _) {
    final renderBox = _key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final height = renderBox.size.height;
      widget.onMeasured(widget.index, height);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: _key,
      child: widget.child,
    );
  }
}
