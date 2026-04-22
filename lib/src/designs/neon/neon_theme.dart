import 'dart:ui';

import '../../theme/ui_color_scheme.dart';
import '../../theme/ui_spacing.dart';
import '../../theme/ui_theme_data.dart';
import '../../theme/ui_typography.dart';

/// Neon design preset — bold, glowing, dark-first.
///
/// Inspired by cyberpunk aesthetics with vibrant accent colors,
/// glow effects, and high-contrast dark surfaces.
abstract final class NeonTheme {
  /// Dark neon theme with cyan primary and magenta secondary.
  static final dark = UiThemeData(
    name: 'Neon Dark',
    colorScheme: const UiColorScheme(
      primary: Color(0xFF00F0FF),
      onPrimary: Color(0xFF000000),
      secondary: Color(0xFFFF00E5),
      onSecondary: Color(0xFF000000),
      surface: Color(0xFF1A1A2E),
      onSurface: Color(0xFFE0E0FF),
      background: Color(0xFF0D0D1A),
      onBackground: Color(0xFFE0E0FF),
      error: Color(0xFFFF3366),
      onError: Color(0xFF000000),
      success: Color(0xFF00FF88),
      onSuccess: Color(0xFF000000),
      warning: Color(0xFFFFCC00),
      onWarning: Color(0xFF000000),
      border: Color(0xFF2A2A4A),
      shadow: Color(0x6600F0FF),
      glow: Color(0xFF00F0FF),
      gradient: [Color(0xFF00F0FF), Color(0xFFFF00E5)],
    ),
    typography: UiTypography.fromFont(
      fontFamily: 'sans-serif',
      color: const Color(0xFFE0E0FF),
    ),
    spacing: const UiSpacing(
      borderRadiusSm: 4.0,
      borderRadiusMd: 8.0,
      borderRadiusLg: 12.0,
      borderRadiusXl: 20.0,
    ),
    useGlow: true,
    useGradients: true,
    useShadows: true,
    borderWidth: 1.5,
    animationDuration: const Duration(milliseconds: 250),
  );

  /// Light neon variant — same accent palette on light surfaces.
  static final light = UiThemeData(
    name: 'Neon Light',
    colorScheme: const UiColorScheme(
      primary: Color(0xFF0099AA),
      onPrimary: Color(0xFFFFFFFF),
      secondary: Color(0xFFBB00AA),
      onSecondary: Color(0xFFFFFFFF),
      surface: Color(0xFFF0F0FF),
      onSurface: Color(0xFF1A1A2E),
      background: Color(0xFFFFFFFF),
      onBackground: Color(0xFF1A1A2E),
      error: Color(0xFFCC2255),
      onError: Color(0xFFFFFFFF),
      success: Color(0xFF00AA55),
      onSuccess: Color(0xFFFFFFFF),
      warning: Color(0xFFCC9900),
      onWarning: Color(0xFF000000),
      border: Color(0xFFCCCCEE),
      shadow: Color(0x330099AA),
      glow: Color(0xFF0099AA),
      gradient: [Color(0xFF0099AA), Color(0xFFBB00AA)],
    ),
    typography: UiTypography.fromFont(
      fontFamily: 'sans-serif',
      color: const Color(0xFF1A1A2E),
    ),
    useGlow: true,
    useGradients: true,
    useShadows: true,
    borderWidth: 1.5,
  );
}
