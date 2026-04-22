import 'package:flutter/widgets.dart';

import '../theme/ui_theme.dart';

/// A complete settings page template with a scrollable list of sections.
///
/// Provides the standard layout for a settings screen, including an
/// optional app bar and scrollable content area.
///
/// ```dart
/// UiSettingsScreen(
///   title: 'Settings',
///   sections: [
///     UiSettingsSection(
///       title: 'Account',
///       children: [...],
///     ),
///     UiSettingsSection(
///       title: 'Preferences',
///       children: [...],
///     ),
///   ],
/// )
/// ```
class UiSettingsScreen extends StatelessWidget {
  const UiSettingsScreen({
    super.key,
    required this.sections,
    this.title = 'Settings',
    this.showAppBar = true,
  });

  /// The sections to display in the scrollable area.
  final List<Widget> sections;

  /// Title displayed in the app bar.
  final String title;

  /// Whether to show the top app bar.
  final bool showAppBar;

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final colors = theme.colorScheme;
    final spacing = theme.spacing;
    final typo = theme.typography;

    return Container(
      color: colors.background,
      child: Column(
        children: [
          if (showAppBar) ...[
            Container(
              height: 56,
              padding: EdgeInsets.symmetric(horizontal: spacing.md),
              decoration: BoxDecoration(
                color: colors.surface,
                border: Border(
                  bottom: BorderSide(
                    color: colors.border,
                    width: theme.borderWidth,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: typo.titleMedium.copyWith(
                        color: colors.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                top: spacing.sm,
                bottom: spacing.xl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: sections,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
