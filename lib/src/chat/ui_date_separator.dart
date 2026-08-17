import 'package:flutter/widgets.dart';

import '../theme/ui_theme.dart';

/// A date divider shown between messages from different days.
///
/// Displays "Today", "Yesterday", or a formatted date centered between
/// two horizontal lines, similar to a labeled divider.
///
/// ```dart
/// UiChatDateSeparator(date: DateTime(2025, 3, 15))
/// ```
class UiChatDateSeparator extends StatelessWidget {
  const UiChatDateSeparator({super.key, required this.date});

  /// The date to display.
  final DateTime date;

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diff = today.difference(target).inDays;

    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';

    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    final month = months[date.month - 1];

    if (date.year == now.year) {
      return '$month ${date.day}';
    }
    return '$month ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final colors = theme.colorScheme;
    final spacing = theme.spacing;
    final typo = theme.typography;

    final label = _formatDate(date);
    final lineColor = colors.border.withValues(alpha: 0.4);

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: spacing.md,
        horizontal: spacing.lg,
      ),
      child: Row(
        children: [
          Expanded(child: Container(height: 1, color: lineColor)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: spacing.sm),
            child: Text(
              label,
              style: typo.labelSmall.copyWith(
                color: colors.resolvedOnSurfaceSubtle,
              ),
            ),
          ),
          Expanded(child: Container(height: 1, color: lineColor)),
        ],
      ),
    );
  }
}
