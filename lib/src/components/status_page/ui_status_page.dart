import 'package:flutter/widgets.dart';

import '../../theme/ui_theme.dart';

/// The type of status to display.
enum UiStatusType {
  success,
  error,
  notFound,
  maintenance,
}

/// A full-page status display with an icon, title, description, and
/// optional action widget.
///
/// ```dart
/// UiStatusPage(
///   type: UiStatusType.notFound,
///   title: 'Page not found',
///   description: 'The page you are looking for does not exist.',
///   action: UiButton(label: 'Go home', onPressed: () {}),
/// )
/// ```
class UiStatusPage extends StatelessWidget {
  const UiStatusPage({
    super.key,
    required this.type,
    required this.title,
    this.description,
    this.action,
    this.icon,
  });

  /// The status type, which determines the default icon and color.
  final UiStatusType type;

  /// The main title text.
  final String title;

  /// An optional description shown below the title.
  final String? description;

  /// An optional action widget (e.g. a button) shown below the description.
  final Widget? action;

  /// Override the default icon for the status type.
  final IconData? icon;

  /// Default icon per status type (MaterialIcons codepoints).
  IconData get _defaultIcon {
    switch (type) {
      case UiStatusType.success:
        // check_circle
        return const IconData(0xe159, fontFamily: 'MaterialIcons');
      case UiStatusType.error:
        // error_outline
        return const IconData(0xe1f6, fontFamily: 'MaterialIcons');
      case UiStatusType.notFound:
        // search_off
        return const IconData(0xf1f3, fontFamily: 'MaterialIcons');
      case UiStatusType.maintenance:
        // build
        return const IconData(0xe0ce, fontFamily: 'MaterialIcons');
    }
  }

  Color _iconColor(UiStatusType type, _StatusColors c) {
    switch (type) {
      case UiStatusType.success:
        return c.success;
      case UiStatusType.error:
        return c.error;
      case UiStatusType.notFound:
        return c.warning;
      case UiStatusType.maintenance:
        return c.secondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final colors = theme.colorScheme;
    final spacing = theme.spacing;
    final typo = theme.typography;

    final statusColors = _StatusColors(
      success: colors.success,
      error: colors.error,
      warning: colors.warning,
      secondary: colors.secondary,
    );

    final effectiveIcon = icon ?? _defaultIcon;
    final color = _iconColor(type, statusColors);

    List<BoxShadow>? glow;
    if (theme.useGlow && colors.glow != null) {
      glow = [
        BoxShadow(
          color: color.withValues(alpha: 0.3),
          blurRadius: 24,
          spreadRadius: 4,
        ),
      ];
    }

    return Center(
      child: Padding(
        padding: spacing.paddingLg,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: glow != null
                  ? BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: glow,
                    )
                  : null,
              child: Icon(
                effectiveIcon,
                size: 72,
                color: color,
              ),
            ),
            SizedBox(height: spacing.lg),
            Text(
              title,
              style: typo.headlineMedium.copyWith(color: colors.onBackground),
              textAlign: TextAlign.center,
            ),
            if (description != null) ...[
              SizedBox(height: spacing.sm),
              Text(
                description!,
                style: typo.bodyMedium.copyWith(
                  color: colors.onBackground.withValues(alpha: 0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[
              SizedBox(height: spacing.xl),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Helper to hold resolved status colors without repeating the switch.
class _StatusColors {
  const _StatusColors({
    required this.success,
    required this.error,
    required this.warning,
    required this.secondary,
  });

  final Color success;
  final Color error;
  final Color warning;
  final Color secondary;
}
