import 'package:flutter/widgets.dart';

import '../../interaction/ui_interactive_region.dart';
import '../../theme/ui_color_scheme.dart';
import '../../theme/ui_spacing.dart';
import '../../theme/ui_theme.dart';
import '../../theme/ui_theme_data.dart';
import '../../theme/ui_typography.dart';

/// A single sidebar navigation item.
class UiSidebarItem {
  const UiSidebarItem({required this.label, this.icon, this.badge});

  final String label;
  final IconData? icon;

  /// Optional badge text (e.g. notification count).
  final String? badge;
}

/// A themed vertical sidebar navigation.
///
/// ```dart
/// UiSidebar(
///   header: Text('My App'),
///   items: [
///     UiSidebarItem(label: 'Dashboard', icon: Icons.home),
///     UiSidebarItem(label: 'Settings', icon: Icons.settings),
///   ],
///   selectedIndex: 0,
///   onChanged: (i) => setState(() => _index = i),
/// )
/// ```
class UiSidebar extends StatelessWidget {
  const UiSidebar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onChanged,
    this.header,
    this.footer,
    this.width = 240,
    this.collapsed = false,
  });

  final List<UiSidebarItem> items;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final Widget? header;
  final Widget? footer;
  final double width;

  /// If true, shows only icons (compact mode).
  final bool collapsed;

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final colors = theme.colorScheme;
    final spacing = theme.spacing;
    final typo = theme.typography;

    return AnimatedContainer(
      duration: theme.animationDuration,
      curve: theme.animationCurve,
      width: collapsed ? 64 : width,
      decoration: BoxDecoration(
        color: colors.resolvedSurfaceRaised,
        border: Border(
          right: BorderSide(color: colors.border, width: theme.borderWidth),
        ),
      ),
      child: Column(
        children: [
          if (header != null)
            Padding(padding: EdgeInsets.all(spacing.md), child: header!),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(
                horizontal: spacing.sm,
                vertical: spacing.xs,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) =>
                  _buildItem(index, theme, colors, spacing, typo),
            ),
          ),
          if (footer != null)
            Padding(padding: EdgeInsets.all(spacing.md), child: footer!),
        ],
      ),
    );
  }

  Widget _buildItem(
    int index,
    UiThemeData theme,
    UiColorScheme colors,
    UiSpacing spacing,
    UiTypography typo,
  ) {
    final selected = index == selectedIndex;
    final item = items[index];

    List<BoxShadow>? glow;
    if (selected && theme.useGlow && colors.glow != null) {
      glow = [
        BoxShadow(color: colors.glow!.withValues(alpha: 0.2), blurRadius: 8),
      ];
    }

    return Padding(
      padding: EdgeInsets.only(bottom: spacing.xs),
      child: UiInteractiveRegion(
        enabled: true,
        onActivate: () => onChanged(index),
        semanticLabel: item.label,
        button: true,
        selected: selected,
        borderRadius: theme.components.controlBorderRadius,
        child: GestureDetector(
          onTap: () => onChanged(index),
          child: AnimatedContainer(
            duration: theme.animationDuration,
            curve: theme.animationCurve,
            padding: EdgeInsets.symmetric(
              horizontal: spacing.sm,
              vertical: spacing.sm,
            ),
            decoration: BoxDecoration(
              color: selected
                  ? colors.primary.withValues(alpha: 0.15)
                  : const Color(0x00000000),
              borderRadius: theme.components.controlBorderRadius,
              boxShadow: glow,
            ),
            constraints: BoxConstraints(
              minHeight: theme.components.controlHeightMedium,
            ),
            child: Row(
              children: [
                if (item.icon != null)
                  Icon(
                    theme.icons.resolve(item.icon!),
                    size: theme.components.iconSizeMedium,
                    color: selected ? colors.primary : colors.onSurface,
                  ),
                if (!collapsed) ...[
                  if (item.icon != null) SizedBox(width: spacing.sm),
                  Expanded(
                    child: Text(
                      item.label,
                      style: typo.bodyMedium.copyWith(
                        color: selected ? colors.primary : colors.onSurface,
                        fontWeight: selected ? FontWeight.w600 : null,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (item.badge != null)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: spacing.xs + 2,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: colors.primary,
                        borderRadius: spacing.radiusFull,
                      ),
                      child: Text(
                        item.badge!,
                        style: typo.labelSmall.copyWith(
                          color: colors.onPrimary,
                          fontSize: 10,
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
