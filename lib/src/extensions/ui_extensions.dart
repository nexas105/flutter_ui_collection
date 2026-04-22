import 'package:flutter/widgets.dart';

import '../theme/ui_theme.dart';
import '../theme/ui_theme_data.dart';

/// Convenience extension to access the [UiThemeData] directly from context.
///
/// ```dart
/// final colors = context.uiTheme.colorScheme;
/// ```
extension UiThemeContext on BuildContext {
  /// Returns the nearest [UiThemeData] from the widget tree.
  UiThemeData get uiTheme => UiTheme.of(this);

  /// Returns the nearest [UiThemeData], or null if not found.
  UiThemeData? get maybeUiTheme => UiTheme.maybeOf(this);
}
