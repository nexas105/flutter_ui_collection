import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../theme/ui_theme.dart';

/// Animated "typing..." indicator with three bouncing dots.
///
/// Optionally displays a user name before the dots, e.g.
/// "Alice is typing...".
///
/// ```dart
/// UiTypingIndicator(userName: 'Alice')
/// ```
class UiTypingIndicator extends StatefulWidget {
  const UiTypingIndicator({
    super.key,
    this.userName,
  });

  /// The name of the user who is typing. When null, only dots are shown.
  final String? userName;

  @override
  State<UiTypingIndicator> createState() => _UiTypingIndicatorState();
}

class _UiTypingIndicatorState extends State<UiTypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final colors = theme.colorScheme;
    final spacing = theme.spacing;
    final typo = theme.typography;

    final textColor = colors.onSurface.withValues(alpha: 0.6);
    final dotColor = colors.primary;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: spacing.md,
        vertical: spacing.xs,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.userName != null) ...[
            Text(
              '${widget.userName} is typing',
              style: typo.bodySmall.copyWith(
                color: textColor,
                fontStyle: FontStyle.italic,
              ),
            ),
            SizedBox(width: spacing.xs),
          ],
          _BouncingDot(controller: _controller, delay: 0.0, color: dotColor),
          SizedBox(width: spacing.xs / 2),
          _BouncingDot(controller: _controller, delay: 0.15, color: dotColor),
          SizedBox(width: spacing.xs / 2),
          _BouncingDot(controller: _controller, delay: 0.3, color: dotColor),
        ],
      ),
    );
  }
}

class _BouncingDot extends StatelessWidget {
  const _BouncingDot({
    required this.controller,
    required this.delay,
    required this.color,
  });

  final AnimationController controller;
  final double delay;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        // Map the animation value with stagger delay to a bounce offset.
        final t = (controller.value - delay) % 1.0;
        // Only bounce in the first half of the cycle for this dot.
        final bounce = t < 0.5 ? math.sin(t * 2 * math.pi) * 4.0 : 0.0;

        return Transform.translate(
          offset: Offset(0, -bounce.abs()),
          child: child,
        );
      },
      child: Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
