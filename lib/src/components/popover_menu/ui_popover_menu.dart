import 'package:flutter/widgets.dart';

import '../../theme/ui_theme.dart';
import '../../theme/ui_theme_data.dart';

/// A single popover menu item.
class UiPopoverItem {
  const UiPopoverItem({
    required this.label,
    this.icon,
    this.destructive = false,
    this.enabled = true,
  });

  final String label;
  final IconData? icon;
  final bool destructive;
  final bool enabled;
}

/// A themed popover/context menu that appears relative to a trigger widget.
///
/// ```dart
/// UiPopoverMenu(
///   items: [
///     UiPopoverItem(label: 'Edit', icon: UiIcons.edit),
///     UiPopoverItem(label: 'Delete', icon: UiIcons.delete, destructive: true),
///   ],
///   onSelected: (index) => _handleAction(index),
///   child: UiIcon(UiIcons.moreVert),
/// )
/// ```
class UiPopoverMenu extends StatefulWidget {
  const UiPopoverMenu({
    super.key,
    required this.items,
    required this.onSelected,
    required this.child,
    this.dividerAfter = const {},
  });

  final List<UiPopoverItem> items;
  final ValueChanged<int> onSelected;
  final Widget child;

  /// Indices after which to show a divider.
  final Set<int> dividerAfter;

  @override
  State<UiPopoverMenu> createState() => _UiPopoverMenuState();
}

class _UiPopoverMenuState extends State<UiPopoverMenu> {
  final LayerLink _link = LayerLink();
  OverlayEntry? _entry;
  bool _open = false;

  void _toggle() {
    if (_open) {
      _close();
    } else {
      _openMenu();
    }
  }

  void _openMenu() {
    final theme = UiTheme.of(context);
    final box = context.findRenderObject()! as RenderBox;

    _entry = OverlayEntry(
      builder: (context) => _PopoverOverlay(
        link: _link,
        triggerWidth: box.size.width,
        items: widget.items,
        dividerAfter: widget.dividerAfter,
        theme: theme,
        onSelected: (i) {
          _close();
          widget.onSelected(i);
        },
        onDismiss: _close,
      ),
    );

    Overlay.of(context).insert(_entry!);
    setState(() => _open = true);
  }

  void _close() {
    _entry?.remove();
    _entry = null;
    if (mounted) setState(() => _open = false);
  }

  @override
  void dispose() {
    _entry?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _link,
      child: GestureDetector(
        onTap: _toggle,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: widget.child,
        ),
      ),
    );
  }
}

class _PopoverOverlay extends StatelessWidget {
  const _PopoverOverlay({
    required this.link,
    required this.triggerWidth,
    required this.items,
    required this.dividerAfter,
    required this.theme,
    required this.onSelected,
    required this.onDismiss,
  });

  final LayerLink link;
  final double triggerWidth;
  final List<UiPopoverItem> items;
  final Set<int> dividerAfter;
  final UiThemeData theme;
  final ValueChanged<int> onSelected;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final colors = theme.colorScheme;
    final spacing = theme.spacing;

    List<BoxShadow>? shadows;
    if (theme.useGlow && colors.glow != null) {
      shadows = [BoxShadow(color: colors.glow!.withValues(alpha: 0.15), blurRadius: 16)];
    } else if (theme.useShadows) {
      shadows = [BoxShadow(color: colors.shadow, blurRadius: 16, offset: const Offset(0, 4))];
    }

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onDismiss,
      child: SizedBox.expand(
        child: CompositedTransformFollower(
          link: link,
          offset: Offset(0, spacing.xs),
          targetAnchor: Alignment.bottomRight,
          followerAnchor: Alignment.topRight,
          child: Align(
            alignment: Alignment.topRight,
            child: Container(
              constraints: const BoxConstraints(minWidth: 160, maxWidth: 280),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: spacing.radiusMd,
                border: Border.all(color: colors.border, width: theme.borderWidth),
                boxShadow: shadows,
              ),
              child: ClipRRect(
                borderRadius: spacing.radiusMd,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (int i = 0; i < items.length; i++) ...[
                      _MenuItem(
                        item: items[i],
                        theme: theme,
                        onTap: items[i].enabled ? () => onSelected(i) : null,
                      ),
                      if (dividerAfter.contains(i))
                        Container(height: theme.borderWidth, color: colors.border),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuItem extends StatefulWidget {
  const _MenuItem({required this.item, required this.theme, this.onTap});
  final UiPopoverItem item;
  final UiThemeData theme;
  final VoidCallback? onTap;

  @override
  State<_MenuItem> createState() => _MenuItemState();
}

class _MenuItemState extends State<_MenuItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = widget.theme.colorScheme;
    final spacing = widget.theme.spacing;
    final typo = widget.theme.typography;
    final item = widget.item;

    final fgColor = item.destructive
        ? colors.error
        : (item.enabled ? colors.onSurface : colors.onSurface.withValues(alpha: 0.4));

    return GestureDetector(
      onTap: widget.onTap,
      child: MouseRegion(
        cursor: item.enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: spacing.md, vertical: spacing.sm),
          color: _hovered ? colors.onSurface.withValues(alpha: 0.06) : const Color(0x00000000),
          child: Row(
            children: [
              if (item.icon != null) ...[
                Icon(item.icon, size: 18, color: fgColor),
                SizedBox(width: spacing.sm),
              ],
              Expanded(child: Text(item.label, style: typo.bodyMedium.copyWith(color: fgColor))),
            ],
          ),
        ),
      ),
    );
  }
}
