import 'package:flutter/widgets.dart';

import '../../theme/ui_theme.dart';

/// Trend direction for [UiStat].
enum UiStatTrend { up, down, neutral }

/// A themed statistic display widget.
///
/// Great for dashboards, showing KPIs with optional trend indicators.
///
/// ```dart
/// UiStat(
///   label: 'Revenue',
///   value: '\$12,345',
///   trend: UiStatTrend.up,
///   trendText: '+12.5%',
/// )
/// ```
class UiStat extends StatelessWidget {
  const UiStat({
    super.key,
    required this.label,
    required this.value,
    this.trend,
    this.trendText,
    this.icon,
    this.compact = false,
  });

  final String label;
  final String value;
  final UiStatTrend? trend;
  final String? trendText;
  final IconData? icon;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final colors = theme.colorScheme;
    final spacing = theme.spacing;
    final typo = theme.typography;

    final Color? trendColor;
    final String? trendArrow;
    switch (trend) {
      case UiStatTrend.up:
        trendColor = colors.success;
        trendArrow = '\u2191';
      case UiStatTrend.down:
        trendColor = colors.error;
        trendArrow = '\u2193';
      case UiStatTrend.neutral:
        trendColor = colors.onSurface.withValues(alpha: 0.5);
        trendArrow = '\u2192';
      case null:
        trendColor = null;
        trendArrow = null;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: colors.onSurface.withValues(alpha: 0.5)),
              SizedBox(width: spacing.xs),
            ],
            Text(
              label,
              style: typo.labelMedium.copyWith(
                color: colors.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
        SizedBox(height: compact ? 2 : spacing.xs),
        Text(
          value,
          style: (compact ? typo.titleLarge : typo.headlineMedium).copyWith(
            color: colors.onSurface,
          ),
        ),
        if (trendText != null && trendColor != null) ...[
          SizedBox(height: spacing.xs / 2),
          Text(
            '${trendArrow ?? ''} $trendText',
            style: typo.labelSmall.copyWith(color: trendColor),
          ),
        ],
      ],
    );
  }
}
