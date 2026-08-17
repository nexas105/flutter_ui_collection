import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../theme/ui_theme.dart';

/// Data segment for [UiPieChart].
class UiPieChartData {
  const UiPieChartData({required this.value, required this.label, this.color});

  final double value;
  final String label;

  /// Override color for this segment.
  final Color? color;
}

/// A themed pie/donut chart rendered via [CustomPaint].
///
/// ```dart
/// UiPieChart(
///   data: [
///     UiPieChartData(value: 40, label: 'Desktop'),
///     UiPieChartData(value: 35, label: 'Mobile'),
///     UiPieChartData(value: 25, label: 'Tablet'),
///   ],
///   size: 200,
///   donut: true,
/// )
/// ```
class UiPieChart extends StatefulWidget {
  const UiPieChart({
    super.key,
    required this.data,
    this.size = 200,
    this.donut = false,
    this.donutWidth = 30,
    this.showLabels = true,
    this.showPercentages = false,
    this.animated = true,
  });

  final List<UiPieChartData> data;
  final double size;

  /// Render as a donut (hollow center) instead of a full pie.
  final bool donut;

  /// Width of the donut ring when [donut] is true.
  final double donutWidth;

  final bool showLabels;
  final bool showPercentages;
  final bool animated;

  @override
  State<UiPieChart> createState() => _UiPieChartState();
}

class _UiPieChartState extends State<UiPieChart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
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

  /// Default palette for segments when no color is provided.
  static const _defaultPalette = [
    Color(0xFF6366F1), // indigo
    Color(0xFF22D3EE), // cyan
    Color(0xFFF59E0B), // amber
    Color(0xFFEF4444), // red
    Color(0xFF10B981), // emerald
    Color(0xFFA855F7), // purple
    Color(0xFFF97316), // orange
    Color(0xFF3B82F6), // blue
  ];

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final colors = theme.colorScheme;
    final typo = theme.typography;
    final spacing = theme.spacing;
    final useGlow = theme.useGlow && colors.glow != null;

    // Assign colors
    final segmentColors = <Color>[];
    for (int i = 0; i < widget.data.length; i++) {
      segmentColors.add(
        widget.data[i].color ?? _defaultPalette[i % _defaultPalette.length],
      );
    }

    final total = widget.data.fold<double>(0, (sum, d) => sum + d.value);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: widget.size,
          height: widget.size,
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, _) {
              return CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _PieChartPainter(
                  data: widget.data,
                  segmentColors: segmentColors,
                  progress: _animation.value,
                  donut: widget.donut,
                  donutWidth: widget.donutWidth,
                  showPercentages: widget.showPercentages,
                  total: total,
                  percentageStyle: typo.labelSmall.copyWith(
                    color: colors.onPrimary,
                  ),
                  glowColor: useGlow ? colors.glow : null,
                  centerColor: widget.donut ? colors.surface : null,
                ),
              );
            },
          ),
        ),
        if (widget.showLabels && widget.data.isNotEmpty) ...[
          SizedBox(height: spacing.sm),
          Wrap(
            spacing: spacing.md,
            runSpacing: spacing.xs,
            alignment: WrapAlignment.center,
            children: [
              for (int i = 0; i < widget.data.length; i++)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: segmentColors[i],
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: spacing.xs),
                    Text(
                      widget.showPercentages && total > 0
                          ? '${widget.data[i].label} (${(widget.data[i].value / total * 100).round()}%)'
                          : widget.data[i].label,
                      style: typo.labelSmall.copyWith(
                        color: colors.resolvedOnSurfaceMuted,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _PieChartPainter extends CustomPainter {
  _PieChartPainter({
    required this.data,
    required this.segmentColors,
    required this.progress,
    required this.donut,
    required this.donutWidth,
    required this.showPercentages,
    required this.total,
    required this.percentageStyle,
    this.glowColor,
    this.centerColor,
  });

  final List<UiPieChartData> data;
  final List<Color> segmentColors;
  final double progress;
  final bool donut;
  final double donutWidth;
  final bool showPercentages;
  final double total;
  final TextStyle percentageStyle;
  final Color? glowColor;
  final Color? centerColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty || total <= 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 4;
    final rect = Rect.fromCircle(center: center, radius: radius);

    const startOffset = -math.pi / 2;
    final totalSweep = 2 * math.pi * progress;
    var currentAngle = startOffset;

    for (int i = 0; i < data.length; i++) {
      final fraction = data[i].value / total;
      final sweepAngle = totalSweep * fraction;
      final segColor = segmentColors[i];

      // Glow
      if (glowColor != null) {
        final glowPaint = Paint()
          ..color = segColor.withValues(alpha: 0.3)
          ..style = PaintingStyle.fill
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
        canvas.drawArc(rect, currentAngle, sweepAngle, true, glowPaint);
      }

      // Segment
      final segPaint = Paint()
        ..color = segColor
        ..style = PaintingStyle.fill;
      canvas.drawArc(rect, currentAngle, sweepAngle, true, segPaint);

      // Percentage text inside segment
      if (showPercentages && fraction > 0.06 && progress > 0.8) {
        final midAngle = currentAngle + sweepAngle / 2;
        final labelRadius = donut ? radius - donutWidth / 2 : radius * 0.65;
        final labelX = center.dx + labelRadius * math.cos(midAngle);
        final labelY = center.dy + labelRadius * math.sin(midAngle);

        final tp = TextPainter(
          text: TextSpan(
            text: '${(fraction * 100).round()}%',
            style: percentageStyle,
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(labelX - tp.width / 2, labelY - tp.height / 2));
      }

      currentAngle += sweepAngle;
    }

    // Donut hole
    if (donut) {
      final innerRadius = radius - donutWidth;
      if (innerRadius > 0) {
        canvas.drawCircle(
          center,
          innerRadius,
          Paint()..color = centerColor ?? const Color(0xFF1A1A2E),
        );
      }
    }

    // Thin separator lines
    currentAngle = startOffset;
    for (int i = 0; i < data.length; i++) {
      final fraction = data[i].value / total;
      final sweepAngle = totalSweep * fraction;

      if (data.length > 1) {
        final sepPaint = Paint()
          ..color =
              centerColor?.withValues(alpha: 0.5) ?? const Color(0x40000000)
          ..strokeWidth = 1.5
          ..style = PaintingStyle.stroke;

        final innerR = donut ? radius - donutWidth : 0.0;
        final x1 = center.dx + innerR * math.cos(currentAngle);
        final y1 = center.dy + innerR * math.sin(currentAngle);
        final x2 = center.dx + radius * math.cos(currentAngle);
        final y2 = center.dy + radius * math.sin(currentAngle);
        canvas.drawLine(Offset(x1, y1), Offset(x2, y2), sepPaint);
      }

      currentAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(_PieChartPainter oldDelegate) =>
      progress != oldDelegate.progress ||
      data != oldDelegate.data ||
      donut != oldDelegate.donut;
}
