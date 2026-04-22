import 'package:flutter/widgets.dart';

import '../theme/ui_color_scheme.dart';
import '../theme/ui_theme.dart';
import '../theme/ui_theme_data.dart';
import '../theme/ui_spacing.dart';

/// Animates transitions between [UiThemeData] values.
///
/// Wrap your app with [AnimatedUiTheme] instead of [UiTheme]
/// to get smooth color, typography, and spacing transitions
/// when the theme changes.
///
/// ```dart
/// AnimatedUiTheme(
///   data: isDark ? NeonTheme.dark : NeonTheme.light,
///   duration: Duration(milliseconds: 300),
///   child: MyApp(),
/// )
/// ```
class AnimatedUiTheme extends StatefulWidget {
  const AnimatedUiTheme({
    super.key,
    required this.data,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
  });

  final UiThemeData data;
  final Widget child;
  final Duration duration;
  final Curve curve;

  @override
  State<AnimatedUiTheme> createState() => _AnimatedUiThemeState();
}

class _AnimatedUiThemeState extends State<AnimatedUiTheme>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late UiThemeData _oldTheme;
  late UiThemeData _newTheme;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _oldTheme = widget.data;
    _newTheme = widget.data;
  }

  @override
  void didUpdateWidget(AnimatedUiTheme oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data) {
      _oldTheme = oldWidget.data;
      _newTheme = widget.data;
      _controller.duration = widget.duration;
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: CurvedAnimation(parent: _controller, curve: widget.curve),
      builder: (context, child) {
        final t = _controller.value;
        final interpolated = _lerpTheme(_oldTheme, _newTheme, t);
        return UiTheme(data: interpolated, child: widget.child);
      },
    );
  }
}

UiThemeData _lerpTheme(UiThemeData a, UiThemeData b, double t) {
  if (t <= 0) return a;
  if (t >= 1) return b;

  return UiThemeData(
    name: b.name,
    colorScheme: _lerpColorScheme(a.colorScheme, b.colorScheme, t),
    typography: t < 0.5 ? a.typography : b.typography,
    spacing: _lerpSpacing(a.spacing, b.spacing, t),
    animationDuration: b.animationDuration,
    animationCurve: b.animationCurve,
    useShadows: b.useShadows,
    useGlow: b.useGlow,
    useGradients: b.useGradients,
    borderWidth: _lerpDouble(a.borderWidth, b.borderWidth, t),
    elevation: _lerpDouble(a.elevation, b.elevation, t),
  );
}

UiColorScheme _lerpColorScheme(UiColorScheme a, UiColorScheme b, double t) {
  return UiColorScheme(
    primary: Color.lerp(a.primary, b.primary, t)!,
    onPrimary: Color.lerp(a.onPrimary, b.onPrimary, t)!,
    secondary: Color.lerp(a.secondary, b.secondary, t)!,
    onSecondary: Color.lerp(a.onSecondary, b.onSecondary, t)!,
    surface: Color.lerp(a.surface, b.surface, t)!,
    onSurface: Color.lerp(a.onSurface, b.onSurface, t)!,
    background: Color.lerp(a.background, b.background, t)!,
    onBackground: Color.lerp(a.onBackground, b.onBackground, t)!,
    error: Color.lerp(a.error, b.error, t)!,
    onError: Color.lerp(a.onError, b.onError, t)!,
    success: Color.lerp(a.success, b.success, t)!,
    onSuccess: Color.lerp(a.onSuccess, b.onSuccess, t)!,
    warning: Color.lerp(a.warning, b.warning, t)!,
    onWarning: Color.lerp(a.onWarning, b.onWarning, t)!,
    border: Color.lerp(a.border, b.border, t)!,
    shadow: Color.lerp(a.shadow, b.shadow, t)!,
    glow: Color.lerp(a.glow, b.glow, t),
    gradient: b.gradient,
  );
}

UiSpacing _lerpSpacing(UiSpacing a, UiSpacing b, double t) {
  return UiSpacing(
    xs: _lerpDouble(a.xs, b.xs, t),
    sm: _lerpDouble(a.sm, b.sm, t),
    md: _lerpDouble(a.md, b.md, t),
    lg: _lerpDouble(a.lg, b.lg, t),
    xl: _lerpDouble(a.xl, b.xl, t),
    xxl: _lerpDouble(a.xxl, b.xxl, t),
    borderRadiusSm: _lerpDouble(a.borderRadiusSm, b.borderRadiusSm, t),
    borderRadiusMd: _lerpDouble(a.borderRadiusMd, b.borderRadiusMd, t),
    borderRadiusLg: _lerpDouble(a.borderRadiusLg, b.borderRadiusLg, t),
    borderRadiusXl: _lerpDouble(a.borderRadiusXl, b.borderRadiusXl, t),
    borderRadiusFull: _lerpDouble(a.borderRadiusFull, b.borderRadiusFull, t),
  );
}

double _lerpDouble(double a, double b, double t) => a + (b - a) * t;
