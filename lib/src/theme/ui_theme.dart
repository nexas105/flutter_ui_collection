import 'package:flutter/widgets.dart';

import 'ui_theme_data.dart';

/// Provides a [UiThemeData] to all descendant widgets.
///
/// Wrap your app (or a subtree) with [UiTheme] to make the design tokens
/// available via `UiTheme.of(context)`.
///
/// ```dart
/// UiTheme(
///   data: NeonTheme.dark,
///   child: MyApp(),
/// )
/// ```
class UiTheme extends InheritedWidget {
  const UiTheme({super.key, required this.data, required super.child});

  /// The theme configuration for this subtree.
  final UiThemeData data;

  /// Returns the nearest [UiThemeData] above the given [context].
  ///
  /// Throws if no [UiTheme] is found in the widget tree.
  static UiThemeData of(BuildContext context) {
    final widget = context.dependOnInheritedWidgetOfExactType<UiTheme>();
    assert(
      widget != null,
      'No UiTheme found in the widget tree. '
      'Wrap your app with UiTheme(data: ..., child: ...).',
    );
    return widget!.data;
  }

  /// Returns the nearest [UiThemeData], or `null` if none is found.
  static UiThemeData? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<UiTheme>()?.data;
  }

  @override
  bool updateShouldNotify(UiTheme oldWidget) => data != oldWidget.data;
}
