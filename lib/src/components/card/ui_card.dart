import 'dart:ui';

import 'package:flutter/widgets.dart';

import '../../theme/ui_theme.dart';

/// A themed container surface.
///
/// Adapts its appearance (borders, shadows, glow, glassmorphism blur)
/// based on the active [UiThemeData].
///
/// ```dart
/// UiCard(
///   child: Text('Hello'),
/// )
/// ```
class UiCard extends StatelessWidget {
  const UiCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.color,
    this.onTap,
    this.blur = false,
  });

  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final BorderRadius? borderRadius;
  final Color? color;
  final VoidCallback? onTap;

  /// If true, applies a backdrop blur (glassmorphism effect).
  final bool blur;

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final colors = theme.colorScheme;
    final components = theme.components;

    final resolvedRadius = borderRadius ?? components.cardBorderRadius;
    final resolvedPadding = padding ?? EdgeInsets.all(components.cardPadding);
    final resolvedColor = color ?? colors.resolvedSurfaceRaised;

    List<BoxShadow>? shadows;
    if (theme.useGlow && colors.glow != null) {
      shadows = [
        BoxShadow(
          color: colors.glow!.withValues(alpha: 0.15),
          blurRadius: components.shadowBlur,
          offset: components.shadowOffset,
        ),
      ];
    } else if (theme.useShadows) {
      shadows = [
        BoxShadow(
          color: colors.shadow,
          blurRadius: components.shadowBlur,
          offset: components.shadowOffset,
        ),
      ];
    }

    Widget card = Container(
      margin: margin,
      padding: resolvedPadding,
      decoration: BoxDecoration(
        color: blur ? resolvedColor.withValues(alpha: 0.6) : resolvedColor,
        borderRadius: resolvedRadius,
        border: theme.useShadows || theme.useGlow
            ? null
            : Border.all(color: colors.border, width: theme.borderWidth),
        boxShadow: shadows,
      ),
      child: child,
    );

    if (blur) {
      card = ClipRRect(
        borderRadius: resolvedRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: card,
        ),
      );
    }

    if (onTap != null) {
      card = GestureDetector(onTap: onTap, child: card);
    }

    return card;
  }
}
