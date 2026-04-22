import 'package:flutter/widgets.dart';

import 'ui_color_scheme.dart';
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

  UiThemeData copyWith({
    String? name,
    UiColorScheme? colorScheme,
    UiTypography? typography,
    UiSpacing? spacing,
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
