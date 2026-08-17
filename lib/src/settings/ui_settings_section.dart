import 'package:flutter/widgets.dart';

import '../theme/ui_theme.dart';

/// A grouped section of settings with an optional header title.
///
/// Wraps its children in a themed card-like container with dividers
/// between each item, similar to iOS Settings sections.
///
/// ```dart
/// UiSettingsSection(
///   title: 'General',
///   children: [
///     UiSettingsToggle(...),
///     UiSettingsNavigation(...),
///   ],
/// )
/// ```
class UiSettingsSection extends StatelessWidget {
  const UiSettingsSection({
    super.key,
    this.title,
    required this.children,
    this.padding,
  });

  /// Optional section header displayed above the card.
  final String? title;

  /// The setting tiles within this section.
  final List<Widget> children;

  /// Outer padding around the entire section.
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final colors = theme.colorScheme;
    final spacing = theme.spacing;
    final typo = theme.typography;

    final resolvedPadding =
        padding ??
        EdgeInsets.symmetric(horizontal: spacing.md, vertical: spacing.sm);

    return Padding(
      padding: resolvedPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null) ...[
            Padding(
              padding: EdgeInsets.only(left: spacing.xs, bottom: spacing.sm),
              child: Text(
                title!,
                style: typo.titleSmall.copyWith(
                  color: colors.resolvedOnSurfaceMuted,
                ),
              ),
            ),
          ],
          Container(
            decoration: BoxDecoration(
              color: colors.resolvedSurfaceRaised,
              borderRadius: theme.components.cardBorderRadius,
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (int i = 0; i < children.length; i++) ...[
                  children[i],
                  if (i < children.length - 1)
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: spacing.md),
                      child: Container(
                        height: theme.borderWidth,
                        color: colors.border,
                      ),
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
