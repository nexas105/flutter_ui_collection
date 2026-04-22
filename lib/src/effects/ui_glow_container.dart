import 'package:flutter/widgets.dart';

import '../theme/ui_theme.dart';

/// A container with an animated glow border effect.
///
/// The glow color rotates through the theme's gradient or primary color,
/// creating a premium, eye-catching border animation.
///
/// ```dart
/// UiGlowContainer(
///   child: UiCard(child: Text('Premium Content')),
/// )
/// ```
class UiGlowContainer extends StatefulWidget {
  const UiGlowContainer({
    super.key,
    required this.child,
    this.glowColor,
    this.borderRadius,
    this.intensity = 0.6,
    this.blurRadius = 16.0,
    this.spreadRadius = 2.0,
    this.duration = const Duration(seconds: 3),
    this.animate = true,
    this.padding,
  });

  final Widget child;

  /// Override glow color. Defaults to theme's glow or primary.
  final Color? glowColor;

  final BorderRadius? borderRadius;

  /// Glow opacity (0.0 - 1.0).
  final double intensity;

  final double blurRadius;
  final double spreadRadius;
  final Duration duration;

  /// Whether to animate the glow. If false, shows static glow.
  final bool animate;

  final EdgeInsets? padding;

  @override
  State<UiGlowContainer> createState() => _UiGlowContainerState();
}

class _UiGlowContainerState extends State<UiGlowContainer>
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

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final spacing = theme.spacing;
    final colors = theme.colorScheme;
    final glowColor = widget.glowColor ?? colors.glow ?? colors.primary;
    final radius = widget.borderRadius ?? spacing.radiusMd;

    if (!widget.animate) {
      return Container(
        padding: widget.padding,
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: [
            BoxShadow(
              color: glowColor.withValues(alpha: widget.intensity),
              blurRadius: widget.blurRadius,
              spreadRadius: widget.spreadRadius,
            ),
          ],
        ),
        child: widget.child,
      );
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Pulsing intensity
        final pulse = (0.5 + 0.5 * _pulseValue(_controller.value))
            .clamp(0.0, 1.0);

        return Container(
          padding: widget.padding,
          decoration: BoxDecoration(
            borderRadius: radius,
            boxShadow: [
              BoxShadow(
                color: glowColor.withValues(alpha: widget.intensity * pulse),
                blurRadius: widget.blurRadius * (0.7 + 0.3 * pulse),
                spreadRadius: widget.spreadRadius * pulse,
              ),
            ],
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }

  /// Sine-based pulse between 0.0 and 1.0
  double _pulseValue(double t) {
    return (1.0 + _sin(t * 2 * 3.14159265)) / 2.0;
  }

  /// Simple sine approximation (avoids dart:math import)
  double _sin(double x) {
    // Normalize to [-pi, pi]
    x = x % (2 * 3.14159265);
    if (x > 3.14159265) x -= 2 * 3.14159265;
    // Taylor series approximation
    final x3 = x * x * x;
    final x5 = x3 * x * x;
    final x7 = x5 * x * x;
    return x - x3 / 6 + x5 / 120 - x7 / 5040;
  }
}
