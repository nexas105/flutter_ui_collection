import 'package:flutter/widgets.dart';

import 'ui_theme.dart';
import 'ui_theme_data.dart';

/// Automatically switches between a dark and light [UiThemeData]
/// based on the platform brightness setting.
///
/// ```dart
/// UiThemeMode(
///   dark: NeonTheme.dark,
///   light: NeonTheme.light,
///   child: MyApp(),
/// )
/// ```
class UiThemeMode extends StatelessWidget {
  const UiThemeMode({
    super.key,
    required this.dark,
    required this.light,
    this.mode,
    required this.child,
  });

  /// The dark theme variant.
  final UiThemeData dark;

  /// The light theme variant.
  final UiThemeData light;

  /// Force a specific brightness. If null, follows the platform.
  final Brightness? mode;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final brightness = mode ?? MediaQuery.platformBrightnessOf(context);
    final data = brightness == Brightness.dark ? dark : light;

    return UiTheme(data: data, child: child);
  }
}
