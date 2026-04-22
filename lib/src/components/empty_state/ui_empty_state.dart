import 'package:flutter/widgets.dart';

import '../../theme/ui_theme.dart';

/// A themed empty state placeholder.
///
/// Shows when a list or page has no content. Includes optional icon,
/// title, description, and action button.
///
/// ```dart
/// UiEmptyState(
///   icon: UiIcons.folder,
///   title: 'No files yet',
///   description: 'Upload your first file to get started.',
///   action: UiButton(label: 'Upload', onPressed: () {}),
/// )
/// ```
class UiEmptyState extends StatelessWidget {
  const UiEmptyState({
    super.key,
    this.icon,
    this.title,
    this.description,
    this.action,
    this.compact = false,
  });

  final IconData? icon;
  final String? title;
  final String? description;

  /// Optional action widget (e.g. a UiButton).
  final Widget? action;

  /// Reduced padding for inline use.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final colors = theme.colorScheme;
    final spacing = theme.spacing;
    final typo = theme.typography;

    return Padding(
      padding: compact ? spacing.paddingMd : spacing.paddingLg,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: compact ? 40 : 56,
              color: colors.onSurface.withValues(alpha: 0.2),
            ),
            SizedBox(height: spacing.md),
          ],
          if (title != null) ...[
            Text(
              title!,
              style: (compact ? typo.titleMedium : typo.titleLarge).copyWith(
                color: colors.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: spacing.xs),
          ],
          if (description != null) ...[
            Text(
              description!,
              style: typo.bodyMedium.copyWith(
                color: colors.onSurface.withValues(alpha: 0.4),
              ),
              textAlign: TextAlign.center,
            ),
          ],
          if (action != null) ...[
            SizedBox(height: spacing.lg),
            action!,
          ],
        ],
      ),
    );
  }
}
