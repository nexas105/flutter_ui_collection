import 'package:flutter/widgets.dart';

import '../theme/ui_theme.dart';

/// Text rendered with a gradient fill.
///
/// Uses the theme's gradient colors by default, or custom colors.
///
/// ```dart
/// UiGradientText(
///   'Hello World',
///   style: theme.typography.displayLarge,
/// )
/// ```
class UiGradientText extends StatelessWidget {
  const UiGradientText(
    this.text, {
    super.key,
    this.style,
    this.colors,
    this.begin = Alignment.centerLeft,
    this.end = Alignment.centerRight,
  });

  final String text;
  final TextStyle? style;

  /// Gradient colors. Defaults to theme's gradient or [primary, secondary].
  final List<Color>? colors;

  final Alignment begin;
  final Alignment end;

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final resolvedStyle = style ??
        theme.typography.headlineLarge.copyWith(
          color: theme.colorScheme.onBackground,
        );

    final resolvedColors = colors ??
        theme.colorScheme.gradient ??
        [theme.colorScheme.primary, theme.colorScheme.secondary];

    return ShaderMask(
      shaderCallback: (bounds) {
        return LinearGradient(
          begin: begin,
          end: end,
          colors: resolvedColors,
        ).createShader(bounds);
      },
      blendMode: BlendMode.srcIn,
      child: Text(text, style: resolvedStyle),
    );
  }
}
