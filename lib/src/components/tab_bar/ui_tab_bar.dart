import 'package:flutter/widgets.dart';

import '../../interaction/ui_interactive_region.dart';
import '../../theme/ui_color_scheme.dart';
import '../../theme/ui_spacing.dart';
import '../../theme/ui_theme.dart';
import '../../theme/ui_theme_data.dart';
import '../../theme/ui_typography.dart';

/// A single tab definition.
class UiTab {
  const UiTab({required this.label, this.icon});

  final String label;
  final IconData? icon;
}

/// A themed tab bar with animated indicator.
///
/// ```dart
/// UiTabBar(
///   tabs: [UiTab(label: 'Home'), UiTab(label: 'Settings')],
///   selectedIndex: 0,
///   onChanged: (i) => setState(() => _index = i),
/// )
/// ```
class UiTabBar extends StatelessWidget {
  const UiTabBar({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onChanged,
    this.expand = true,
  });

  final List<UiTab> tabs;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  /// If true, tabs expand to fill available width.
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final colors = theme.colorScheme;
    final spacing = theme.spacing;
    final typo = theme.typography;

    return Container(
      decoration: BoxDecoration(
        color: colors.resolvedSurfaceRaised,
        borderRadius: theme.components.controlBorderRadius,
        border: Border.all(color: colors.border, width: theme.borderWidth),
      ),
      padding: EdgeInsets.all(spacing.xs),
      child: Row(
        children: [
          for (int i = 0; i < tabs.length; i++)
            expand
                ? Expanded(child: _buildTab(i, theme, colors, spacing, typo))
                : _buildTab(i, theme, colors, spacing, typo),
        ],
      ),
    );
  }

  Widget _buildTab(
    int index,
    UiThemeData theme,
    UiColorScheme colors,
    UiSpacing spacing,
    UiTypography typo,
  ) {
    final selected = index == selectedIndex;
    final tab = tabs[index];

    List<BoxShadow>? glow;
    if (selected && theme.useGlow && colors.glow != null) {
      glow = [
        BoxShadow(color: colors.glow!.withValues(alpha: 0.3), blurRadius: 8),
      ];
    }

    return UiInteractiveRegion(
      enabled: true,
      onActivate: () => onChanged(index),
      semanticLabel: tab.label,
      button: true,
      selected: selected,
      borderRadius: theme.components.controlBorderRadius,
      child: GestureDetector(
        onTap: () => onChanged(index),
        child: AnimatedContainer(
          duration: theme.animationDuration,
          curve: theme.animationCurve,
          padding: EdgeInsets.symmetric(
            horizontal: spacing.md,
            vertical: spacing.sm,
          ),
          decoration: BoxDecoration(
            color: selected ? colors.primary : const Color(0x00000000),
            borderRadius: theme.components.controlBorderRadius,
            boxShadow: glow,
          ),
          constraints: BoxConstraints(
            minHeight: theme.components.controlHeightMedium,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (tab.icon != null) ...[
                Icon(
                  theme.icons.resolve(tab.icon!),
                  size: theme.components.iconSizeSmall,
                  color: selected ? colors.onPrimary : colors.onSurface,
                ),
                SizedBox(width: spacing.xs),
              ],
              Text(
                tab.label,
                style: typo.labelMedium.copyWith(
                  color: selected ? colors.onPrimary : colors.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
