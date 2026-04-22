import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../theme/ui_theme.dart';

/// Data point for [UiBarChart].
class UiBarChartData {
  const UiBarChartData({
    required this.label,
    required this.value,
    this.color,
  });

  final String label;
  final double value;

  /// Override color for this bar. Falls back to primary or gradient.
  final Color? color;
}

/// A themed vertical bar chart rendered entirely via [CustomPaint].
///
/// Supports animated bar growth, theme gradients, and glow effects.
///
/// ```dart
/// UiBarChart(
///   data: [
///     UiBarChartData(label: 'Mon', value: 120),
///     UiBarChartData(label: 'Tue', value: 180),
///     UiBarChartData(label: 'Wed', value: 90),
///   ],
///   height: 200,
/// )
/// ```
class UiBarChart extends StatefulWidget {
  const UiBarChart({
    super.key,
    required this.data,
    this.height = 200,
    this.showLabels = true,
    this.showValues = false,
    this.animated = true,
    this.barWidth,
    this.barRadius = 4.0,
  });

  final List<UiBarChartData> data;
  final double height;
  final bool showLabels;
  final bool showValues;
  final bool animated;

  /// Width of each bar. If null, bars fill available space evenly.
  final double? barWidth;

  /// Corner radius for bar tops.
  final double barRadius;

  @override
  State<UiBarChart> createState() => _UiBarChartState();
}

class _UiBarChartState extends State<UiBarChart>
    with SingleTickerProviderStateMixin {
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

    final useGradient =
        theme.useGradients && colors.gradient != null && colors.gradient!.length >= 2;
    final useGlow = theme.useGlow && colors.glow != null;

    final labelHeight = widget.showLabels ? 24.0 : 0.0;
    final valueHeight = widget.showValues ? 20.0 : 0.0;
    final chartHeight = widget.height - labelHeight - valueHeight;

    return SizedBox(
      height: widget.height,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, _) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: chartHeight + valueHeight,
                child: CustomPaint(
                  size: Size(double.infinity, chartHeight + valueHeight),
                  painter: _BarChartPainter(
                    data: widget.data,
                    progress: _animation.value,
                    barWidth: widget.barWidth,
                    barRadius: widget.barRadius,
                    showValues: widget.showValues,
                    defaultColor: colors.primary,
                    gradientColors: useGradient ? colors.gradient! : null,
                    glowColor: useGlow ? colors.glow! : null,
                    valueStyle: typo.labelSmall.copyWith(
                      color: colors.onBackground,
                    ),
                    gridColor: colors.border.withValues(alpha: 0.3),
                    valueHeight: valueHeight,
                  ),
                ),
              ),
              if (widget.showLabels)
                SizedBox(
                  height: labelHeight,
                  child: Row(
                    children: [
                      for (int i = 0; i < widget.data.length; i++)
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: spacing.xs / 2,
                            ),
                            child: Text(
                              widget.data[i].label,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: typo.labelSmall.copyWith(
                                color: colors.onBackground.withValues(alpha: 0.6),
                              ),
                            ),
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

class _BarChartPainter extends CustomPainter {
  _BarChartPainter({
    required this.data,
    required this.progress,
    required this.defaultColor,
    required this.gridColor,
    required this.valueStyle,
    required this.valueHeight,
    this.barWidth,
    this.barRadius = 4.0,
    this.showValues = false,
    this.gradientColors,
    this.glowColor,
  });

  final List<UiBarChartData> data;
  final double progress;
  final double? barWidth;
  final double barRadius;
  final bool showValues;
  final Color defaultColor;
  final List<Color>? gradientColors;
  final Color? glowColor;
  final TextStyle valueStyle;
  final Color gridColor;
  final double valueHeight;

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final chartHeight = size.height - valueHeight;
    final maxVal = data.map((d) => d.value).reduce(math.max);
    if (maxVal <= 0) return;

    final count = data.length;
    final slotWidth = size.width / count;
    final resolvedBarWidth = barWidth ?? (slotWidth * 0.6).clamp(4.0, 60.0);
    final barGap = (slotWidth - resolvedBarWidth) / 2;

    // Draw horizontal grid lines
    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 0.5;

    for (int i = 1; i <= 4; i++) {
      final y = chartHeight - (chartHeight * i / 4);
      canvas.drawLine(Offset(0, y + valueHeight), Offset(size.width, y + valueHeight), gridPaint);
    }

    for (int i = 0; i < count; i++) {
      final item = data[i];
      final barHeight = (item.value / maxVal) * chartHeight * progress;
      final x = i * slotWidth + barGap;
      final y = chartHeight - barHeight + valueHeight;

      final barRect = RRect.fromRectAndCorners(
        Rect.fromLTWH(x, y, resolvedBarWidth, barHeight),
        topLeft: Radius.circular(barRadius),
        topRight: Radius.circular(barRadius),
      );

      // Glow
      if (glowColor != null) {
        final glowPaint = Paint()
          ..color = (item.color ?? glowColor!).withValues(alpha: 0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
        canvas.drawRRect(barRect, glowPaint);
      }

      // Bar fill
      final barPaint = Paint();
      if (gradientColors != null && item.color == null) {
        barPaint.shader = LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: gradientColors!,
        ).createShader(Rect.fromLTWH(x, y, resolvedBarWidth, barHeight));
      } else {
        barPaint.color = item.color ?? defaultColor;
      }

      canvas.drawRRect(barRect, barPaint);

      // Value text
      if (showValues && progress > 0.5) {
        final tp = TextPainter(
          text: TextSpan(text: item.value.toStringAsFixed(0), style: valueStyle),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(
          canvas,
          Offset(x + (resolvedBarWidth - tp.width) / 2, y - tp.height - 4),
        );
      }
    }
  }

  @override
  bool shouldRepaint(_BarChartPainter oldDelegate) =>
      progress != oldDelegate.progress ||
      data != oldDelegate.data ||
      defaultColor != oldDelegate.defaultColor;
}
