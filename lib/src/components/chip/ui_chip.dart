import 'package:flutter/widgets.dart';

import '../../icons/ui_icons.dart';
import '../../theme/ui_theme.dart';

/// A compact element for tags, filters, or selections.
///
/// ```dart
/// UiChip(label: 'Flutter', selected: true, onTap: () {})
/// ```
class UiChip extends StatefulWidget {
  const UiChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
    this.onDelete,
    this.icon,
    this.enabled = true,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final IconData? icon;
  final bool enabled;

  @override
  State<UiChip> createState() => _UiChipState();
}

class _UiChipState extends State<UiChip> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final colors = theme.colorScheme;
    final spacing = theme.spacing;
    final typo = theme.typography;

    final Color bgColor;
    if (widget.selected) {
      bgColor = _hovered
          ? colors.primary.withValues(alpha: 0.25)
          : colors.primary.withValues(alpha: 0.15);
    } else {
      bgColor = _hovered
          ? colors.onSurface.withValues(alpha: 0.08)
          : colors.surface;
    }
    final fgColor = widget.selected ? colors.primary : colors.onSurface;
    final borderColor = widget.selected ? colors.primary : colors.border;

    List<BoxShadow>? glow;
    if (widget.selected && theme.useGlow && colors.glow != null) {
      glow = [
        BoxShadow(color: colors.glow!.withValues(alpha: 0.15), blurRadius: 6),
      ];
    }

    return Opacity(
      opacity: widget.enabled ? 1.0 : 0.5,
      child: GestureDetector(
        onTap: widget.enabled ? widget.onTap : null,
        child: MouseRegion(
          cursor: widget.enabled && widget.onTap != null
              ? SystemMouseCursors.click
              : SystemMouseCursors.basic,
          onEnter: (_) => setState(() => _hovered = true),
          onExit: (_) => setState(() => _hovered = false),
          child: AnimatedContainer(
            duration: theme.animationDuration,
            curve: theme.animationCurve,
            padding: EdgeInsets.symmetric(
              horizontal: spacing.sm,
              vertical: spacing.xs,
            ),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: spacing.radiusFull,
              border: Border.all(color: borderColor, width: theme.borderWidth),
              boxShadow: glow,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.icon != null) ...[
                  Icon(widget.icon, size: 14, color: fgColor),
                  SizedBox(width: spacing.xs),
                ],
                Text(
                  widget.label,
                  style: typo.labelSmall.copyWith(color: fgColor),
                ),
                if (widget.onDelete != null && widget.enabled) ...[
                  SizedBox(width: spacing.xs),
                  GestureDetector(
                    onTap: widget.onDelete,
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Icon(
                        UiIcons.close,
                        size: 12,
                        color: fgColor.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
