import 'package:flutter/widgets.dart';

import '../theme/ui_theme.dart';
import 'ui_stat_card.dart';

/// KPI definition for [UiKpiRow].
class UiKpiData {
  const UiKpiData({
    required this.label,
    required this.value,
    this.trend,
    this.trendValue,
    this.icon,
    this.sparklineData,
    this.color,
  });

  final String label;
  final String value;
  final UiStatCardTrend? trend;
  final String? trendValue;
  final IconData? icon;
  final List<double>? sparklineData;
  final Color? color;
}

/// A responsive row of KPI stat cards for dashboard headers.
///
/// Uses [Wrap] to flow cards to the next line on narrow screens.
///
/// ```dart
/// UiKpiRow(
///   kpis: [
///     UiKpiData(label: 'Revenue', value: '\$12,345', trend: UiStatCardTrend.up, trendValue: '+12%'),
///     UiKpiData(label: 'Users', value: '1,234', trend: UiStatCardTrend.up, trendValue: '+5%'),
///     UiKpiData(label: 'Orders', value: '567', trend: UiStatCardTrend.down, trendValue: '-3%'),
///   ],
/// )
/// ```
class UiKpiRow extends StatelessWidget {
  const UiKpiRow({
    super.key,
    required this.kpis,
    this.compact = false,
  });

  final List<UiKpiData> kpis;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final spacing = theme.spacing;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Determine card width based on available space
        final maxWidth = constraints.maxWidth;
        final gap = spacing.sm;

        int columns;
        if (maxWidth > 900) {
          columns = kpis.length.clamp(1, 4);
        } else if (maxWidth > 600) {
          columns = kpis.length.clamp(1, 3).clamp(1, 3);
        } else if (maxWidth > 400) {
          columns = 2;
        } else {
          columns = 1;
        }

        final cardWidth = (maxWidth - gap * (columns - 1)) / columns;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final kpi in kpis)
              SizedBox(
                width: cardWidth,
                child: UiStatCard(
                  label: kpi.label,
                  value: kpi.value,
                  trend: kpi.trend,
                  trendValue: kpi.trendValue,
                  icon: kpi.icon,
                  sparklineData: kpi.sparklineData,
                  color: kpi.color,
                  glowBorder: theme.useGlow,
                ),
              ),
          ],
        );
      },
    );
  }
}
