import 'package:flutter/widgets.dart';

import '../../theme/ui_theme.dart';

/// Position of the scroll indicator bar.
enum UiScrollIndicatorPosition { top, bottom }

/// A thin progress bar that fills as the user scrolls.
///
/// ```dart
/// UiScrollIndicator(
///   controller: _scrollController,
///   position: UiScrollIndicatorPosition.top,
/// )
/// ```
class UiScrollIndicator extends StatefulWidget {
  const UiScrollIndicator({
    super.key,
    required this.controller,
    this.position = UiScrollIndicatorPosition.top,
    this.height = 3.0,
    this.color,
  });

  /// The scroll controller to observe.
  final ScrollController controller;

  /// Where to display the indicator. Defaults to `top`.
  final UiScrollIndicatorPosition position;

  /// Thickness of the bar. Defaults to `3.0`.
  final double height;

  /// Optional override color for the bar.
  final Color? color;

  @override
  State<UiScrollIndicator> createState() => _UiScrollIndicatorState();
}

class _UiScrollIndicatorState extends State<UiScrollIndicator> {
  double _progress = 0;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(UiScrollIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onScroll);
      widget.controller.addListener(_onScroll);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    if (!widget.controller.hasClients) return;
    final position = widget.controller.position;
    final max = position.maxScrollExtent;
    if (max <= 0) {
      setState(() => _progress = 0);
      return;
    }
    setState(() {
      _progress = (position.pixels / max).clamp(0.0, 1.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final colors = theme.colorScheme;

    final barColor = widget.color ?? colors.primary;

    List<BoxShadow>? glow;
    if (theme.useGlow && colors.glow != null) {
      glow = [
        BoxShadow(
          color: (colors.glow ?? barColor).withValues(alpha: 0.4),
          blurRadius: 6,
          spreadRadius: 1,
        ),
      ];
    }

    final useGradient = theme.useGradients && colors.gradient != null;

    return Align(
      alignment: widget.position == UiScrollIndicatorPosition.top
          ? Alignment.topLeft
          : Alignment.bottomLeft,
      child: AnimatedContainer(
        duration: theme.animationDuration,
        curve: theme.animationCurve,
        height: widget.height,
        width: double.infinity,
        child: FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: _progress,
          child: Container(
            decoration: BoxDecoration(
              color: useGradient ? null : barColor,
              gradient: useGradient
                  ? LinearGradient(colors: colors.gradient!)
                  : null,
              borderRadius: BorderRadius.circular(widget.height / 2),
              boxShadow: glow,
            ),
          ),
        ),
      ),
    );
  }
}
