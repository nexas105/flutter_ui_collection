import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../../theme/ui_theme.dart';

/// A themed circular progress indicator with optional label.
///
/// ```dart
/// UiProgressCircle(
///   value: 0.75,
///   size: 80,
///   showLabel: true,
/// )
/// ```
class UiProgressCircle extends StatelessWidget {
  const UiProgressCircle({
    super.key,
    required this.value,
    this.size = 64,
    this.strokeWidth = 4,
    this.showLabel = false,
    this.color,
    this.trackColor,
  });

  /// Progress value between 0.0 and 1.0.
  final double value;

  /// Diameter of the circle.
  final double size;

  /// Width of the progress arc stroke.
  final double strokeWidth;

  /// Whether to show the percentage label in the center.
  final bool showLabel;

  /// Override color for the progress arc. Falls back to primary.
  final Color? color;

  /// Override color for the background track. Falls back to border.
  final Color? trackColor;

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final colors = theme.colorScheme;
    final typo = theme.typography;

    final progressColor = color ?? colors.primary;
    final bgTrackColor = trackColor ?? colors.border.withValues(alpha: 0.3);

    final useGradient =
        theme.useGradients && colors.gradient != null && colors.gradient!.length >= 2;
    final useGlow = theme.useGlow && colors.glow != null;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _ProgressCirclePainter(
              value: value.clamp(0.0, 1.0),
              strokeWidth: strokeWidth,
              progressColor: progressColor,
              trackColor: bgTrackColor,
              gradientColors: useGradient ? colors.gradient! : null,
              glowColor: useGlow ? colors.glow! : null,
            ),
          ),
          if (showLabel)
            Text(
              '${(value.clamp(0.0, 1.0) * 100).round()}%',
              style: typo.labelSmall.copyWith(
                color: colors.onSurface,
                fontSize: size * 0.2,
              ),
            ),
        ],
      ),
    );
  }
}

class _ProgressCirclePainter extends CustomPainter {
  _ProgressCirclePainter({
    required this.value,
    required this.strokeWidth,
    required this.progressColor,
    required this.trackColor,
    this.gradientColors,
    this.glowColor,
  });

  final double value;
  final double strokeWidth;
  final Color progressColor;
  final Color trackColor;
  final List<Color>? gradientColors;
  final Color? glowColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Draw track
    final trackPaint = Paint()
      ..color = trackColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    if (value <= 0) return;

    // Draw progress arc
    final sweepAngle = 2 * math.pi * value;
    const startAngle = -math.pi / 2;

    // Glow layer
    if (glowColor != null) {
      final glowPaint = Paint()
        ..color = glowColor!.withValues(alpha: 0.4)
        ..strokeWidth = strokeWidth + 4
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

      canvas.drawArc(rect, startAngle, sweepAngle, false, glowPaint);
    }

    // Progress arc
    final progressPaint = Paint()
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    if (gradientColors != null) {
      progressPaint.shader = SweepGradient(
        startAngle: startAngle,
        endAngle: startAngle + sweepAngle,
        colors: gradientColors!,
      ).createShader(rect);
    } else {
      progressPaint.color = progressColor;
    }

    canvas.drawArc(rect, startAngle, sweepAngle, false, progressPaint);
  }

  @override
  bool shouldRepaint(_ProgressCirclePainter oldDelegate) =>
      value != oldDelegate.value ||
      strokeWidth != oldDelegate.strokeWidth ||
      progressColor != oldDelegate.progressColor ||
      trackColor != oldDelegate.trackColor ||
      glowColor != oldDelegate.glowColor;
}
