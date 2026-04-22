import 'package:flutter/widgets.dart';

import '../theme/ui_theme.dart';

/// A themed hero widget for shared-element transitions between routes.
///
/// Wraps Flutter's [Hero] with theme-aware flight animations --
/// adds glow trails, color morphing, and smooth size transitions.
///
/// ```dart
/// // On page A:
/// UiHero(
///   tag: 'avatar-1',
///   child: UiAvatar(initials: 'TL'),
/// )
///
/// // On page B (same tag):
/// UiHero(
///   tag: 'avatar-1',
///   child: UiAvatar(initials: 'TL', size: UiAvatarSize.large),
/// )
/// ```
class UiHero extends StatelessWidget {
  const UiHero({
    super.key,
    required this.tag,
    required this.child,
    this.flightStyle = UiHeroFlightStyle.standard,
    this.placeholderBuilder,
  });

  /// Unique tag that matches heroes across routes.
  final Object tag;

  final Widget child;

  /// The flight animation style.
  final UiHeroFlightStyle flightStyle;

  /// Widget shown in the original position during flight.
  final Widget Function(BuildContext, Size, Widget)? placeholderBuilder;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: tag,
      flightShuttleBuilder: _buildFlightShuttle,
      placeholderBuilder: placeholderBuilder != null
          ? (context, size, child) => placeholderBuilder!(context, size, child)
          : null,
      child: child,
    );
  }

  Widget _buildFlightShuttle(
    BuildContext flightContext,
    Animation<double> animation,
    HeroFlightDirection direction,
    BuildContext fromContext,
    BuildContext toContext,
  ) {
    final theme = UiTheme.maybeOf(toContext) ?? UiTheme.maybeOf(fromContext);

    switch (flightStyle) {
      case UiHeroFlightStyle.standard:
        final destHero = toContext.widget;
        final destChild = destHero is Hero ? destHero.child : child;
        return destChild;

      case UiHeroFlightStyle.glow:
        return AnimatedBuilder(
          animation: animation,
          builder: (context, _) {
            final glowColor = theme?.colorScheme.glow ??
                theme?.colorScheme.primary ??
                const Color(0xFF00F0FF);
            final glowIntensity = (1.0 - (animation.value - 0.5).abs() * 2)
                .clamp(0.0, 1.0);

            return Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: glowColor.withValues(alpha: glowIntensity * 0.6),
                    blurRadius: 24 * glowIntensity,
                    spreadRadius: 4 * glowIntensity,
                  ),
                ],
              ),
              child: (toContext.widget as Hero).child,
            );
          },
        );

      case UiHeroFlightStyle.fade:
        final toHero = toContext.widget as Hero;
        final fromHero = fromContext.widget as Hero;
        return AnimatedBuilder(
          animation: animation,
          builder: (context, _) {
            return Stack(
              alignment: Alignment.center,
              children: [
                Opacity(
                  opacity: (1.0 - animation.value).clamp(0.0, 1.0),
                  child: fromHero.child,
                ),
                Opacity(
                  opacity: animation.value.clamp(0.0, 1.0),
                  child: toHero.child,
                ),
              ],
            );
          },
        );

      case UiHeroFlightStyle.scale:
        return AnimatedBuilder(
          animation: animation,
          builder: (context, _) {
            final scale = Tween<double>(begin: 0.8, end: 1.0)
                .chain(CurveTween(
                    curve: theme?.animationCurve ?? Curves.easeOutCubic))
                .evaluate(animation);

            return Transform.scale(
              scale: scale,
              child: (toContext.widget as Hero).child,
            );
          },
        );
    }
  }
}

/// Flight animation styles for [UiHero].
enum UiHeroFlightStyle {
  /// Standard material-like flight.
  standard,

  /// Adds a glow trail during flight (best with neon/cyberpunk themes).
  glow,

  /// Cross-fades between source and destination.
  fade,

  /// Scales up during flight.
  scale,
}
