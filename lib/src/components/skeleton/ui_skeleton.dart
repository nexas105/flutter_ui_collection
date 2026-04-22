import 'package:flutter/widgets.dart';

import '../../theme/ui_theme.dart';

/// Shape variants for skeleton placeholders.
enum UiSkeletonShape { rectangle, circle, rounded }

/// A themed loading placeholder with shimmer animation.
///
/// ```dart
/// // Text placeholder
/// UiSkeleton(width: 200, height: 16)
///
/// // Avatar placeholder
/// UiSkeleton.circle(size: 44)
///
/// // Card placeholder
/// UiSkeleton(width: double.infinity, height: 120, shape: UiSkeletonShape.rounded)
///
/// // Static (no animation)
/// UiSkeleton(width: 200, height: 16, animate: false)
/// ```
class UiSkeleton extends StatefulWidget {
  const UiSkeleton({
    super.key,
    this.width,
    this.height,
    this.shape = UiSkeletonShape.rounded,
    this.borderRadius,
    this.animate = true,
    this.duration = const Duration(milliseconds: 1500),
    this.baseColor,
    this.highlightColor,
  });

  /// Creates a circular skeleton (e.g. for avatars).
  const UiSkeleton.circle({
    super.key,
    required double size,
    this.animate = true,
    this.duration = const Duration(milliseconds: 1500),
    this.baseColor,
    this.highlightColor,
  })  : width = size,
        height = size,
        shape = UiSkeletonShape.circle,
        borderRadius = null;

  final double? width;
  final double? height;
  final UiSkeletonShape shape;
  final BorderRadius? borderRadius;

  /// Whether to animate the shimmer. Defaults to true.
  final bool animate;

  /// Shimmer animation duration. Defaults to 1500ms.
  final Duration duration;

  /// Override the base (background) color.
  final Color? baseColor;

  /// Override the highlight (shimmer) color.
  final Color? highlightColor;

  @override
  State<UiSkeleton> createState() => _UiSkeletonState();
}

class _UiSkeletonState extends State<UiSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    if (widget.animate) _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  BorderRadius _resolveBorderRadius(double borderRadiusMd) {
    if (widget.borderRadius != null) return widget.borderRadius!;
    switch (widget.shape) {
      case UiSkeletonShape.rectangle:
        return BorderRadius.zero;
      case UiSkeletonShape.circle:
        return BorderRadius.circular(999);
      case UiSkeletonShape.rounded:
        return BorderRadius.circular(borderRadiusMd);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final colors = theme.colorScheme;
    final spacing = theme.spacing;

    final base = widget.baseColor ?? colors.surface;
    final highlight = widget.highlightColor ?? colors.border;
    final radius = _resolveBorderRadius(spacing.borderRadiusMd);

    if (!widget.animate) {
      return Container(
        width: widget.width,
        height: widget.height ?? 16,
        decoration: BoxDecoration(
          color: base,
          borderRadius: radius,
        ),
      );
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height ?? 16,
          decoration: BoxDecoration(
            borderRadius: radius,
            gradient: LinearGradient(
              begin: Alignment(-1.0 + 2.0 * _controller.value, 0),
              end: Alignment(1.0 + 2.0 * _controller.value, 0),
              colors: [base, highlight, base],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }
}
