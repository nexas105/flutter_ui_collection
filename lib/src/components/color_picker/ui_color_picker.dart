import 'package:flutter/widgets.dart';

import '../../icons/ui_icons.dart';
import '../../theme/ui_theme.dart';

/// A grid of color swatches for selecting a color.
///
/// ```dart
/// UiColorPicker(
///   value: selectedColor,
///   onChanged: (color) => setState(() => selectedColor = color),
/// )
/// ```
class UiColorPicker extends StatelessWidget {
  const UiColorPicker({
    super.key,
    required this.value,
    required this.onChanged,
    this.colors = defaultColors,
    this.label,
    this.size = 36.0,
  });

  /// The currently selected color.
  final Color value;

  /// Called when the user taps a color swatch.
  final ValueChanged<Color> onChanged;

  /// The palette of colors to display.
  final List<Color> colors;

  /// Optional label displayed above the color grid.
  final String? label;

  /// The diameter of each color swatch.
  final double size;

  /// A sensible default palette: rainbow hues plus grays.
  static const List<Color> defaultColors = [
    Color(0xFFEF4444), // red
    Color(0xFFF97316), // orange
    Color(0xFFEAB308), // yellow
    Color(0xFF22C55E), // green
    Color(0xFF14B8A6), // teal
    Color(0xFF3B82F6), // blue
    Color(0xFF6366F1), // indigo
    Color(0xFF8B5CF6), // violet
    Color(0xFFEC4899), // pink
    Color(0xFF000000), // black
    Color(0xFF6B7280), // gray
    Color(0xFFD1D5DB), // light gray
    Color(0xFFFFFFFF), // white
  ];

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final spacing = theme.spacing;
    final typo = theme.typography;
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: typo.labelMedium.copyWith(color: colors.onSurface),
          ),
          SizedBox(height: spacing.sm),
        ],
        Wrap(
          spacing: spacing.sm,
          runSpacing: spacing.sm,
          children: [
            for (final color in this.colors)
              _ColorSwatch(
                color: color,
                selected: value == color,
                size: size,
                onTap: () => onChanged(color),
              ),
          ],
        ),
      ],
    );
  }
}

class _ColorSwatch extends StatefulWidget {
  const _ColorSwatch({
    required this.color,
    required this.selected,
    required this.size,
    required this.onTap,
  });

  final Color color;
  final bool selected;
  final double size;
  final VoidCallback onTap;

  @override
  State<_ColorSwatch> createState() => _ColorSwatchState();
}

class _ColorSwatchState extends State<_ColorSwatch> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final colors = theme.colorScheme;

    List<BoxShadow>? shadows;
    if (widget.selected && theme.useGlow && colors.glow != null) {
      shadows = [
        BoxShadow(
          color: colors.glow!.withValues(alpha: 0.4),
          blurRadius: 10,
          spreadRadius: 2,
        ),
      ];
    } else if (widget.selected) {
      shadows = [
        BoxShadow(
          color: widget.color.withValues(alpha: 0.4),
          blurRadius: 8,
          spreadRadius: 1,
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
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: widget.color,
            shape: BoxShape.circle,
            border: Border.all(
              color: widget.selected
                  ? colors.primary
                  : _hovered
                  ? colors.border
                  : colors.border.withValues(alpha: 0.3),
              width: widget.selected ? 2.0 : theme.borderWidth,
            ),
            boxShadow: shadows,
          ),
          child: widget.selected
              ? Center(
                  child: Icon(
                    UiIcons.check,
                    size: widget.size * 0.5,
                    color: _contrastColor(widget.color),
                  ),
                )
              : null,
        ),
      ),
    );
  }

  /// Returns white or black depending on the luminance of [color].
  static Color _contrastColor(Color color) {
    final luminance = 0.299 * color.r + 0.587 * color.g + 0.114 * color.b;
    return luminance > 0.5 ? const Color(0xFF000000) : const Color(0xFFFFFFFF);
  }
}
