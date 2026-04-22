import 'package:flutter/widgets.dart';

import '../../theme/ui_theme.dart';
import '../../theme/ui_theme_data.dart';

/// The root widget for apps using flutter_ui_collection.
///
/// [UiApp] replaces `MaterialApp` / `CupertinoApp`. It sets up:
/// - [UiTheme] for the entire widget tree
/// - [Navigator] for routing (dialogs, drawers, page navigation)
/// - [Overlay] for toasts, tooltips, dropdowns
/// - [MediaQuery] for responsive layouts
/// - [DefaultTextStyle] from the theme
/// - Keyboard/focus management
///
/// ```dart
/// void main() {
///   runApp(UiApp(
///     theme: NeonTheme.dark,
///     home: MyHomePage(),
///   ));
/// }
/// ```
class UiApp extends StatelessWidget {
  const UiApp({
    super.key,
    required this.theme,
    this.darkTheme,
    this.home,
    this.title = '',
    this.routes = const {},
    this.initialRoute,
    this.onGenerateRoute,
    this.onUnknownRoute,
    this.navigatorKey,
    this.navigatorObservers = const [],
    this.debugShowCheckedModeBanner = true,
    this.textDirection = TextDirection.ltr,
  });

  /// The theme to use. If [darkTheme] is also provided, this is used
  /// as the light theme and the system brightness determines which is active.
  final UiThemeData theme;

  /// Optional dark theme. When provided, the app automatically switches
  /// between [theme] (light) and [darkTheme] (dark) based on platform brightness.
  final UiThemeData? darkTheme;

  final Widget? home;
  final String title;
  final Map<String, WidgetBuilder> routes;
  final String? initialRoute;
  final RouteFactory? onGenerateRoute;
  final RouteFactory? onUnknownRoute;
  final GlobalKey<NavigatorState>? navigatorKey;
  final List<NavigatorObserver> navigatorObservers;
  final bool debugShowCheckedModeBanner;
  final TextDirection textDirection;

  @override
  Widget build(BuildContext context) {
    return WidgetsApp(
      title: title,
      color: theme.colorScheme.primary,
      debugShowCheckedModeBanner: debugShowCheckedModeBanner,
      home: home,
      routes: routes,
      initialRoute: home == null ? (initialRoute ?? '/') : null,
      onGenerateRoute: onGenerateRoute,
      onUnknownRoute: onUnknownRoute,
      navigatorKey: navigatorKey,
      navigatorObservers: navigatorObservers,
      pageRouteBuilder: <T>(RouteSettings settings, WidgetBuilder builder) {
        return PageRouteBuilder<T>(
          settings: settings,
          pageBuilder: (context, animation, secondaryAnimation) =>
              builder(context),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        );
      },
      builder: (context, navigator) {
        // Resolve theme based on platform brightness
        final resolvedTheme = _resolveTheme(context);

        return Directionality(
          textDirection: textDirection,
          child: UiTheme(
            data: resolvedTheme,
            child: DefaultTextStyle(
              style: resolvedTheme.typography.bodyMedium.copyWith(
                color: resolvedTheme.colorScheme.onBackground,
              ),
              child: ColoredBox(
                color: resolvedTheme.colorScheme.background,
                child: navigator ?? const SizedBox.shrink(),
              ),
            ),
          ),
        );
      },
    );
  }

  UiThemeData _resolveTheme(BuildContext context) {
    if (darkTheme == null) return theme;

    final brightness = MediaQuery.platformBrightnessOf(context);
    return brightness == Brightness.dark ? darkTheme! : theme;
  }
}
