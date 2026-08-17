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
    this.description,
    this.navigation,
    this.leading,
    this.actions = const [],
    this.maxContentWidth,
  });

  /// The sections to display in the scrollable area.
  final List<Widget> sections;

  /// Title displayed in the app bar.
  final String title;

  /// Whether to show the top app bar.
  final bool showAppBar;
  final String? description;

  /// Optional navigation pane shown beside the settings on wide viewports.
  final Widget? navigation;
  final Widget? leading;
  final List<Widget> actions;
  final double? maxContentWidth;

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final colors = theme.colorScheme;
    final spacing = theme.spacing;
    final typo = theme.typography;

    final header = showAppBar
        ? Container(
            constraints: const BoxConstraints(minHeight: 96),
            padding: EdgeInsets.symmetric(
              horizontal: spacing.lg,
              vertical: spacing.md,
            ),
            child: Row(
              children: [
                if (leading != null) ...[leading!, SizedBox(width: spacing.md)],
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: typo.headlineSmall.copyWith(
                          color: colors.onBackground,
                        ),
                      ),
                      if (description != null) ...[
                        SizedBox(height: spacing.xs),
                        Text(
                          description!,
                          style: typo.bodyMedium.copyWith(
                            color: colors.resolvedOnSurfaceMuted,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                for (final action in actions) ...[
                  SizedBox(width: spacing.sm),
                  action,
                ],
              ],
            ),
          )
        : const SizedBox.shrink();

    Widget content() => SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        spacing.md,
        spacing.sm,
        spacing.md,
        spacing.xxl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: sections,
      ),
    );

    return ColoredBox(
      color: colors.resolvedCanvas,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 720 && navigation != null;
          final maxWidth = maxContentWidth ?? theme.components.contentMaxWidth;

          final body = wide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      width: 280,
                      child: ColoredBox(
                        color: colors.resolvedSurfaceRaised,
                        child: Padding(
                          padding: EdgeInsets.all(spacing.md),
                          child: navigation!,
                        ),
                      ),
                    ),
                    Container(width: theme.borderWidth, color: colors.border),
                    Expanded(child: content()),
                  ],
                )
              : content();

          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (showAppBar) header,
                  if (showAppBar)
                    Container(height: theme.borderWidth, color: colors.border),
                  Expanded(child: body),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
