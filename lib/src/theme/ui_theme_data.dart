import 'package:flutter/widgets.dart';

import 'ui_color_scheme.dart';
import 'ui_component_tokens.dart';
import 'ui_icon_set.dart';
import 'ui_spacing.dart';
import 'ui_typography.dart';

/// The visual configuration for all UI components.
///
/// [UiThemeData] bundles color scheme, typography, spacing, and
/// component-level overrides into a single, immutable object.
/// Pass it to [UiTheme] to make it available throughout the widget tree.
class UiThemeData {
  const UiThemeData({
    required this.name,
    required this.colorScheme,
    required this.typography,
    this.spacing = const UiSpacing(),
    this.components = const UiComponentTokens(),
    this.icons = const UiIconSet(),
    this.animationDuration = const Duration(milliseconds: 200),
    this.animationCurve = Curves.easeInOut,
    this.useShadows = true,
    this.useGlow = false,
    this.useGradients = false,
    this.borderWidth = 1.0,
    this.elevation = 0.0,
  });

  /// Human-readable name of this theme (e.g. "Neon", "Glass").
  final String name;

  final UiColorScheme colorScheme;
  final UiTypography typography;
  final UiSpacing spacing;
  final UiComponentTokens components;
  final UiIconSet icons;

  /// Default animation duration for interactive components.
  final Duration animationDuration;

  /// Default animation curve for interactive components.
  final Curve animationCurve;

  /// Whether components should render drop shadows.
  final bool useShadows;

  /// Whether components should render glow effects (neon, cyberpunk).
  final bool useGlow;

  /// Whether components should use gradient fills.
  final bool useGradients;

  /// Default border width for outlined components.
  final double borderWidth;

  /// Default elevation for cards and surfaces.
  final double elevation;

  /// Resolves the preset's shared depth treatment for cards and overlays.
  ///
  /// Modules should use this instead of rebuilding glow and shadow constants.
  List<BoxShadow>? surfaceShadows({bool emphasized = false, Color? accent}) {
    if (useGlow && colorScheme.glow != null) {
      final glow = accent ?? colorScheme.glow!;
      return [
        BoxShadow(
          color: glow.withValues(alpha: emphasized ? 0.32 : 0.18),
          blurRadius: components.shadowBlur * (emphasized ? 1.15 : 0.75),
          offset: components.shadowOffset * 0.5,
        ),
      ];
    }
    if (useShadows) {
      return [
        BoxShadow(
          color: accent ?? colorScheme.shadow,
          blurRadius: components.shadowBlur * (emphasized ? 1 : 0.65),
          offset: components.shadowOffset,
        ),
      ];
    }
    return null;
  }

  UiThemeData copyWith({
    String? name,
    UiColorScheme? colorScheme,
    UiTypography? typography,
    UiSpacing? spacing,
    UiComponentTokens? components,
    UiIconSet? icons,
    Duration? animationDuration,
    Curve? animationCurve,
    bool? useShadows,
    bool? useGlow,
    bool? useGradients,
    double? borderWidth,
    double? elevation,
  }) {
    return UiThemeData(
      name: name ?? this.name,
      colorScheme: colorScheme ?? this.colorScheme,
      typography: typography ?? this.typography,
      spacing: spacing ?? this.spacing,
      components: components ?? this.components,
      icons: icons ?? this.icons,
      animationDuration: animationDuration ?? this.animationDuration,
      animationCurve: animationCurve ?? this.animationCurve,
      useShadows: useShadows ?? this.useShadows,
      useGlow: useGlow ?? this.useGlow,
      useGradients: useGradients ?? this.useGradients,
      borderWidth: borderWidth ?? this.borderWidth,
      elevation: elevation ?? this.elevation,
    );
  }
}
