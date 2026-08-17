import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../theme/ui_theme.dart';

/// Data series for [UiLineChart].
class UiLineChartData {
  const UiLineChartData({required this.points, this.label, this.color});

  /// Y-values. Drawn left-to-right with even horizontal spacing.
  final List<double> points;

  /// Optional label for this series.
  final String? label;

  /// Override color for this series.
  final Color? color;
}

/// A themed line chart rendered via [CustomPaint].
///
/// Supports smooth bezier curves, gradient fill, animated drawing, and glow.
///
/// ```dart
/// UiLineChart(
///   data: [
///     UiLineChartData(points: [10, 25, 18, 30, 22, 35], label: 'Sales'),
///   ],
///   height: 200,
///   filled: true,
///   smooth: true,
/// )
/// ```
class UiLineChart extends StatefulWidget {
  const UiLineChart({
    super.key,
    required this.data,
    this.height = 200,
    this.showDots = false,
    this.showGrid = true,
    this.filled = false,
    this.animated = true,
    this.smooth = true,
  });

  final List<UiLineChartData> data;
  final double height;
  final bool showDots;
  final bool showGrid;

  /// Whether to fill the area under the line.
  final bool filled;

  final bool animated;

  /// Use bezier curves for smooth lines instead of straight segments.
  final bool smooth;

  @override
  State<UiLineChart> createState() => _UiLineChartState();
}

class _UiLineChartState extends State<UiLineChart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
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
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final colors = theme.colorScheme;

    final useGradient =
        theme.useGradients &&
        colors.gradient != null &&
        colors.gradient!.length >= 2;
    final useGlow = theme.useGlow && colors.glow != null;

    // Generate distinct colors for series
    final seriesColors = <Color>[];
    for (int i = 0; i < widget.data.length; i++) {
      seriesColors.add(
        widget.data[i].color ??
            (i == 0
                ? colors.primary
                : i == 1
                ? colors.secondary
                : colors.success),
      );
    }

    return SizedBox(
      height: widget.height,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, _) {
          return CustomPaint(
            size: Size(double.infinity, widget.height),
            painter: _LineChartPainter(
              data: widget.data,
              progress: _animation.value,
              showDots: widget.showDots,
              showGrid: widget.showGrid,
              filled: widget.filled,
              smooth: widget.smooth,
              seriesColors: seriesColors,
              gridColor: colors.resolvedBorderSubtle,
              gradientColors: useGradient ? colors.gradient! : null,
              glowColor: useGlow ? colors.glow : null,
            ),
          );
        },
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  _LineChartPainter({
    required this.data,
    required this.progress,
    required this.showDots,
    required this.showGrid,
    required this.filled,
    required this.smooth,
    required this.seriesColors,
    required this.gridColor,
    this.gradientColors,
    this.glowColor,
  });

  final List<UiLineChartData> data;
  final double progress;
  final bool showDots;
  final bool showGrid;
  final bool filled;
  final bool smooth;
  final List<Color> seriesColors;
  final Color gridColor;
  final List<Color>? gradientColors;
  final Color? glowColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final padding = 8.0;
    final chartWidth = size.width - padding * 2;
    final chartHeight = size.height - padding * 2;

    // Grid
    if (showGrid) {
      final gridPaint = Paint()
        ..color = gridColor
        ..strokeWidth = 0.5;

      for (int i = 0; i <= 4; i++) {
        final y = padding + chartHeight * i / 4;
        canvas.drawLine(
          Offset(padding, y),
          Offset(size.width - padding, y),
          gridPaint,
        );
      }
      for (int i = 0; i <= 6; i++) {
        final x = padding + chartWidth * i / 6;
        canvas.drawLine(
          Offset(x, padding),
          Offset(x, size.height - padding),
          gridPaint,
        );
      }
    }

    // Clip rect for animation
    canvas.save();
    canvas.clipRect(
      Rect.fromLTWH(0, 0, padding + chartWidth * progress, size.height),
    );

    for (int s = 0; s < data.length; s++) {
      final series = data[s];
      if (series.points.length < 2) continue;

      final points = series.points;
      final minVal = points.reduce(math.min);
      final maxVal = points.reduce(math.max);
      final range = maxVal - minVal;
      final effectiveRange = range == 0 ? 1.0 : range;

      final offsets = <Offset>[];
      for (int i = 0; i < points.length; i++) {
        final x = padding + (i / (points.length - 1)) * chartWidth;
        final y =
            padding + (1 - (points[i] - minVal) / effectiveRange) * chartHeight;
        offsets.add(Offset(x, y));
      }

      final color = seriesColors[s];

      // Build line path
      final linePath = Path();
      linePath.moveTo(offsets[0].dx, offsets[0].dy);

      if (smooth) {
        for (int i = 0; i < offsets.length - 1; i++) {
          final p0 = i > 0 ? offsets[i - 1] : offsets[i];
          final p1 = offsets[i];
          final p2 = offsets[i + 1];
          final p3 = i + 2 < offsets.length ? offsets[i + 2] : p2;

          final cp1x = p1.dx + (p2.dx - p0.dx) / 6;
          final cp1y = p1.dy + (p2.dy - p0.dy) / 6;
          final cp2x = p2.dx - (p3.dx - p1.dx) / 6;
          final cp2y = p2.dy - (p3.dy - p1.dy) / 6;

          linePath.cubicTo(cp1x, cp1y, cp2x, cp2y, p2.dx, p2.dy);
        }
      } else {
        for (int i = 1; i < offsets.length; i++) {
          linePath.lineTo(offsets[i].dx, offsets[i].dy);
        }
      }

      // Fill
      if (filled) {
        final fillPath = Path.from(linePath);
        fillPath.lineTo(offsets.last.dx, size.height - padding);
        fillPath.lineTo(offsets.first.dx, size.height - padding);
        fillPath.close();

        final fillPaint = Paint();
        if (gradientColors != null && s == 0) {
          fillPaint.shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              gradientColors!.first.withValues(alpha: 0.3),
              gradientColors!.last.withValues(alpha: 0.02),
            ],
          ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
        } else {
          fillPaint.color = color.withValues(alpha: 0.15);
        }

        canvas.drawPath(fillPath, fillPaint);
      }

      // Glow
      if (glowColor != null) {
        final glowPaint = Paint()
          ..color = color.withValues(alpha: 0.3)
          ..strokeWidth = 4
          ..style = PaintingStyle.stroke
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
        canvas.drawPath(linePath, glowPaint);
      }

      // Line stroke
      final linePaint = Paint()
        ..color = color
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round;

      if (gradientColors != null && s == 0) {
        linePaint.shader = LinearGradient(
          colors: gradientColors!,
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
      }

      canvas.drawPath(linePath, linePaint);

      // Dots
      if (showDots) {
        for (final offset in offsets) {
          canvas.drawCircle(offset, 4, Paint()..color = color);
          canvas.drawCircle(
            offset,
            2,
            Paint()..color = const Color(0xFFFFFFFF),
          );
        }
      }
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(_LineChartPainter oldDelegate) =>
      progress != oldDelegate.progress ||
      data != oldDelegate.data ||
      showDots != oldDelegate.showDots ||
      filled != oldDelegate.filled;
}
