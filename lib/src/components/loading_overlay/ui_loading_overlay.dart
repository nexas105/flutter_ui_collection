import 'package:flutter/widgets.dart';

import '../../theme/ui_theme.dart';

/// A full-screen loading overlay with themed spinner.
///
/// ```dart
/// // As a stack overlay:
/// Stack(children: [
///   MyContent(),
///   if (_loading) UiLoadingOverlay(message: 'Saving...'),
/// ])
///
/// // Or show as a dialog:
/// UiLoadingOverlay.show(context: context, message: 'Loading...');
/// // ... later:
/// Navigator.pop(context);
/// ```
class UiLoadingOverlay extends StatefulWidget {
  const UiLoadingOverlay({
    super.key,
    this.message,
    this.barrierColor,
    this.spinnerSize = 32.0,
  });

  final String? message;
  final Color? barrierColor;
  final double spinnerSize;

  /// Shows as a modal overlay (pop to dismiss).
  static Future<void> show({
    required BuildContext context,
    String? message,
  }) {
    final theme = UiTheme.of(context);
    return Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: false,
        barrierColor: const Color(0x00000000),
        transitionDuration: theme.animationDuration,
        pageBuilder: (ctx, anim, secAnim) => FadeTransition(
          opacity: anim,
          child: UiLoadingOverlay(message: message),
        ),
      ),
    );
  }

  @override
  State<UiLoadingOverlay> createState() => _UiLoadingOverlayState();
}

class _UiLoadingOverlayState extends State<UiLoadingOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
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
    final typo = theme.typography;
    final spacing = theme.spacing;

    return ColoredBox(
      color: widget.barrierColor ??
          colors.background.withValues(alpha: 0.8),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return CustomPaint(
                  size: Size(widget.spinnerSize, widget.spinnerSize),
                  painter: _SpinnerPainter(
                    progress: _controller.value,
                    color: colors.primary,
                    glowColor: theme.useGlow ? colors.glow : null,
                    strokeWidth: 3.0,
                  ),
                );
              },
            ),
            if (widget.message != null) ...[
              SizedBox(height: spacing.md),
              Text(
                widget.message!,
                style: typo.bodyMedium.copyWith(
                  color: colors.onBackground.withValues(alpha: 0.7),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SpinnerPainter extends CustomPainter {
  _SpinnerPainter({
    required this.progress,
    required this.color,
    this.glowColor,
    this.strokeWidth = 3.0,
  });

  final double progress;
  final Color color;
  final Color? glowColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final startAngle = progress * 6.2832; // 2 * pi
    const sweepAngle = 4.2;

    if (glowColor != null) {
      final glowPaint = Paint()
        ..color = glowColor!.withValues(alpha: 0.3)
        ..strokeWidth = strokeWidth + 2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawArc(rect.deflate(2), startAngle, sweepAngle, false, glowPaint);
    }

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect.deflate(2), startAngle, sweepAngle, false, paint);
  }

  @override
  bool shouldRepaint(_SpinnerPainter old) => progress != old.progress;
}
