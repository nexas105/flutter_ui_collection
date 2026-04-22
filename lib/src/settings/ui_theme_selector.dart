import 'package:flutter/widgets.dart';

import '../theme/ui_theme.dart';
import '../theme/ui_theme_data.dart';

/// Represents a theme option for [UiThemeSelector].
class UiThemePreview {
  const UiThemePreview({
    required this.name,
    required this.data,
  });

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

    return GestureDetector(
      onTap: widget.onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: AnimatedContainer(
          duration: theme.animationDuration,
          curve: theme.animationCurve,
          width: 140,
          padding: EdgeInsets.all(spacing.sm + spacing.xs / 2),
          decoration: BoxDecoration(
            color: previewColors.surface,
            borderRadius: spacing.radiusMd,
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
            children: [
              // Color swatches row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _ColorDot(color: previewColors.primary, size: 20),
                  SizedBox(width: spacing.xs),
                  _ColorDot(color: previewColors.secondary, size: 20),
                  SizedBox(width: spacing.xs),
                  _ColorDot(color: previewColors.background, size: 20),
                ],
              ),
              SizedBox(height: spacing.sm),
              // Theme name + checkmark
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      widget.preview.name,
                      style: typo.labelMedium.copyWith(
                        color: previewColors.onSurface,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (widget.selected) ...[
                    SizedBox(width: spacing.xs),
                    Text(
                      '\u2713',
                      style: TextStyle(
                        fontSize: 14,
                        color: colors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ColorDot extends StatelessWidget {
  const _ColorDot({
    required this.color,
    this.size = 16,
  });

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: theme.colorScheme.border,
          width: theme.borderWidth,
        ),
      ),
    );
  }
}
