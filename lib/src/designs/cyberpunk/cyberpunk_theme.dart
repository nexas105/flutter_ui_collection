import 'package:flutter/widgets.dart';

import '../../theme/ui_color_scheme.dart';
import '../../theme/ui_spacing.dart';
import '../../theme/ui_theme_data.dart';
import '../../theme/ui_typography.dart';

/// Cyberpunk design preset — aggressive, angular, high-energy.
///
/// Sharp corners, bold neon accents on deep dark backgrounds,
/// and asymmetric visual weight. Think terminal-meets-nightclub.
abstract final class CyberpunkTheme {
  static final dark = UiThemeData(
    name: 'Cyberpunk Dark',
    colorScheme: const UiColorScheme(
      primary: Color(0xFFFFE500),
      onPrimary: Color(0xFF000000),
      secondary: Color(0xFFFF0055),
      onSecondary: Color(0xFFFFFFFF),
      surface: Color(0xFF1A0A2E),
      onSurface: Color(0xFFE0D0FF),
      background: Color(0xFF0A0014),
      onBackground: Color(0xFFE0D0FF),
      error: Color(0xFFFF0055),
      onError: Color(0xFFFFFFFF),
      success: Color(0xFF00FF41),
      onSuccess: Color(0xFF000000),
      warning: Color(0xFFFF6600),
      onWarning: Color(0xFF000000),
      border: Color(0xFF3D1A6E),
      shadow: Color(0x88FFE500),
      glow: Color(0xFFFFE500),
      gradient: [Color(0xFFFFE500), Color(0xFFFF0055), Color(0xFF7B2FBE)],
    ),
    typography: UiTypography.fromFont(
      fontFamily: 'monospace',
      color: const Color(0xFFE0D0FF),
      baseWeight: FontWeight.w500,
    ),
    spacing: const UiSpacing(
      borderRadiusSm: 0.0,
      borderRadiusMd: 2.0,
      borderRadiusLg: 4.0,
      borderRadiusXl: 4.0,
    ),
    useGlow: true,
    useGradients: true,
    useShadows: true,
    borderWidth: 2.0,
    animationDuration: const Duration(milliseconds: 150),
    animationCurve: Curves.easeOutBack,
  );

  static final light = UiThemeData(
    name: 'Cyberpunk Light',
    colorScheme: const UiColorScheme(
      primary: Color(0xFFBB9900),
      onPrimary: Color(0xFFFFFFFF),
      secondary: Color(0xFFCC0044),
      onSecondary: Color(0xFFFFFFFF),
      surface: Color(0xFFF5F0FF),
      onSurface: Color(0xFF1A0A2E),
      background: Color(0xFFFFFFFF),
      onBackground: Color(0xFF1A0A2E),
      error: Color(0xFFCC0044),
      onError: Color(0xFFFFFFFF),
      success: Color(0xFF00AA33),
      onSuccess: Color(0xFFFFFFFF),
      warning: Color(0xFFCC5500),
      onWarning: Color(0xFFFFFFFF),
      border: Color(0xFFCCBBEE),
      shadow: Color(0x33BB9900),
      glow: Color(0xFFBB9900),
      gradient: [Color(0xFFBB9900), Color(0xFFCC0044)],
    ),
    typography: UiTypography.fromFont(
      fontFamily: 'monospace',
      color: const Color(0xFF1A0A2E),
      baseWeight: FontWeight.w500,
    ),
    spacing: const UiSpacing(
      borderRadiusSm: 0.0,
      borderRadiusMd: 2.0,
      borderRadiusLg: 4.0,
      borderRadiusXl: 4.0,
    ),
    useGlow: true,
    useGradients: true,
    useShadows: true,
    borderWidth: 2.0,
    animationDuration: const Duration(milliseconds: 150),
    animationCurve: Curves.easeOutBack,
  );
}
