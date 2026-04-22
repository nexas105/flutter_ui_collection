import 'package:flutter/widgets.dart';

import '../../theme/ui_color_scheme.dart';
import '../../theme/ui_spacing.dart';
import '../../theme/ui_theme_data.dart';
import '../../theme/ui_typography.dart';

/// Retro/Pixel design preset -- nostalgic, 8-bit inspired, blocky.
///
/// Sharp pixel-perfect edges, bold primary colors, and a
/// chunky feel reminiscent of classic gaming UIs.
abstract final class RetroTheme {
  static final dark = UiThemeData(
    name: 'Retro Dark',
    colorScheme: const UiColorScheme(
      primary: Color(0xFF00CC00),
      onPrimary: Color(0xFF000000),
      secondary: Color(0xFFCC6600),
      onSecondary: Color(0xFF000000),
      surface: Color(0xFF222222),
      onSurface: Color(0xFF00CC00),
      background: Color(0xFF111111),
      onBackground: Color(0xFF00CC00),
      error: Color(0xFFCC0000),
      onError: Color(0xFFFFFFFF),
      success: Color(0xFF00CC00),
      onSuccess: Color(0xFF000000),
      warning: Color(0xFFCCCC00),
      onWarning: Color(0xFF000000),
      border: Color(0xFF00CC00),
      shadow: Color(0x4400CC00),
      glow: Color(0xFF00CC00),
    ),
    typography: UiTypography.fromFont(
      fontFamily: 'monospace',
      color: const Color(0xFF00CC00),
      baseWeight: FontWeight.w700,
    ),
    spacing: const UiSpacing(
      borderRadiusSm: 0.0,
      borderRadiusMd: 0.0,
      borderRadiusLg: 0.0,
      borderRadiusXl: 0.0,
      borderRadiusFull: 0.0,
    ),
    useGlow: true,
    useShadows: false,
    borderWidth: 2.0,
    animationDuration: const Duration(milliseconds: 100),
    animationCurve: Curves.linear,
  );

  static final light = UiThemeData(
    name: 'Retro Light',
    colorScheme: const UiColorScheme(
      primary: Color(0xFF0066CC),
      onPrimary: Color(0xFFFFFFFF),
      secondary: Color(0xFFCC3300),
      onSecondary: Color(0xFFFFFFFF),
      surface: Color(0xFFEEEECC),
      onSurface: Color(0xFF333300),
      background: Color(0xFFFFFFF0),
      onBackground: Color(0xFF333300),
      error: Color(0xFFCC0000),
      onError: Color(0xFFFFFFFF),
      success: Color(0xFF008800),
      onSuccess: Color(0xFFFFFFFF),
      warning: Color(0xFFCC9900),
      onWarning: Color(0xFF000000),
      border: Color(0xFF333300),
      shadow: Color(0x33333300),
    ),
    typography: UiTypography.fromFont(
      fontFamily: 'monospace',
      color: const Color(0xFF333300),
      baseWeight: FontWeight.w700,
    ),
    spacing: const UiSpacing(
      borderRadiusSm: 0.0,
      borderRadiusMd: 0.0,
      borderRadiusLg: 0.0,
      borderRadiusXl: 0.0,
      borderRadiusFull: 0.0,
    ),
    useShadows: true,
    borderWidth: 2.0,
    animationDuration: const Duration(milliseconds: 100),
    animationCurve: Curves.linear,
  );
}
