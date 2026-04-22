import 'package:flutter/widgets.dart';

import '../../theme/ui_theme.dart';

/// Badge type determines the semantic color.
enum UiBadgeType { primary, secondary, success, warning, error, neutral }

/// Badge size presets.
enum UiBadgeSize { small, medium, large }

/// A small status indicator or label.
///
/// ```dart
/// UiBadge(label: 'NEW', type: UiBadgeType.success)
/// UiBadge(label: '3', size: UiBadgeSize.small)
/// ```
class UiBadge extends StatelessWidget {
  const UiBadge({
    super.key,
    required this.label,
    this.type = UiBadgeType.primary,
    this.size = UiBadgeSize.medium,
    this.outlined = false,
    this.icon,
  });

  final String label;
  final UiBadgeType type;
  final UiBadgeSize size;
  final bool outlined;

  /// Optional leading icon.
  final IconData? icon;

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

    final double hPad;
    final double vPad;
    final TextStyle textStyle;
    final double iconSize;

    switch (size) {
      case UiBadgeSize.small:
        hPad = spacing.xs + 2;
        vPad = 1;
        textStyle = typo.labelSmall.copyWith(fontSize: 10);
        iconSize = 10;
      case UiBadgeSize.medium:
        hPad = spacing.sm;
        vPad = spacing.xs / 2;
        textStyle = typo.labelSmall;
        iconSize = 12;
      case UiBadgeSize.large:
        hPad = spacing.sm + 2;
        vPad = spacing.xs;
        textStyle = typo.labelMedium;
        iconSize = 14;
    }

    List<BoxShadow>? glow;
    if (theme.useGlow && colors.glow != null && !outlined) {
      glow = [
        BoxShadow(
          color: bg.withValues(alpha: 0.3),
          blurRadius: 6,
        ),
      ];
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
      decoration: BoxDecoration(
        color: outlined ? const Color(0x00000000) : bg,
        borderRadius: spacing.radiusFull,
        border: outlined ? Border.all(color: bg, width: theme.borderWidth) : null,
        boxShadow: glow,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: iconSize, color: outlined ? bg : fg),
            SizedBox(width: spacing.xs / 2),
          ],
          Text(label, style: textStyle.copyWith(color: outlined ? bg : fg)),
        ],
      ),
    );
  }
}
