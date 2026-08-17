import 'dart:ui';

import '../../theme/ui_color_scheme.dart';
import '../../theme/ui_spacing.dart';
import '../../theme/ui_theme_data.dart';
import '../../theme/ui_typography.dart';

/// Minimal design preset — clean, spacious, typography-focused.
///
/// Flat surfaces, generous whitespace, and restrained color use.
/// Ideal for content-heavy applications.
abstract final class MinimalTheme {
  static final dark = UiThemeData(
    name: 'Minimal Dark',
    colorScheme: const UiColorScheme(
      primary: Color(0xFFFFFFFF),
      onPrimary: Color(0xFF111111),
      secondary: Color(0xFF888888),
      onSecondary: Color(0xFFFFFFFF),
      surface: Color(0xFF1C1C1E),
      onSurface: Color(0xFFE5E5E7),
      background: Color(0xFF111111),
      onBackground: Color(0xFFE5E5E7),
      error: Color(0xFFFF453A),
      onError: Color(0xFFFFFFFF),
      success: Color(0xFF30D158),
      onSuccess: Color(0xFF000000),
      warning: Color(0xFFFFD60A),
      onWarning: Color(0xFF000000),
      border: Color(0xFF38383A),
      shadow: Color(0x33000000),
    ),
    typography: UiTypography.fromFont(
      fontFamily: 'Helvetica Neue',
      fontFamilyFallback: const ['Segoe UI', 'Roboto'],
      color: const Color(0xFFE5E5E7),
      baseWeight: FontWeight.w400,
    ),
    spacing: const UiSpacing(
      sm: 10.0,
      md: 20.0,
      lg: 32.0,
      xl: 44.0,
      borderRadiusSm: 6.0,
      borderRadiusMd: 10.0,
      borderRadiusLg: 14.0,
      borderRadiusXl: 20.0,
    ),
    useShadows: false,
    useGlow: false,
    borderWidth: 1.0,
  );

  static final light = UiThemeData(
    name: 'Minimal Light',
    colorScheme: const UiColorScheme(
      primary: Color(0xFF111111),
      onPrimary: Color(0xFFFFFFFF),
      secondary: Color(0xFF6E6E73),
      onSecondary: Color(0xFFFFFFFF),
      surface: Color(0xFFFFFFFF),
      onSurface: Color(0xFF1C1C1E),
      background: Color(0xFFF5F5F7),
      onBackground: Color(0xFF1C1C1E),
      error: Color(0xFFFF3B30),
      onError: Color(0xFFFFFFFF),
      success: Color(0xFF34C759),
      onSuccess: Color(0xFFFFFFFF),
      warning: Color(0xFFFF9500),
      onWarning: Color(0xFFFFFFFF),
      border: Color(0xFFD1D1D6),
      shadow: Color(0x14000000),
    ),
    typography: UiTypography.fromFont(
      fontFamily: 'Helvetica Neue',
      fontFamilyFallback: const ['Segoe UI', 'Roboto'],
      color: const Color(0xFF1C1C1E),
      baseWeight: FontWeight.w400,
    ),
    spacing: const UiSpacing(
      sm: 10.0,
      md: 20.0,
      lg: 32.0,
      xl: 44.0,
      borderRadiusSm: 6.0,
      borderRadiusMd: 10.0,
      borderRadiusLg: 14.0,
      borderRadiusXl: 20.0,
    ),
    useShadows: true,
    useGlow: false,
    borderWidth: 0.5,
  );
}
