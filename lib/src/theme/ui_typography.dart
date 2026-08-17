import 'package:flutter/widgets.dart';

/// Typography system for UI components.
///
/// Provides a consistent text style hierarchy independent of Material's
/// TextTheme. Each level maps to a semantic role in the UI.
class UiTypography {
  const UiTypography({
    required this.displayLarge,
    required this.displayMedium,
    required this.displaySmall,
    required this.headlineLarge,
    required this.headlineMedium,
    required this.headlineSmall,
    required this.titleLarge,
    required this.titleMedium,
    required this.titleSmall,
    required this.bodyLarge,
    required this.bodyMedium,
    required this.bodySmall,
    required this.labelLarge,
    required this.labelMedium,
    required this.labelSmall,
  });

  final TextStyle displayLarge;
  final TextStyle displayMedium;
  final TextStyle displaySmall;
  final TextStyle headlineLarge;
  final TextStyle headlineMedium;
  final TextStyle headlineSmall;
  final TextStyle titleLarge;
  final TextStyle titleMedium;
  final TextStyle titleSmall;
  final TextStyle bodyLarge;
  final TextStyle bodyMedium;
  final TextStyle bodySmall;
  final TextStyle labelLarge;
  final TextStyle labelMedium;
  final TextStyle labelSmall;

  /// Creates a default typography set from a base font family and color.
  factory UiTypography.fromFont({
    required String fontFamily,
    required Color color,
    double baseSize = 14.0,
    FontWeight baseWeight = FontWeight.w400,
    String? displayFontFamily,
    List<String>? fontFamilyFallback,
  }) {
    final resolvedFallback =
        fontFamilyFallback ??
        (fontFamily == 'monospace'
            ? const ['SFMono-Regular', 'Menlo', 'Consolas']
            : const ['SF Pro Text', 'Segoe UI', 'Roboto']);

    TextStyle style({
      required double size,
      required FontWeight weight,
      required double height,
      double? letterSpacing,
      bool display = false,
    }) {
      return TextStyle(
        fontFamily: display ? displayFontFamily ?? fontFamily : fontFamily,
        fontFamilyFallback: resolvedFallback,
        fontSize: size,
        fontWeight: weight,
        height: height,
        color: color,
        letterSpacing: letterSpacing,
      );
    }

    return UiTypography(
      displayLarge: style(
        size: baseSize * 4.0,
        weight: FontWeight.w600,
        height: 1.02,
        letterSpacing: -1.5,
        display: true,
      ),
      displayMedium: style(
        size: baseSize * 3.5,
        weight: FontWeight.w600,
        height: 1.05,
        letterSpacing: -1.0,
        display: true,
      ),
      displaySmall: style(
        size: baseSize * 3.0,
        weight: FontWeight.w600,
        height: 1.08,
        letterSpacing: -0.7,
        display: true,
      ),
      headlineLarge: style(
        size: baseSize * 2.25,
        weight: FontWeight.w600,
        height: 1.15,
        letterSpacing: -0.4,
        display: true,
      ),
      headlineMedium: style(
        size: baseSize * 2.0,
        weight: FontWeight.w600,
        height: 1.18,
        letterSpacing: -0.3,
        display: true,
      ),
      headlineSmall: style(
        size: baseSize * 1.7,
        weight: FontWeight.w600,
        height: 1.2,
        letterSpacing: -0.2,
        display: true,
      ),
      titleLarge: style(
        size: baseSize * 1.55,
        weight: FontWeight.w600,
        height: 1.25,
        letterSpacing: -0.15,
      ),
      titleMedium: style(
        size: baseSize * 1.15,
        weight: FontWeight.w600,
        height: 1.3,
      ),
      titleSmall: style(size: baseSize, weight: FontWeight.w600, height: 1.35),
      bodyLarge: style(size: baseSize * 1.15, weight: baseWeight, height: 1.5),
      bodyMedium: style(size: baseSize, weight: baseWeight, height: 1.5),
      bodySmall: style(
        size: baseSize * 0.85,
        weight: baseWeight,
        height: 1.45,
        letterSpacing: 0.1,
      ),
      labelLarge: style(
        size: baseSize,
        weight: FontWeight.w600,
        height: 1.2,
        letterSpacing: 0.1,
      ),
      labelMedium: style(
        size: baseSize * 0.85,
        weight: FontWeight.w600,
        height: 1.2,
        letterSpacing: 0.15,
      ),
      labelSmall: style(
        size: baseSize * 0.75,
        weight: FontWeight.w600,
        height: 1.2,
        letterSpacing: 0.2,
      ),
    );
  }

  UiTypography apply({Color? color, String? fontFamily}) {
    TextStyle applyOverrides(TextStyle style) =>
        style.copyWith(color: color, fontFamily: fontFamily);

    return UiTypography(
      displayLarge: applyOverrides(displayLarge),
      displayMedium: applyOverrides(displayMedium),
      displaySmall: applyOverrides(displaySmall),
      headlineLarge: applyOverrides(headlineLarge),
      headlineMedium: applyOverrides(headlineMedium),
      headlineSmall: applyOverrides(headlineSmall),
      titleLarge: applyOverrides(titleLarge),
      titleMedium: applyOverrides(titleMedium),
      titleSmall: applyOverrides(titleSmall),
      bodyLarge: applyOverrides(bodyLarge),
      bodyMedium: applyOverrides(bodyMedium),
      bodySmall: applyOverrides(bodySmall),
      labelLarge: applyOverrides(labelLarge),
      labelMedium: applyOverrides(labelMedium),
      labelSmall: applyOverrides(labelSmall),
    );
  }
}
