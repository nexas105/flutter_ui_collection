import 'package:flutter/widgets.dart';

import '../../theme/ui_theme.dart';
import '../../theme/ui_theme_data.dart';

/// A single timeline entry.
class UiTimelineItem {
  const UiTimelineItem({
    required this.title,
    this.subtitle,
    this.content,
    this.icon,
    this.color,
  });

  final String title;
  final String? subtitle;
  final Widget? content;
  final IconData? icon;

  /// Override dot color for this item.
  final Color? color;
}

/// A themed vertical timeline.
///
/// ```dart
/// UiTimeline(
///   items: [
///     UiTimelineItem(title: 'Order placed', subtitle: '2 hours ago'),
///     UiTimelineItem(title: 'Shipped', subtitle: '1 hour ago', icon: UiIcons.check),
///     UiTimelineItem(title: 'Delivered', subtitle: 'Just now', color: Colors.green),
///   ],
/// )
/// ```
class UiTimeline extends StatelessWidget {
  const UiTimeline({
    super.key,
    required this.items,
    this.lineWidth = 2.0,
    this.dotSize = 12.0,
  });

  final List<UiTimelineItem> items;
  final double lineWidth;
  final double dotSize;

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < items.length; i++)
          _TimelineEntry(
            item: items[i],
            isFirst: i == 0,
            isLast: i == items.length - 1,
            lineWidth: lineWidth,
            dotSize: dotSize,
            theme: theme,
          ),
      ],
    );
  }
}

class _TimelineEntry extends StatelessWidget {
  const _TimelineEntry({
    required this.item,
    required this.isFirst,
    required this.isLast,
    required this.lineWidth,
    required this.dotSize,
    required this.theme,
  });

  final UiTimelineItem item;
  final bool isFirst;
  final bool isLast;
  final double lineWidth;
  final double dotSize;
  final UiThemeData theme;

  @override
  Widget build(BuildContext context) {
    final colors = theme.colorScheme;
    final spacing = theme.spacing;
    final typo = theme.typography;

    final dotColor = item.color ?? colors.primary;

    List<BoxShadow>? glow;
    if (theme.useGlow && colors.glow != null) {
      glow = [BoxShadow(color: dotColor.withValues(alpha: 0.3), blurRadius: 6)];
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline rail
          SizedBox(
            width: dotSize + spacing.md,
            child: Column(
              children: [
                // Top line
                if (!isFirst)
                  Container(width: lineWidth, height: spacing.xs, color: colors.border)
                else
                  SizedBox(height: spacing.xs),
                // Dot
                Container(
                  width: dotSize,
                  height: dotSize,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                    boxShadow: glow,
                  ),
                  child: item.icon != null
                      ? Center(child: Icon(item.icon, size: dotSize * 0.6, color: colors.onPrimary))
                      : null,
                ),
                // Bottom line
                if (!isLast)
                  Expanded(child: Center(child: Container(width: lineWidth, color: colors.border)))
                else
                  const Expanded(child: SizedBox()),
              ],
            ),
          ),
          // Content
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: spacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(item.title, style: typo.titleSmall.copyWith(color: colors.onSurface)),
                  if (item.subtitle != null)
                    Text(
                      item.subtitle!,
                      style: typo.bodySmall.copyWith(color: colors.onSurface.withValues(alpha: 0.5)),
                    ),
                  if (item.content != null)
                    Padding(
                      padding: EdgeInsets.only(top: spacing.xs),
                      child: item.content!,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
