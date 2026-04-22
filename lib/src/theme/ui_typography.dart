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
  }) {
    return UiTypography(
      displayLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: baseSize * 4.0,
        fontWeight: FontWeight.w300,
        color: color,
        letterSpacing: -1.5,
      ),
      displayMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: baseSize * 3.5,
        fontWeight: FontWeight.w300,
        color: color,
        letterSpacing: -0.5,
      ),
      displaySmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: baseSize * 3.0,
        fontWeight: FontWeight.w400,
        color: color,
      ),
      headlineLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: baseSize * 2.25,
        fontWeight: FontWeight.w600,
        color: color,
        letterSpacing: 0.25,
      ),
      headlineMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: baseSize * 2.0,
        fontWeight: FontWeight.w600,
        color: color,
      ),
      headlineSmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: baseSize * 1.7,
        fontWeight: FontWeight.w600,
        color: color,
      ),
      titleLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: baseSize * 1.55,
        fontWeight: FontWeight.w500,
        color: color,
        letterSpacing: 0.15,
      ),
      titleMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: baseSize * 1.15,
        fontWeight: FontWeight.w500,
        color: color,
        letterSpacing: 0.15,
      ),
      titleSmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: baseSize,
        fontWeight: FontWeight.w500,
        color: color,
        letterSpacing: 0.1,
      ),
      bodyLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: baseSize * 1.15,
        fontWeight: baseWeight,
        color: color,
        letterSpacing: 0.5,
      ),
      bodyMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: baseSize,
        fontWeight: baseWeight,
        color: color,
        letterSpacing: 0.25,
      ),
      bodySmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: baseSize * 0.85,
        fontWeight: baseWeight,
        color: color,
        letterSpacing: 0.4,
      ),
      labelLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: baseSize,
        fontWeight: FontWeight.w600,
        color: color,
        letterSpacing: 1.25,
      ),
      labelMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: baseSize * 0.85,
        fontWeight: FontWeight.w600,
        color: color,
        letterSpacing: 1.0,
      ),
      labelSmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: baseSize * 0.75,
        fontWeight: FontWeight.w600,
        color: color,
        letterSpacing: 1.5,
      ),
    );
  }

  UiTypography apply({Color? color, String? fontFamily}) {
    TextStyle applyOverrides(TextStyle style) => style.copyWith(
          color: color,
          fontFamily: fontFamily,
        );

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
