import 'package:flutter/widgets.dart';

import '../../theme/ui_color_scheme.dart';
import '../../theme/ui_component_tokens.dart';
import '../../theme/ui_icon_set.dart';
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
      canvas: Color(0xFF1A1525),
      surfaceRaised: Color(0xFF342D41),
      surfaceOverlay: Color(0xFF40374E),
      onSurfaceMuted: Color(0xFFAAA0B5),
    ),
    typography: UiTypography.fromFont(
      fontFamily: 'Trebuchet MS',
      fontFamilyFallback: const ['Segoe UI', 'Roboto'],
      color: const Color(0xFFE8E0F0),
      baseWeight: FontWeight.w400,
    ),
    spacing: const UiSpacing(
      borderRadiusSm: 12.0,
      borderRadiusMd: 18.0,
      borderRadiusLg: 26.0,
      borderRadiusXl: 34.0,
    ),
    components: const UiComponentTokens(
      controlHeightSmall: 40,
      controlHeightMedium: 48,
      controlHeightLarge: 56,
      controlRadius: 18,
      cardRadius: 26,
      cardPadding: 26,
      appBarHeight: 68,
      iconSizeSmall: 16,
      iconSizeMedium: 20,
      iconSizeLarge: 24,
      hoverOpacity: 0.08,
      pressedOpacity: 0.14,
      disabledOpacity: 0.46,
      focusRingWidth: 2,
      shadowBlur: 24,
      shadowOffset: Offset(0, 8),
      contentMaxWidth: 1080,
    ),
    icons: const UiIconSet(weight: 300, grade: -25, opticalSize: 22),
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
      canvas: Color(0xFFF8F4FF),
      surfaceRaised: Color(0xFFFFFFFF),
      surfaceOverlay: Color(0xFFF1EAF8),
      onSurfaceMuted: Color(0xFF756C82),
    ),
    typography: UiTypography.fromFont(
      fontFamily: 'Trebuchet MS',
      fontFamilyFallback: const ['Segoe UI', 'Roboto'],
      color: const Color(0xFF3D3550),
      baseWeight: FontWeight.w400,
    ),
    spacing: const UiSpacing(
      borderRadiusSm: 12.0,
      borderRadiusMd: 18.0,
      borderRadiusLg: 26.0,
      borderRadiusXl: 34.0,
    ),
    components: const UiComponentTokens(
      controlHeightSmall: 40,
      controlHeightMedium: 48,
      controlHeightLarge: 56,
      controlRadius: 18,
      cardRadius: 26,
      cardPadding: 26,
      appBarHeight: 68,
      iconSizeSmall: 16,
      iconSizeMedium: 20,
      iconSizeLarge: 24,
      hoverOpacity: 0.08,
      pressedOpacity: 0.14,
      disabledOpacity: 0.46,
      focusRingWidth: 2,
      shadowBlur: 24,
      shadowOffset: Offset(0, 8),
      contentMaxWidth: 1080,
    ),
    icons: const UiIconSet(weight: 300, grade: -25, opticalSize: 22),
    useShadows: true,
    useGlow: false,
    borderWidth: 0.0,
    elevation: 2.0,
    animationDuration: const Duration(milliseconds: 350),
    animationCurve: Curves.easeOutQuart,
  );
}
