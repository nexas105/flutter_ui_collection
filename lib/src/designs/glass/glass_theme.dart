import 'package:flutter/widgets.dart';

import '../../theme/ui_color_scheme.dart';
import '../../theme/ui_spacing.dart';
import '../../theme/ui_theme_data.dart';
import '../../theme/ui_typography.dart';

/// Glassmorphism design preset — frosted, translucent, elegant.
///
/// Semi-transparent surfaces with blur effects and subtle borders.
/// Works best on gradient or image backgrounds.
abstract final class GlassTheme {
  /// Dark glass theme with frosted surfaces.
  static final dark = UiThemeData(
    name: 'Glass Dark',
    colorScheme: const UiColorScheme(
      primary: Color(0xFF7C83FF),
      onPrimary: Color(0xFFFFFFFF),
      secondary: Color(0xFFFF7EB3),
      onSecondary: Color(0xFFFFFFFF),
      surface: Color(0x33FFFFFF),
      onSurface: Color(0xFFFFFFFF),
      background: Color(0xFF121224),
      onBackground: Color(0xFFFFFFFF),
      error: Color(0xFFFF6B6B),
      onError: Color(0xFFFFFFFF),
      success: Color(0xFF51CF66),
      onSuccess: Color(0xFFFFFFFF),
      warning: Color(0xFFFFD43B),
      onWarning: Color(0xFF000000),
      border: Color(0x44FFFFFF),
      shadow: Color(0x11000000),
    ),
    typography: UiTypography.fromFont(
      fontFamily: 'SF Pro Text',
      displayFontFamily: 'SF Pro Display',
      fontFamilyFallback: const ['Segoe UI', 'Roboto'],
      color: const Color(0xFFFFFFFF),
      baseWeight: FontWeight.w300,
    ),
    spacing: const UiSpacing(
      borderRadiusSm: 8.0,
      borderRadiusMd: 16.0,
      borderRadiusLg: 24.0,
      borderRadiusXl: 32.0,
    ),
    useShadows: false,
    borderWidth: 1.0,
    elevation: 0,
    animationDuration: const Duration(milliseconds: 300),
    animationCurve: Curves.easeOutCubic,
  );

  /// Light glass theme with frosted light surfaces.
  static final light = UiThemeData(
    name: 'Glass Light',
    colorScheme: const UiColorScheme(
      primary: Color(0xFF5C63E0),
      onPrimary: Color(0xFFFFFFFF),
      secondary: Color(0xFFE0598B),
      onSecondary: Color(0xFFFFFFFF),
      surface: Color(0x88FFFFFF),
      onSurface: Color(0xFF1A1A2E),
      background: Color(0xFFEEEEFF),
      onBackground: Color(0xFF1A1A2E),
      error: Color(0xFFE03131),
      onError: Color(0xFFFFFFFF),
      success: Color(0xFF2B8A3E),
      onSuccess: Color(0xFFFFFFFF),
      warning: Color(0xFFE67700),
      onWarning: Color(0xFFFFFFFF),
      border: Color(0x33000000),
      shadow: Color(0x08000000),
    ),
    typography: UiTypography.fromFont(
      fontFamily: 'SF Pro Text',
      displayFontFamily: 'SF Pro Display',
      fontFamilyFallback: const ['Segoe UI', 'Roboto'],
      color: const Color(0xFF1A1A2E),
      baseWeight: FontWeight.w300,
    ),
    spacing: const UiSpacing(
      borderRadiusSm: 8.0,
      borderRadiusMd: 16.0,
      borderRadiusLg: 24.0,
      borderRadiusXl: 32.0,
    ),
    useShadows: false,
    borderWidth: 1.0,
    elevation: 0,
    animationDuration: const Duration(milliseconds: 300),
    animationCurve: Curves.easeOutCubic,
  );
}
