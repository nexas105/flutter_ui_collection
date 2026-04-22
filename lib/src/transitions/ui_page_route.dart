import 'package:flutter/widgets.dart';

import '../theme/ui_theme.dart';

/// Themed page transition styles.
enum UiTransitionStyle {
  /// Fade in/out.
  fade,

  /// Slide from right (iOS-like).
  slideRight,

  /// Slide from bottom (modal-like).
  slideUp,

  /// Scale + fade (zoom in).
  scale,

  /// Slide + fade combined.
  slideFade,

  /// No animation (instant).
  none,
}

/// A themed page route with built-in transition animations.
///
/// Uses the active theme's animation duration and curve.
///
/// ```dart
/// Navigator.of(context).push(
///   UiPageRoute(
///     builder: (context) => DetailPage(),
///     style: UiTransitionStyle.slideRight,
///   ),
/// );
///
/// // Or use the shorthand:
/// UiPageRoute.push(context, builder: (ctx) => DetailPage());
/// ```
class UiPageRoute<T> extends PageRouteBuilder<T> {
  UiPageRoute({
    required WidgetBuilder builder,
    this.style = UiTransitionStyle.slideFade,
    super.settings,
    super.fullscreenDialog,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) =>
              builder(context),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return _UiTransitionBuilder(
              style: style,
              animation: animation,
              secondaryAnimation: secondaryAnimation,
              child: child,
            );
          },
        );

  final UiTransitionStyle style;

  @override
  Duration get transitionDuration {
    // Can't access theme here, use sensible default
    return const Duration(milliseconds: 300);
  }

  /// Convenience: push a new route with themed transitions.
  static Future<T?> push<T>(
    BuildContext context, {
    required WidgetBuilder builder,
    UiTransitionStyle style = UiTransitionStyle.slideFade,
    RouteSettings? settings,
    bool fullscreenDialog = false,
  }) {
    return Navigator.of(context).push<T>(
      UiPageRoute<T>(
        builder: builder,
        style: style,
        settings: settings,
        fullscreenDialog: fullscreenDialog,
      ),
    );
  }

  /// Convenience: push and replace current route.
  static Future<T?> pushReplacement<T, TO>(
    BuildContext context, {
    required WidgetBuilder builder,
    UiTransitionStyle style = UiTransitionStyle.slideFade,
  }) {
    return Navigator.of(context).pushReplacement<T, TO>(
      UiPageRoute<T>(builder: builder, style: style),
    );
  }
}

class _UiTransitionBuilder extends StatelessWidget {
  const _UiTransitionBuilder({
    required this.style,
    required this.animation,
    required this.secondaryAnimation,
    required this.child,
  });

  final UiTransitionStyle style;
  final Animation<double> animation;
  final Animation<double> secondaryAnimation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.maybeOf(context);
    final curve = theme?.animationCurve ?? Curves.easeInOut;

    final curved = CurvedAnimation(parent: animation, curve: curve);

    switch (style) {
      case UiTransitionStyle.fade:
        return FadeTransition(opacity: curved, child: child);

      case UiTransitionStyle.slideRight:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        );

      case UiTransitionStyle.slideUp:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        );

      case UiTransitionStyle.scale:
        return ScaleTransition(
          scale: Tween<double>(begin: 0.85, end: 1.0).animate(curved),
          child: FadeTransition(opacity: curved, child: child),
        );

      case UiTransitionStyle.slideFade:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.05, 0),
            end: Offset.zero,
          ).animate(curved),
          child: FadeTransition(opacity: curved, child: child),
        );

      case UiTransitionStyle.none:
        return child;
    }
  }
}
