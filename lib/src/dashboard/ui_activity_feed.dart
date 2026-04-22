import 'package:flutter/widgets.dart';

import '../theme/ui_theme.dart';

/// Activity type for visual differentiation.
enum UiActivityType {
  info,
  success,
  warning,
  error,
}

/// A single entry in a [UiActivityFeed].
class UiActivityItem {
  const UiActivityItem({
    required this.title,
    this.description,
    required this.timestamp,
    this.avatar,
    this.type = UiActivityType.info,
  });

  /// Optional avatar widget (e.g. [UiAvatar]).
  final Widget? avatar;

  final String title;
  final String? description;
  final DateTime timestamp;
  final UiActivityType type;
}

/// A themed activity/event feed for dashboards.
///
/// Displays a time-ordered list of events with type indicators.
///
/// ```dart
/// UiActivityFeed(
///   items: [
///     UiActivityItem(
///       title: 'New user signed up',
///       description: 'john@example.com',
///       timestamp: DateTime.now(),
///       type: UiActivityType.success,
///     ),
///   ],
/// )
/// ```
class UiActivityFeed extends StatelessWidget {
  const UiActivityFeed({
    super.key,
    required this.items,
    this.onItemTap,
    this.showTimestamps = true,
    this.compact = false,
  });

  final List<UiActivityItem> items;

  /// Called when an item is tapped with its index.
  final void Function(int index)? onItemTap;

  final bool showTimestamps;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final colors = theme.colorScheme;
    final spacing = theme.spacing;
    final typo = theme.typography;

    if (items.isEmpty) {
      return Padding(
        padding: spacing.paddingMd,
        child: Text(
          'No activity',
          style: typo.bodySmall.copyWith(
            color: colors.onSurface.withValues(alpha: 0.5),
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < items.length; i++) ...[
          _ActivityRow(
            item: items[i],
            compact: compact,
            showTimestamp: showTimestamps,
            onTap: onItemTap != null ? () => onItemTap!(i) : null,
            theme: theme,
          ),
          if (i < items.length - 1)
            Container(
              height: 1,
              color: colors.border.withValues(alpha: 0.3),
            ),
        ],
      ],
    );
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({
    required this.item,
    required this.compact,
    required this.showTimestamp,
    required this.theme,
    this.onTap,
  });

  final UiActivityItem item;
  final bool compact;
  final bool showTimestamp;
  final VoidCallback? onTap;
  final dynamic theme;

  Color _typeColor(dynamic colors) {
    switch (item.type) {
      case UiActivityType.success:
        return colors.success as Color;
      case UiActivityType.warning:
        return colors.warning as Color;
      case UiActivityType.error:
        return colors.error as Color;
      case UiActivityType.info:
        return colors.primary as Color;
    }
  }

  String _formatTimestamp(DateTime ts) {
    final now = DateTime.now();
    final diff = now.difference(ts);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${ts.day}/${ts.month}/${ts.year}';
  }

  @override
  Widget build(BuildContext context) {
    final t = UiTheme.of(context);
    final colors = t.colorScheme;
    final spacing = t.spacing;
    final typo = t.typography;

    final dotColor = _typeColor(colors);
    final verticalPad = compact ? spacing.xs : spacing.sm;

    Widget row = Padding(
      padding: EdgeInsets.symmetric(
        vertical: verticalPad,
        horizontal: spacing.sm,
      ),
      child: Row(
        children: [
          // Type dot or avatar
          if (item.avatar != null)
            SizedBox(width: compact ? 24 : 32, height: compact ? 24 : 32, child: item.avatar)
          else
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
          SizedBox(width: spacing.sm),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.title,
                  style: (compact ? typo.bodySmall : typo.bodyMedium).copyWith(
                    color: colors.onSurface,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (item.description != null && !compact)
                  Padding(
                    padding: EdgeInsets.only(top: spacing.xs / 2),
                    child: Text(
                      item.description!,
                      style: typo.bodySmall.copyWith(
                        color: colors.onSurface.withValues(alpha: 0.5),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ),
          if (showTimestamp) ...[
            SizedBox(width: spacing.sm),
            Text(
              _formatTimestamp(item.timestamp),
              style: typo.labelSmall.copyWith(
                color: colors.onSurface.withValues(alpha: 0.4),
              ),
            ),
          ],
        ],
      ),
    );

    if (onTap != null) {
      row = GestureDetector(onTap: onTap, child: row);
    }

    return row;
  }
}
