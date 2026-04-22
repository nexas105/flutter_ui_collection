import 'package:flutter/widgets.dart';

import '../theme/ui_theme.dart';

/// Wraps a child with a pulsing glow/scale animation.
///
/// Great for drawing attention to a button, badge, or indicator.
///
/// ```dart
/// UiPulse(
///   child: UiBadge(label: 'LIVE', type: UiBadgeType.error),
/// )
/// ```
class UiPulse extends StatefulWidget {
  const UiPulse({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1500),
    this.minScale = 0.95,
    this.maxScale = 1.05,
    this.glowColor,
    this.glowRadius = 12.0,
    this.enabled = true,
  });

  final Widget child;
  final Duration duration;
  final double minScale;
  final double maxScale;

  /// Glow color. Defaults to theme's glow or primary.
  final Color? glowColor;

  final double glowRadius;

  /// Set to false to pause the animation.
  final bool enabled;

  @override
  State<UiPulse> createState() => _UiPulseState();
}

class _UiPulseState extends State<UiPulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _scaleAnimation = Tween<double>(
      begin: widget.minScale,
      end: widget.maxScale,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    if (widget.enabled) _controller.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(UiPulse oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enabled && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.enabled && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final glow = widget.glowColor ??
        theme.colorScheme.glow ??
        theme.colorScheme.primary;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final glowOpacity = (_scaleAnimation.value - widget.minScale) /
            (widget.maxScale - widget.minScale);

        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            decoration: theme.useGlow
                ? BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: glow.withValues(alpha: glowOpacity * 0.5),
                        blurRadius: widget.glowRadius * glowOpacity,
                        spreadRadius: widget.glowRadius * 0.2 * glowOpacity,
                      ),
                    ],
                  )
                : null,
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}
