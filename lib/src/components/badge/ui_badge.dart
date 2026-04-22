import 'package:flutter/widgets.dart';

import '../../theme/ui_theme.dart';

/// Badge type determines the semantic color.
enum UiBadgeType { primary, secondary, success, warning, error, neutral }

/// A small status indicator or label.
///
/// ```dart
/// UiBadge(label: 'NEW', type: UiBadgeType.success)
/// ```
class UiBadge extends StatelessWidget {
  const UiBadge({
    super.key,
    required this.label,
    this.type = UiBadgeType.primary,
    this.outlined = false,
  });

  final String label;
  final UiBadgeType type;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final colors = theme.colorScheme;
    final spacing = theme.spacing;
    final typo = theme.typography;

    final Color bg;
    final Color fg;

    switch (type) {
      case UiBadgeType.primary:
        bg = colors.primary;
        fg = colors.onPrimary;
      case UiBadgeType.secondary:
        bg = colors.secondary;
        fg = colors.onSecondary;
      case UiBadgeType.success:
        bg = colors.success;
        fg = colors.onSuccess;
      case UiBadgeType.warning:
        bg = colors.warning;
        fg = colors.onWarning;
      case UiBadgeType.error:
        bg = colors.error;
        fg = colors.onError;
      case UiBadgeType.neutral:
        bg = colors.surface;
        fg = colors.onSurface;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: spacing.sm,
        vertical: spacing.xs / 2,
      ),
      decoration: BoxDecoration(
        color: outlined ? const Color(0x00000000) : bg,
        borderRadius: spacing.radiusFull,
        border: outlined ? Border.all(color: bg, width: theme.borderWidth) : null,
      ),
      child: Text(
        label,
        style: typo.labelSmall.copyWith(
          color: outlined ? bg : fg,
        ),
      ),
    );
  }
}
