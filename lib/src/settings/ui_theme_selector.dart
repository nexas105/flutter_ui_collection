import 'package:flutter/widgets.dart';

import '../icons/ui_icons.dart';
import '../interaction/ui_interactive_region.dart';
import '../theme/ui_theme.dart';
import '../theme/ui_theme_data.dart';

/// Represents a theme option for [UiThemeSelector].
class UiThemePreview {
  const UiThemePreview({required this.name, required this.data});

  /// Display name of the theme.
  final String name;

  /// The theme data used to render the preview and apply the theme.
  final UiThemeData data;
}

/// A grid of theme previews allowing users to pick a UI theme.
///
/// Each card shows the theme's name and three color swatches
/// (primary, secondary, surface) rendered in the theme's own colors.
///
/// ```dart
/// UiThemeSelector(
///   themes: [
///     UiThemePreview(name: 'Neon', data: NeonTheme.dark),
///     UiThemePreview(name: 'Glass', data: GlassTheme.dark),
///   ],
///   selectedTheme: 'Neon',
///   onChanged: (name) => setState(() => _theme = name),
/// )
/// ```
class UiThemeSelector extends StatelessWidget {
  const UiThemeSelector({
    super.key,
    required this.themes,
    required this.selectedTheme,
    required this.onChanged,
    this.crossAxisCount = 2,
  });

  /// Available theme options.
  final List<UiThemePreview> themes;

  /// Name of the currently selected theme.
  final String selectedTheme;

  /// Called with the theme name when a new theme is selected.
  final ValueChanged<String> onChanged;

  /// Number of columns in the grid.
  final int crossAxisCount;

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final spacing = theme.spacing;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: spacing.md,
        vertical: spacing.sm,
      ),
      child: Wrap(
        spacing: spacing.sm,
        runSpacing: spacing.sm,
        children: [
          for (final preview in themes)
            _UiThemePreviewCard(
              preview: preview,
              selected: preview.name == selectedTheme,
              onTap: () => onChanged(preview.name),
            ),
        ],
      ),
    );
  }
}

class _UiThemePreviewCard extends StatefulWidget {
  const _UiThemePreviewCard({
    required this.preview,
    required this.selected,
    required this.onTap,
  });

  final UiThemePreview preview;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_UiThemePreviewCard> createState() => _UiThemePreviewCardState();
}

class _UiThemePreviewCardState extends State<_UiThemePreviewCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final spacing = theme.spacing;
    final typo = theme.typography;
    final colors = theme.colorScheme;

    // Use the preview theme's colors for the card itself
    final previewColors = widget.preview.data.colorScheme;

    List<BoxShadow>? shadows;
    if (widget.selected && theme.useGlow && colors.glow != null) {
      shadows = [
        BoxShadow(
          color: colors.glow!.withValues(alpha: 0.3),
          blurRadius: 12,
          spreadRadius: 1,
        ),
      ];
    } else if (widget.selected && theme.useShadows) {
      shadows = [
        BoxShadow(
          color: colors.primary.withValues(alpha: 0.3),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];
    }

    return UiInteractiveRegion(
      enabled: true,
      onActivate: widget.onTap,
      semanticLabel: widget.preview.name,
      button: true,
      selected: widget.selected,
      borderRadius: theme.components.cardBorderRadius,
      child: GestureDetector(
        onTap: widget.onTap,
        child: MouseRegion(
          onEnter: (_) => setState(() => _hovered = true),
          onExit: (_) => setState(() => _hovered = false),
          child: AnimatedContainer(
            duration: theme.animationDuration,
            curve: theme.animationCurve,
            width: 176,
            padding: EdgeInsets.all(spacing.sm),
            decoration: BoxDecoration(
              color: colors.resolvedSurfaceRaised,
              borderRadius: theme.components.cardBorderRadius,
              border: Border.all(
                color: widget.selected
                    ? colors.primary
                    : _hovered
                    ? colors.onSurface.withValues(alpha: 0.2)
                    : colors.border,
                width: widget.selected ? 2.0 : theme.borderWidth,
              ),
              boxShadow: shadows,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  height: 92,
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: previewColors.resolvedCanvas,
                    borderRadius:
                        widget.preview.data.components.cardBorderRadius,
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: previewColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Container(
                            width: 44,
                            height: 5,
                            color: previewColors.resolvedOnSurfaceMuted,
                          ),
                          const Spacer(),
                          Container(
                            width: 22,
                            height: 8,
                            decoration: BoxDecoration(
                              color: previewColors.primary,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              width: 22,
                              decoration: BoxDecoration(
                                color: previewColors.surface,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Column(
                                children: [
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color:
                                            previewColors.resolvedSurfaceRaised,
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          height: 12,
                                          color: previewColors.secondary,
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      Expanded(
                                        child: Container(
                                          height: 12,
                                          color: previewColors.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: spacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.preview.name,
                        style: typo.labelMedium.copyWith(
                          color: colors.onSurface,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (widget.selected)
                      Icon(
                        theme.icons.resolve(UiIcons.check),
                        size: theme.components.iconSizeSmall,
                        color: colors.primary,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
