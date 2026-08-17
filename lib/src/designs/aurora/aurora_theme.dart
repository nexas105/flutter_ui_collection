import 'package:flutter/widgets.dart';

import '../../theme/ui_color_scheme.dart';
import '../../theme/ui_spacing.dart';
import '../../theme/ui_theme_data.dart';
import '../../theme/ui_typography.dart';

/// Aurora design preset -- gradient-heavy, flowing, ethereal.
///
/// Soft gradients, rounded shapes, and a dreamy color palette
/// inspired by the Northern Lights.
abstract final class AuroraTheme {
  static final dark = UiThemeData(
    name: 'Aurora Dark',
    colorScheme: const UiColorScheme(
      primary: Color(0xFF6366F1),
      onPrimary: Color(0xFFFFFFFF),
      secondary: Color(0xFF06B6D4),
      onSecondary: Color(0xFFFFFFFF),
      surface: Color(0xFF1E1B3A),
      onSurface: Color(0xFFE0DEFF),
      background: Color(0xFF0F0D24),
      onBackground: Color(0xFFE0DEFF),
      error: Color(0xFFF43F5E),
      onError: Color(0xFFFFFFFF),
      success: Color(0xFF10B981),
      onSuccess: Color(0xFFFFFFFF),
      warning: Color(0xFFF59E0B),
      onWarning: Color(0xFF000000),
      border: Color(0xFF3730A3),
      shadow: Color(0x336366F1),
      glow: Color(0xFF818CF8),
      gradient: [
        Color(0xFF6366F1),
        Color(0xFF8B5CF6),
        Color(0xFF06B6D4),
        Color(0xFF10B981),
      ],
    ),
    typography: UiTypography.fromFont(
      fontFamily: 'Avenir Next',
      displayFontFamily: 'Avenir Next Condensed',
      fontFamilyFallback: const ['Segoe UI', 'Roboto'],
      color: const Color(0xFFE0DEFF),
      baseWeight: FontWeight.w300,
    ),
    spacing: const UiSpacing(
      borderRadiusSm: 10.0,
      borderRadiusMd: 16.0,
      borderRadiusLg: 24.0,
      borderRadiusXl: 32.0,
    ),
    useGlow: true,
    useGradients: true,
    useShadows: true,
    borderWidth: 1.0,
    animationDuration: const Duration(milliseconds: 400),
    animationCurve: Curves.easeInOutCubic,
  );

  static final light = UiThemeData(
    name: 'Aurora Light',
    colorScheme: const UiColorScheme(
      primary: Color(0xFF4F46E5),
      onPrimary: Color(0xFFFFFFFF),
      secondary: Color(0xFF0891B2),
      onSecondary: Color(0xFFFFFFFF),
      surface: Color(0xFFFFFFFF),
      onSurface: Color(0xFF1E1B4B),
      background: Color(0xFFF5F3FF),
      onBackground: Color(0xFF1E1B4B),
      error: Color(0xFFE11D48),
      onError: Color(0xFFFFFFFF),
      success: Color(0xFF059669),
      onSuccess: Color(0xFFFFFFFF),
      warning: Color(0xFFD97706),
      onWarning: Color(0xFFFFFFFF),
      border: Color(0xFFC7D2FE),
      shadow: Color(0x1A6366F1),
      glow: Color(0xFF818CF8),
      gradient: [Color(0xFF4F46E5), Color(0xFF7C3AED), Color(0xFF0891B2)],
    ),
    typography: UiTypography.fromFont(
      fontFamily: 'Avenir Next',
      displayFontFamily: 'Avenir Next Condensed',
      fontFamilyFallback: const ['Segoe UI', 'Roboto'],
      color: const Color(0xFF1E1B4B),
      baseWeight: FontWeight.w300,
    ),
    spacing: const UiSpacing(
      borderRadiusSm: 10.0,
      borderRadiusMd: 16.0,
      borderRadiusLg: 24.0,
      borderRadiusXl: 32.0,
    ),
    useGlow: false,
    useGradients: true,
    useShadows: true,
    borderWidth: 1.0,
    animationDuration: const Duration(milliseconds: 400),
    animationCurve: Curves.easeInOutCubic,
  );
}
