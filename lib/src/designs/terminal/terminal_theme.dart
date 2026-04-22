import 'package:flutter/widgets.dart';

import '../../theme/ui_color_scheme.dart';
import '../../theme/ui_spacing.dart';
import '../../theme/ui_theme_data.dart';
import '../../theme/ui_typography.dart';

/// Terminal/Hacker design preset -- monochrome green-on-black, raw.
///
/// Classic terminal aesthetic with scan-line feel, monospace type,
/// and minimal decoration. Pure function over form.
abstract final class TerminalTheme {
  static final dark = UiThemeData(
    name: 'Terminal Dark',
    colorScheme: const UiColorScheme(
      primary: Color(0xFF33FF33),
      onPrimary: Color(0xFF000000),
      secondary: Color(0xFF33FF33),
      onSecondary: Color(0xFF000000),
      surface: Color(0xFF0A0A0A),
      onSurface: Color(0xFF33FF33),
      background: Color(0xFF000000),
      onBackground: Color(0xFF33FF33),
      error: Color(0xFFFF3333),
      onError: Color(0xFF000000),
      success: Color(0xFF33FF33),
      onSuccess: Color(0xFF000000),
      warning: Color(0xFFFFFF33),
      onWarning: Color(0xFF000000),
      border: Color(0xFF1A3A1A),
      shadow: Color(0x3333FF33),
      glow: Color(0xFF33FF33),
    ),
    typography: UiTypography.fromFont(
      fontFamily: 'monospace',
      color: const Color(0xFF33FF33),
      baseWeight: FontWeight.w400,
    ),
    spacing: const UiSpacing(
      xs: 4.0,
      sm: 8.0,
      md: 12.0,
      lg: 20.0,
      xl: 28.0,
      borderRadiusSm: 0.0,
      borderRadiusMd: 2.0,
      borderRadiusLg: 2.0,
      borderRadiusXl: 2.0,
      borderRadiusFull: 2.0,
    ),
    useGlow: true,
    useShadows: false,
    borderWidth: 1.0,
    animationDuration: Duration.zero,
    animationCurve: Curves.linear,
  );

  /// Amber terminal variant.
  static final amber = UiThemeData(
    name: 'Terminal Amber',
    colorScheme: const UiColorScheme(
      primary: Color(0xFFFFBB33),
      onPrimary: Color(0xFF000000),
      secondary: Color(0xFFFFBB33),
      onSecondary: Color(0xFF000000),
      surface: Color(0xFF0A0800),
      onSurface: Color(0xFFFFBB33),
      background: Color(0xFF000000),
      onBackground: Color(0xFFFFBB33),
      error: Color(0xFFFF3333),
      onError: Color(0xFF000000),
      success: Color(0xFFFFBB33),
      onSuccess: Color(0xFF000000),
      warning: Color(0xFFFFFF33),
      onWarning: Color(0xFF000000),
      border: Color(0xFF3A2A0A),
      shadow: Color(0x33FFBB33),
      glow: Color(0xFFFFBB33),
    ),
    typography: UiTypography.fromFont(
      fontFamily: 'monospace',
      color: const Color(0xFFFFBB33),
      baseWeight: FontWeight.w400,
    ),
    spacing: const UiSpacing(
      xs: 4.0,
      sm: 8.0,
      md: 12.0,
      lg: 20.0,
      xl: 28.0,
      borderRadiusSm: 0.0,
      borderRadiusMd: 2.0,
      borderRadiusLg: 2.0,
      borderRadiusXl: 2.0,
      borderRadiusFull: 2.0,
    ),
    useGlow: true,
    useShadows: false,
    borderWidth: 1.0,
    animationDuration: Duration.zero,
    animationCurve: Curves.linear,
  );
}
