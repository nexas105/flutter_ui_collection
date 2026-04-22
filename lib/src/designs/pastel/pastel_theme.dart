import 'package:flutter/widgets.dart';

import '../../theme/ui_color_scheme.dart';
import '../../theme/ui_spacing.dart';
import '../../theme/ui_theme_data.dart';
import '../../theme/ui_typography.dart';

/// Pastel/Soft design preset -- gentle, warm, approachable.
///
/// Muted, desaturated colors with generous rounding and soft shadows.
/// Ideal for wellness, education, and consumer-facing apps.
abstract final class PastelTheme {
  static final dark = UiThemeData(
    name: 'Pastel Dark',
    colorScheme: const UiColorScheme(
      primary: Color(0xFFB4A0D8),
      onPrimary: Color(0xFF1A1028),
      secondary: Color(0xFFF4A0B0),
      onSecondary: Color(0xFF2A1018),
      surface: Color(0xFF2A2435),
      onSurface: Color(0xFFE8E0F0),
      background: Color(0xFF1A1525),
      onBackground: Color(0xFFE8E0F0),
      error: Color(0xFFE88090),
      onError: Color(0xFF2A1018),
      success: Color(0xFF80C8A0),
      onSuccess: Color(0xFF102818),
      warning: Color(0xFFE8C880),
      onWarning: Color(0xFF282010),
      border: Color(0xFF3D3550),
      shadow: Color(0x22000000),
    ),
    typography: UiTypography.fromFont(
      fontFamily: 'sans-serif',
      color: const Color(0xFFE8E0F0),
      baseWeight: FontWeight.w400,
    ),
    spacing: const UiSpacing(
      borderRadiusSm: 12.0,
      borderRadiusMd: 18.0,
      borderRadiusLg: 26.0,
      borderRadiusXl: 34.0,
    ),
    useShadows: true,
    useGlow: false,
    borderWidth: 0.0,
    elevation: 2.0,
    animationDuration: const Duration(milliseconds: 350),
    animationCurve: Curves.easeOutQuart,
  );

  static final light = UiThemeData(
    name: 'Pastel Light',
    colorScheme: const UiColorScheme(
      primary: Color(0xFF9B7FCC),
      onPrimary: Color(0xFFFFFFFF),
      secondary: Color(0xFFE87890),
      onSecondary: Color(0xFFFFFFFF),
      surface: Color(0xFFFFFFFF),
      onSurface: Color(0xFF3D3550),
      background: Color(0xFFF8F4FF),
      onBackground: Color(0xFF3D3550),
      error: Color(0xFFE06878),
      onError: Color(0xFFFFFFFF),
      success: Color(0xFF5FB888),
      onSuccess: Color(0xFFFFFFFF),
      warning: Color(0xFFE0B060),
      onWarning: Color(0xFFFFFFFF),
      border: Color(0xFFE8E0F0),
      shadow: Color(0x11000000),
    ),
    typography: UiTypography.fromFont(
      fontFamily: 'sans-serif',
      color: const Color(0xFF3D3550),
      baseWeight: FontWeight.w400,
    ),
    spacing: const UiSpacing(
      borderRadiusSm: 12.0,
      borderRadiusMd: 18.0,
      borderRadiusLg: 26.0,
      borderRadiusXl: 34.0,
    ),
    useShadows: true,
    useGlow: false,
    borderWidth: 0.0,
    elevation: 2.0,
    animationDuration: const Duration(milliseconds: 350),
    animationCurve: Curves.easeOutQuart,
  );
}
