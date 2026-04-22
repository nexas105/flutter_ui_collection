import 'package:flutter/widgets.dart';

import '../../theme/ui_theme.dart';

/// A themed list tile for lists and menus.
///
/// ```dart
/// UiListTile(
///   leading: UiAvatar(initials: 'TL'),
///   title: Text('Tobias Ludwig'),
///   subtitle: Text('Online'),
///   trailing: UiBadge(label: '3'),
///   onTap: () {},
/// )
/// ```
class UiListTile extends StatefulWidget {
  const UiListTile({
    super.key,
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.padding,
    this.dense = false,
    this.selected = false,
    this.enabled = true,
  });

  final Widget? leading;
  final Widget? title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final EdgeInsets? padding;

  /// Reduces vertical padding.
  final bool dense;

  /// Highlights the tile as selected.
  final bool selected;

  final bool enabled;

  @override
  State<UiListTile> createState() => _UiListTileState();
}

class _UiListTileState extends State<UiListTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final colors = theme.colorScheme;
    final spacing = theme.spacing;
    final typo = theme.typography;

    final vPad = widget.dense ? spacing.xs : spacing.sm;

    final Color bgColor;
    if (widget.selected) {
      bgColor = colors.primary.withValues(alpha: 0.1);
    } else if (_hovered) {
      bgColor = colors.onSurface.withValues(alpha: 0.04);
    } else {
      bgColor = const Color(0x00000000);
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
            padding: widget.padding ??
                EdgeInsets.symmetric(horizontal: spacing.md, vertical: vPad),
            decoration: BoxDecoration(
              color: bgColor,
              border: Border(
                left: widget.selected
                    ? BorderSide(color: colors.primary, width: 3)
                    : BorderSide.none,
              ),
            ),
            child: Row(
              children: [
                if (widget.leading != null) ...[
                  widget.leading!,
                  SizedBox(width: spacing.md),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.title != null)
                        DefaultTextStyle(
                          style: typo.bodyMedium.copyWith(
                            color: widget.selected
                                ? colors.primary
                                : colors.onSurface,
                            fontWeight:
                                widget.selected ? FontWeight.w600 : null,
                          ),
                          child: widget.title!,
                        ),
                      if (widget.subtitle != null) ...[
                        SizedBox(height: 2),
                        DefaultTextStyle(
                          style: typo.bodySmall.copyWith(
                            color: colors.onSurface.withValues(alpha: 0.6),
                          ),
                          child: widget.subtitle!,
                        ),
                      ],
                    ],
                  ),
                ),
                if (widget.trailing != null) ...[
                  SizedBox(width: spacing.sm),
                  widget.trailing!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
