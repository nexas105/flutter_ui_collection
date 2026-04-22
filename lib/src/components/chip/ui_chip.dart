import 'package:flutter/widgets.dart';

import '../../theme/ui_theme.dart';

/// A compact element for tags, filters, or selections.
///
/// ```dart
/// UiChip(label: 'Flutter', selected: true, onTap: () {})
/// ```
class UiChip extends StatelessWidget {
  const UiChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
    this.onDelete,
    this.icon,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final colors = theme.colorScheme;
    final spacing = theme.spacing;
    final typo = theme.typography;

    final bgColor = selected
        ? colors.primary.withValues(alpha: 0.15)
        : colors.surface;
    final fgColor = selected ? colors.primary : colors.onSurface;
    final borderColor = selected ? colors.primary : colors.border;

    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: onTap != null
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: spacing.sm,
            vertical: spacing.xs,
          ),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: spacing.radiusFull,
            border: Border.all(color: borderColor, width: theme.borderWidth),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 14, color: fgColor),
                SizedBox(width: spacing.xs),
              ],
              Text(label, style: typo.labelSmall.copyWith(color: fgColor)),
              if (onDelete != null) ...[
                SizedBox(width: spacing.xs),
                GestureDetector(
                  onTap: onDelete,
                  child: Icon(
                    IconData(0x2715, fontFamily: 'MaterialIcons'),
                    size: 12,
                    color: fgColor.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
