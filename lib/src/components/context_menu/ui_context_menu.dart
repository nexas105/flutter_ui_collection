import 'package:flutter/widgets.dart';

import '../../theme/ui_theme.dart';

/// A single item in [UiContextMenu].
class UiContextMenuItem {
  const UiContextMenuItem({
    required this.label,
    this.icon,
    this.onTap,
    this.destructive = false,
  });

  final String label;
  final Widget? icon;
  final VoidCallback? onTap;
  final bool destructive;
}

/// A themed right-click / long-press context menu.
///
/// ```dart
/// UiContextMenu(
///   items: [
///     UiContextMenuItem(label: 'Copy', onTap: () {}),
///     UiContextMenuItem(label: 'Delete', destructive: true, onTap: () {}),
///   ],
///   child: Text('Right-click me'),
/// )
/// ```
class UiContextMenu extends StatefulWidget {
  const UiContextMenu({super.key, required this.items, required this.child});

  final List<UiContextMenuItem> items;
  final Widget child;

  @override
  State<UiContextMenu> createState() => _UiContextMenuState();
}

class _UiContextMenuState extends State<UiContextMenu> {
  OverlayEntry? _overlayEntry;

  void _show(Offset position) {
    _dismiss();
    final overlay = Overlay.of(context);
    _overlayEntry = OverlayEntry(
      builder: (_) => _ContextMenuOverlay(
        position: position,
        items: widget.items,
        onDismiss: _dismiss,
      ),
    );
    overlay.insert(_overlayEntry!);
  }

  void _dismiss() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  void dispose() {
    _dismiss();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onSecondaryTapDown: (details) => _show(details.globalPosition),
      onLongPressStart: (details) => _show(details.globalPosition),
      child: widget.child,
    );
  }
}

class _ContextMenuOverlay extends StatelessWidget {
  const _ContextMenuOverlay({
    required this.position,
    required this.items,
    required this.onDismiss,
  });

  final Offset position;
  final List<UiContextMenuItem> items;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final colors = theme.colorScheme;
    final spacing = theme.spacing;
    final typo = theme.typography;

    final List<BoxShadow> shadows = [];
    if (theme.useGlow && colors.glow != null) {
      shadows.add(
        BoxShadow(
          color: colors.glow!.withValues(alpha: 0.2),
          blurRadius: 16,
          spreadRadius: 1,
        ),
      );
    } else if (theme.useShadows) {
      shadows.add(
        BoxShadow(
          color: colors.shadow,
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onDismiss,
      child: Stack(
        children: [
          Positioned(
            left: position.dx,
            top: position.dy,
            child: Container(
              constraints: const BoxConstraints(minWidth: 160, maxWidth: 280),
              decoration: BoxDecoration(
                color: colors.resolvedSurfaceOverlay,
                borderRadius: theme.components.cardBorderRadius,
                border: Border.all(
                  color: colors.border,
                  width: theme.borderWidth,
                ),
                boxShadow: shadows,
              ),
              padding: EdgeInsets.symmetric(vertical: spacing.xs),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final item in items)
                    GestureDetector(
                      onTap: () {
                        onDismiss();
                        item.onTap?.call();
                      },
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: spacing.md,
                            vertical: spacing.sm,
                          ),
                          color: const Color(0x00000000),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (item.icon != null) ...[
                                item.icon!,
                                SizedBox(width: spacing.sm),
                              ],
                              Flexible(
                                child: Text(
                                  item.label,
                                  style: typo.bodyMedium.copyWith(
                                    color: item.destructive
                                        ? colors.error
                                        : colors.onSurface,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
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
