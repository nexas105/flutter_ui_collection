import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../../theme/ui_theme.dart';

/// A themed infinite-scroll list with automatic pagination.
///
/// Triggers [onLoadMore] when the user scrolls near the bottom. Shows a
/// themed loading indicator while loading and an empty state when there
/// are no items.
///
/// ```dart
/// UiInfiniteList<Post>(
///   items: posts,
///   itemBuilder: (context, post, index) => PostCard(post: post),
///   onLoadMore: () => fetchNextPage(),
///   hasMore: hasNextPage,
/// )
/// ```
class UiInfiniteList<T> extends StatefulWidget {
  const UiInfiniteList({
    super.key,
    required this.items,
    required this.itemBuilder,
    required this.onLoadMore,
    this.hasMore = true,
    this.loadingBuilder,
    this.emptyBuilder,
    this.separatorBuilder,
    this.loadMoreThreshold = 200.0,
    this.padding,
  });

  /// The current list of items.
  final List<T> items;

  /// Builds a widget for each item.
  final Widget Function(BuildContext context, T item, int index) itemBuilder;

  /// Called when the user scrolls near the bottom and [hasMore] is true.
  final Future<void> Function() onLoadMore;

  /// Whether there are more items to load.
  final bool hasMore;

  /// Optional custom loading widget shown at the bottom while loading.
  final WidgetBuilder? loadingBuilder;

  /// Optional widget shown when [items] is empty and [hasMore] is false.
  final WidgetBuilder? emptyBuilder;

  /// Optional separator between items.
  final IndexedWidgetBuilder? separatorBuilder;

  /// Distance from the bottom (in pixels) at which to trigger [onLoadMore].
  final double loadMoreThreshold;

  /// Padding around the list.
  final EdgeInsets? padding;

  @override
  State<UiInfiniteList<T>> createState() => _UiInfiniteListState<T>();
}

class _UiInfiniteListState<T> extends State<UiInfiniteList<T>>
    with SingleTickerProviderStateMixin {
  late final ScrollController _scrollController;
  late final AnimationController _spinnerController;
  bool _loadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    _spinnerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _spinnerController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_loadingMore || !widget.hasMore) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    if (maxScroll - currentScroll <= widget.loadMoreThreshold) {
      _triggerLoadMore();
    }
  }

  Future<void> _triggerLoadMore() async {
    if (_loadingMore) return;
    setState(() => _loadingMore = true);
    _spinnerController.repeat();
    try {
      await widget.onLoadMore();
    } finally {
      if (mounted) {
        _spinnerController.stop();
        setState(() => _loadingMore = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final colors = theme.colorScheme;
    final spacing = theme.spacing;
    final typo = theme.typography;

    if (widget.items.isEmpty && !widget.hasMore && !_loadingMore) {
      if (widget.emptyBuilder != null) {
        return widget.emptyBuilder!(context);
      }
      return Center(
        child: Padding(
          padding: spacing.paddingLg,
          child: Text(
            'No items',
            style: typo.bodyLarge.copyWith(
              color: colors.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ),
      );
    }

    final hasSeparator = widget.separatorBuilder != null;
    final itemCount = widget.items.length;
    final totalCount = hasSeparator
        ? (itemCount * 2 - (itemCount > 0 ? 1 : 0)) +
            (widget.hasMore || _loadingMore ? 1 : 0)
        : itemCount + (widget.hasMore || _loadingMore ? 1 : 0);

    return ListView.builder(
      controller: _scrollController,
      padding: widget.padding ?? spacing.paddingMd,
      itemCount: totalCount,
      itemBuilder: (context, index) {
        if (hasSeparator) {
          // Last item is loading indicator
          if (index == totalCount - 1 &&
              (widget.hasMore || _loadingMore) &&
              index >= itemCount * 2 - 1) {
            return _buildLoadingIndicator(context);
          }
          // Even indices are items, odd are separators
          if (index.isOdd) {
            return widget.separatorBuilder!(context, index ~/ 2);
          }
          final itemIndex = index ~/ 2;
          return widget.itemBuilder(context, widget.items[itemIndex], itemIndex);
        } else {
          if (index >= itemCount) {
            return _buildLoadingIndicator(context);
          }
          return widget.itemBuilder(context, widget.items[index], index);
        }
      },
    );
  }

  Widget _buildLoadingIndicator(BuildContext context) {
    if (widget.loadingBuilder != null) {
      return widget.loadingBuilder!(context);
    }

    final theme = UiTheme.of(context);
    final colors = theme.colorScheme;
    final spacing = theme.spacing;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: spacing.md),
      child: Center(
        child: AnimatedBuilder(
          animation: _spinnerController,
          builder: (context, _) {
            return CustomPaint(
              size: const Size.square(24),
              painter: _InfiniteListSpinnerPainter(
                progress: _spinnerController.value,
                color: colors.primary,
                glowColor: theme.useGlow ? colors.glow : null,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _InfiniteListSpinnerPainter extends CustomPainter {
  _InfiniteListSpinnerPainter({
    required this.progress,
    required this.color,
    this.glowColor,
  });

  final double progress;
  final Color color;
  final Color? glowColor;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final rect = Offset.zero & size;
    final deflated = rect.deflate(2);
    final startAngle = progress * 2 * math.pi;
    const sweepAngle = 4.0;

    if (glowColor != null) {
      final glowPaint = Paint()
        ..color = glowColor!.withValues(alpha: 0.4)
        ..strokeWidth = 5.0
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      canvas.drawArc(deflated, startAngle, sweepAngle, false, glowPaint);
    }

    canvas.drawArc(deflated, startAngle, sweepAngle, false, paint);
  }

  @override
  bool shouldRepaint(_InfiniteListSpinnerPainter oldDelegate) =>
      progress != oldDelegate.progress;
}
