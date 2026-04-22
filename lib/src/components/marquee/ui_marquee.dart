import 'package:flutter/widgets.dart';

import '../../theme/ui_theme.dart';

/// Scroll direction for the marquee.
enum UiMarqueeDirection { left, right }

/// Continuously scrolling content in a horizontal marquee.
///
/// ```dart
/// UiMarquee(
///   velocity: 60,
///   child: Text('Breaking news: Flutter is awesome!'),
/// )
/// ```
class UiMarquee extends StatefulWidget {
  const UiMarquee({
    super.key,
    required this.child,
    this.velocity = 50.0,
    this.pauseAfterRound,
    this.direction = UiMarqueeDirection.left,
  });

  /// The content to scroll.
  final Widget child;

  /// Scroll speed in logical pixels per second.
  final double velocity;

  /// Optional pause between each loop.
  final Duration? pauseAfterRound;

  /// Scroll direction. Defaults to [UiMarqueeDirection.left].
  final UiMarqueeDirection direction;

  @override
  State<UiMarquee> createState() => _UiMarqueeState();
}

class _UiMarqueeState extends State<UiMarquee>
    with SingleTickerProviderStateMixin {
  late final ScrollController _scrollController;
  late final AnimationController _animController;
  final GlobalKey _childKey = GlobalKey();
  double _childWidth = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1), // Will be recalculated.
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _startScrolling());
  }

  void _startScrolling() {
    final renderBox =
        _childKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    _childWidth = renderBox.size.width;
    if (_childWidth <= 0) return;

    _runLoop();
  }

  Future<void> _runLoop() async {
    while (mounted) {
      final distance = _childWidth;
      final durationMs = (distance / widget.velocity * 1000).round();
      if (durationMs <= 0) break;

      _animController.duration = Duration(milliseconds: durationMs);

      // Reset scroll position.
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(
          widget.direction == UiMarqueeDirection.left ? 0 : distance,
        );
      }

      _animController.reset();

      void listener() {
        if (!_scrollController.hasClients) return;
        final target = widget.direction == UiMarqueeDirection.left
            ? distance * _animController.value
            : distance * (1 - _animController.value);
        _scrollController.jumpTo(target);
      }
      _animController.addListener(listener);

      await _animController.forward().orCancel.catchError((_) {});
      _animController.removeListener(listener);

      if (widget.pauseAfterRound != null && mounted) {
        await Future<void>.delayed(widget.pauseAfterRound!);
      }
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Access theme to stay consistent (allows future glow support).
    UiTheme.of(context);

    return ClipRect(
      child: SingleChildScrollView(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        child: Row(
          children: [
            KeyedSubtree(
              key: _childKey,
              child: widget.child,
            ),
            // Duplicate for seamless looping.
            widget.child,
          ],
        ),
      ),
    );
  }
}
