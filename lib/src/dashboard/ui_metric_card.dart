import 'package:flutter/widgets.dart';

import '../theme/ui_theme.dart';

/// A rich metric card for dashboards with value, change indicator, and
/// optional chart area.
///
/// ```dart
/// UiMetricCard(
///   title: 'Monthly Revenue',
///   value: '\$48,250',
///   change: '+12.5%',
///   changePositive: true,
///   chart: UiSparkline(data: [10, 15, 12, 18, 22, 20, 25]),
/// )
/// ```
class UiMetricCard extends StatefulWidget {
  const UiMetricCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    this.change,
    this.changePositive = true,
    this.chart,
    this.icon,
    this.onTap,
  });

  /// The metric title (e.g. "Monthly Revenue").
  final String title;

  /// The primary metric value (e.g. "\$48,250").
  final String value;

  /// Optional subtitle text below the value.
  final String? subtitle;

  /// Change text (e.g. "+12.5%").
  final String? change;

  /// Whether the change is positive (green/up) or negative (red/down).
  final bool changePositive;

  /// Optional chart widget displayed at the bottom of the card.
  final Widget? chart;

  /// Optional icon displayed next to the title.
  final IconData? icon;

  /// Tap callback.
  final VoidCallback? onTap;

  @override
  State<UiMetricCard> createState() => _UiMetricCardState();
}

class _UiMetricCardState extends State<UiMetricCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final colors = theme.colorScheme;
    final spacing = theme.spacing;
    final typo = theme.typography;

    final useGlow = theme.useGlow && colors.glow != null;

    List<BoxShadow>? shadows;
    if (useGlow && _hovered) {
      shadows = [
        BoxShadow(
          color: (colors.glow ?? colors.primary).withValues(alpha: 0.3),
          blurRadius: 20,
          spreadRadius: 2,
        ),
      ];
    } else if (theme.useShadows) {
      shadows = [
        BoxShadow(
          color: colors.shadow,
          blurRadius: _hovered ? 16 : 12,
          offset: const Offset(0, 4),
        ),
      ];
    }

    // Change badge
    Widget? changeBadge;
    if (widget.change != null) {
      final badgeColor =
          widget.changePositive ? colors.success : colors.error;
      final arrow = widget.changePositive ? '\u2191' : '\u2193';

      changeBadge = Container(
        padding: EdgeInsets.symmetric(
          horizontal: spacing.sm,
          vertical: spacing.xs * 0.5,
        ),
        decoration: BoxDecoration(
          color: badgeColor.withValues(alpha: 0.12),
          borderRadius: spacing.radiusSm,
        ),
        child: Text(
          '$arrow ${widget.change}',
          style: typo.labelSmall.copyWith(color: badgeColor),
        ),
      );
    }

    Widget card = AnimatedContainer(
      duration: theme.animationDuration,
      curve: theme.animationCurve,
      padding: spacing.paddingMd,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: spacing.radiusMd,
        border: Border.all(
          color: _hovered
              ? colors.primary.withValues(alpha: 0.4)
              : colors.border,
          width: theme.borderWidth,
        ),
        boxShadow: shadows,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title row
          Row(
            children: [
              if (widget.icon != null) ...[
                Icon(
                  widget.icon,
                  size: 16,
                  color: colors.onSurface.withValues(alpha: 0.5),
                ),
                SizedBox(width: spacing.xs),
              ],
              Expanded(
                child: Text(
                  widget.title,
                  style: typo.labelMedium.copyWith(
                    color: colors.onSurface.withValues(alpha: 0.6),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: spacing.sm),

          // Value
          Text(
            widget.value,
            style: typo.headlineMedium.copyWith(color: colors.onSurface),
          ),

          // Subtitle
          if (widget.subtitle != null) ...[
            SizedBox(height: spacing.xs),
            Text(
              widget.subtitle!,
              style: typo.bodySmall.copyWith(
                color: colors.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],

          // Change badge
          if (changeBadge != null) ...[
            SizedBox(height: spacing.sm),
            changeBadge,
          ],

          // Chart area
          if (widget.chart != null) ...[
            SizedBox(height: spacing.md),
            widget.chart!,
          ],
        ],
      ),
    );

    card = MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: card,
    );

    if (widget.onTap != null) {
      card = GestureDetector(onTap: widget.onTap, child: card);
    }

    return card;
  }
}
