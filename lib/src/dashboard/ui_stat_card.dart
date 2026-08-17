import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../theme/ui_theme.dart';

/// Trend direction for [UiStatCard].
enum UiStatCardTrend { up, down, neutral }

/// An enhanced stat card for dashboards with optional sparkline background.
///
/// ```dart
/// UiStatCard(
///   label: 'Revenue',
///   value: '\$12,345',
///   icon: UiIcons.chart,
///   trend: UiStatCardTrend.up,
///   trendValue: '+12.5%',
///   sparklineData: [10, 15, 12, 18, 22, 20, 25],
/// )
/// ```
class UiStatCard extends StatelessWidget {
  const UiStatCard({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.trend,
    this.trendValue,
    this.sparklineData,
    this.color,
    this.glowBorder = false,
    this.onTap,
  });

  /// The metric label (e.g. "Revenue").
  final String label;

  /// The metric value (e.g. "\$12,345").
  final String value;

  /// Optional icon displayed next to the label.
  final IconData? icon;

  /// Trend direction indicator.
  final UiStatCardTrend? trend;

  /// Trend percentage text (e.g. "+12.5%").
  final String? trendValue;

  /// Optional sparkline data points drawn in the card background.
  final List<double>? sparklineData;

  /// Override accent color for the card.
  final Color? color;

  /// Whether to render a glow border effect.
  final bool glowBorder;

  /// Tap callback.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final colors = theme.colorScheme;
    final spacing = theme.spacing;
    final typo = theme.typography;

    final accent = color ?? colors.primary;

    final Color? trendColor;
    final String? trendArrow;
    switch (trend) {
      case UiStatCardTrend.up:
        trendColor = colors.success;
        trendArrow = '\u2191';
      case UiStatCardTrend.down:
        trendColor = colors.error;
        trendArrow = '\u2193';
      case UiStatCardTrend.neutral:
        trendColor = colors.resolvedOnSurfaceSubtle;
        trendArrow = '\u2192';
      case null:
        trendColor = null;
        trendArrow = null;
    }

    final shadows = theme.surfaceShadows(
      emphasized: glowBorder,
      accent: glowBorder ? accent : null,
    );

    Widget card = Container(
      padding: spacing.paddingMd,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: spacing.radiusMd,
        border: Border.all(
          color: glowBorder ? accent.withValues(alpha: 0.5) : colors.border,
          width: theme.borderWidth,
        ),
        boxShadow: shadows,
      ),
      child: Stack(
        children: [
          // Sparkline background
          if (sparklineData != null && sparklineData!.length >= 2)
            Positioned.fill(
              child: ClipRRect(
                borderRadius: spacing.radiusMd,
                child: CustomPaint(
                  painter: _SparklinePainter(
                    data: sparklineData!,
                    color: accent.withValues(alpha: 0.15),
                    strokeColor: accent.withValues(alpha: 0.3),
                  ),
                ),
              ),
            ),
          // Content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 16, color: accent),
                    SizedBox(width: spacing.xs),
                  ],
                  Flexible(
                    child: Text(
                      label,
                      style: typo.labelMedium.copyWith(
                        color: colors.resolvedOnSurfaceMuted,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: spacing.sm),
              Text(
                value,
                style: typo.headlineMedium.copyWith(color: colors.onSurface),
              ),
              if (trendValue != null && trendColor != null) ...[
                SizedBox(height: spacing.xs),
                Text(
                  '${trendArrow ?? ''} $trendValue',
                  style: typo.labelSmall.copyWith(color: trendColor),
                ),
              ],
            ],
          ),
        ],
      ),
    );

    if (onTap != null) {
      card = GestureDetector(onTap: onTap, child: card);
    }

    return card;
  }
}

class _SparklinePainter extends CustomPainter {
  _SparklinePainter({
    required this.data,
    required this.color,
    required this.strokeColor,
  });

  final List<double> data;
  final Color color;
  final Color strokeColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) return;

    final minVal = data.reduce(math.min);
    final maxVal = data.reduce(math.max);
    final range = maxVal - minVal;
    if (range == 0) return;

    final stepX = size.width / (data.length - 1);
    final points = <Offset>[];

    for (int i = 0; i < data.length; i++) {
      final x = i * stepX;
      final y =
          size.height -
          ((data[i] - minVal) / range) * size.height * 0.6 -
          size.height * 0.1;
      points.add(Offset(x, y));
    }

    // Fill area
    final fillPath = Path()..moveTo(0, size.height);
    for (final p in points) {
      fillPath.lineTo(p.dx, p.dy);
    }
    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, Paint()..color = color);

    // Stroke line
    final strokePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      strokePath.lineTo(points[i].dx, points[i].dy);
    }

    canvas.drawPath(
      strokePath,
      Paint()
        ..color = strokeColor
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_SparklinePainter oldDelegate) =>
      data != oldDelegate.data ||
      color != oldDelegate.color ||
      strokeColor != oldDelegate.strokeColor;
}
