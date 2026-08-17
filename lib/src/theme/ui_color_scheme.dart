import 'dart:ui';

/// Defines the color palette for a [UiThemeData].
///
/// All UI components resolve their colors from this scheme,
/// making it the single source of truth for the visual identity.
class UiColorScheme {
  const UiColorScheme({
    required this.primary,
    required this.onPrimary,
    required this.secondary,
    required this.onSecondary,
    required this.surface,
    required this.onSurface,
    required this.background,
    required this.onBackground,
    required this.error,
    required this.onError,
    required this.success,
    required this.onSuccess,
    required this.warning,
    required this.onWarning,
    required this.border,
    required this.shadow,
    this.glow,
    this.gradient,
    this.canvas,
    this.surfaceRaised,
    this.surfaceOverlay,
    this.onSurfaceMuted,
    this.onSurfaceSubtle,
  });

  final Color primary;
  final Color onPrimary;
  final Color secondary;
  final Color onSecondary;
  final Color surface;
  final Color onSurface;
  final Color background;
  final Color onBackground;
  final Color error;
  final Color onError;
  final Color success;
  final Color onSuccess;
  final Color warning;
  final Color onWarning;
  final Color border;
  final Color shadow;

  /// Optional glow color for neon/cyberpunk styles.
  final Color? glow;

  /// Optional gradient colors for advanced designs.
  final List<Color>? gradient;

  /// Optional semantic surface levels. Each falls back to the legacy palette.
  final Color? canvas;
  final Color? surfaceRaised;
  final Color? surfaceOverlay;
  final Color? onSurfaceMuted;
  final Color? onSurfaceSubtle;

  Color get resolvedCanvas => canvas ?? background;
  Color get resolvedSurfaceRaised => surfaceRaised ?? surface;
  Color get resolvedSurfaceOverlay => surfaceOverlay ?? surface;
  Color get resolvedOnSurfaceMuted =>
      onSurfaceMuted ?? onSurface.withValues(alpha: 0.62);
  Color get resolvedOnSurfaceSubtle =>
      onSurfaceSubtle ?? onSurface.withValues(alpha: 0.42);
  Color get resolvedBorderSubtle => border.withValues(alpha: 0.3);

  UiColorScheme copyWith({
    Color? primary,
    Color? onPrimary,
    Color? secondary,
    Color? onSecondary,
    Color? surface,
    Color? onSurface,
    Color? background,
    Color? onBackground,
    Color? error,
    Color? onError,
    Color? success,
    Color? onSuccess,
    Color? warning,
    Color? onWarning,
    Color? border,
    Color? shadow,
    Color? glow,
    List<Color>? gradient,
    Color? canvas,
    Color? surfaceRaised,
    Color? surfaceOverlay,
    Color? onSurfaceMuted,
    Color? onSurfaceSubtle,
  }) {
    return UiColorScheme(
      primary: primary ?? this.primary,
      onPrimary: onPrimary ?? this.onPrimary,
      secondary: secondary ?? this.secondary,
      onSecondary: onSecondary ?? this.onSecondary,
      surface: surface ?? this.surface,
      onSurface: onSurface ?? this.onSurface,
      background: background ?? this.background,
      onBackground: onBackground ?? this.onBackground,
      error: error ?? this.error,
      onError: onError ?? this.onError,
      success: success ?? this.success,
      onSuccess: onSuccess ?? this.onSuccess,
      warning: warning ?? this.warning,
      onWarning: onWarning ?? this.onWarning,
      border: border ?? this.border,
      shadow: shadow ?? this.shadow,
      glow: glow ?? this.glow,
      gradient: gradient ?? this.gradient,
      canvas: canvas ?? this.canvas,
      surfaceRaised: surfaceRaised ?? this.surfaceRaised,
      surfaceOverlay: surfaceOverlay ?? this.surfaceOverlay,
      onSurfaceMuted: onSurfaceMuted ?? this.onSurfaceMuted,
      onSurfaceSubtle: onSurfaceSubtle ?? this.onSurfaceSubtle,
    );
  }
}
