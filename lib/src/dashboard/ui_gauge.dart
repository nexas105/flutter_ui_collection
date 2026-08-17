import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../theme/ui_theme.dart';

/// A semi-circular gauge rendered via [CustomPaint].
///
/// ```dart
/// UiGauge(
///   value: 0.72,
///   label: 'CPU',
///   valueLabel: '72%',
/// )
/// ```
class UiGauge extends StatefulWidget {
  const UiGauge({
    super.key,
    required this.value,
    this.size = 120,
    this.label,
    this.valueLabel,
    this.color,
    this.trackColor,
    this.strokeWidth = 8,
    this.animated = true,
  });

  /// Value from 0.0 to 1.0.
  final double value;

  /// Diameter of the gauge.
  final double size;

  /// Label displayed below the value.
  final String? label;

  /// Value label displayed in the center (e.g. "72%").
  final String? valueLabel;

  /// Override arc color. Falls back to [UiColorScheme.primary].
  final Color? color;

  /// Override track color. Falls back to [UiColorScheme.border].
  final Color? trackColor;

  /// Stroke width of the arc.
  final double strokeWidth;

  /// Whether to animate the arc drawing.
  final bool animated;

  @override
  State<UiGauge> createState() => _UiGaugeState();
}

class _UiGaugeState extends State<UiGauge> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    if (widget.animated) {
      _controller.forward();
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(UiGauge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value && widget.animated) {
      _controller.forward(from: 0.0);
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
    final colors = theme.colorScheme;
    final typo = theme.typography;
    final accent = widget.color ?? colors.primary;
    final track = widget.trackColor ?? colors.border;
    final useGlow = theme.useGlow && colors.glow != null;

    return SizedBox(
      width: widget.size,
      height: widget.size * 0.65,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, _) {
          return Stack(
            alignment: Alignment.bottomCenter,
            children: [
              CustomPaint(
                size: Size(widget.size, widget.size * 0.65),
                painter: _GaugePainter(
                  value: widget.value.clamp(0.0, 1.0) * _animation.value,
                  trackColor: track,
                  arcColor: accent,
                  strokeWidth: widget.strokeWidth,
                  useGlow: useGlow,
                  glowColor: colors.glow ?? accent,
                ),
              ),
              Positioned(
                bottom: 0,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.valueLabel != null)
                      Text(
                        widget.valueLabel!,
                        style: typo.headlineSmall.copyWith(
                          color: colors.onSurface,
                        ),
                      ),
                    if (widget.label != null)
                      Text(
                        widget.label!,
                        style: typo.labelSmall.copyWith(
                          color: colors.resolvedOnSurfaceMuted,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  _GaugePainter({
    required this.value,
    required this.trackColor,
    required this.arcColor,
    required this.strokeWidth,
    required this.useGlow,
    required this.glowColor,
  });

  final double value;
  final Color trackColor;
  final Color arcColor;
  final double strokeWidth;
  final bool useGlow;
  final Color glowColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2 - strokeWidth;

    // Track arc (half circle)
    final trackPaint = Paint()
      ..color = trackColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi,
      math.pi,
      false,
      trackPaint,
    );

    // Value arc
    final sweepAngle = math.pi * value;

    // Glow effect
    if (useGlow && value > 0) {
      final glowPaint = Paint()
        ..color = glowColor.withValues(alpha: 0.3)
        ..strokeWidth = strokeWidth + 4
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        math.pi,
        sweepAngle,
        false,
        glowPaint,
      );
    }

    // Value arc
    if (value > 0) {
      final arcPaint = Paint()
        ..color = arcColor
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        math.pi,
        sweepAngle,
        false,
        arcPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_GaugePainter oldDelegate) =>
      value != oldDelegate.value ||
      trackColor != oldDelegate.trackColor ||
      arcColor != oldDelegate.arcColor ||
      strokeWidth != oldDelegate.strokeWidth ||
      useGlow != oldDelegate.useGlow;
}
