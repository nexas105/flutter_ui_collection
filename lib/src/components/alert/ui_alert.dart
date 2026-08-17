import 'package:flutter/widgets.dart';

import '../../icons/ui_icons.dart';
import '../../theme/ui_theme.dart';

/// Alert severity determines color and icon.
enum UiAlertType { info, success, warning, error }

/// A themed inline alert banner.
///
/// Unlike [UiToast] which is an overlay, [UiAlert] is an inline widget
/// that sits in the normal widget tree.
///
/// ```dart
/// UiAlert(
///   type: UiAlertType.warning,
///   title: 'Attention',
///   message: 'Your subscription expires in 3 days.',
///   onDismiss: () {},
/// )
/// ```
class UiAlert extends StatelessWidget {
  const UiAlert({
    super.key,
    this.type = UiAlertType.info,
    this.title,
    required this.message,
    this.onDismiss,
    this.action,
  });

  final UiAlertType type;
  final String? title;
  final String message;

  /// If set, shows a close button.
  final VoidCallback? onDismiss;

  /// Optional action widget (e.g. a text button).
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final colors = theme.colorScheme;
    final spacing = theme.spacing;
    final typo = theme.typography;

    final Color accentColor;
    final IconData icon;
    switch (type) {
      case UiAlertType.info:
        accentColor = colors.primary;
        icon = UiIcons.info;
      case UiAlertType.success:
        accentColor = colors.success;
        icon = UiIcons.check;
      case UiAlertType.warning:
        accentColor = colors.warning;
        icon = UiIcons.warning;
      case UiAlertType.error:
        accentColor = colors.error;
        icon = UiIcons.error;
    }

    return Container(
      padding: EdgeInsets.all(spacing.md),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.08),
        borderRadius: spacing.radiusMd,
        border: Border.all(
          color: accentColor.withValues(alpha: 0.3),
          width: theme.borderWidth,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: accentColor),
          SizedBox(width: spacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (title != null)
                  Padding(
                    padding: EdgeInsets.only(bottom: spacing.xs),
                    child: Text(
                      title!,
                      style: typo.titleSmall.copyWith(color: accentColor),
                    ),
                  ),
                Text(
                  message,
                  style: typo.bodyMedium.copyWith(color: colors.onSurface),
                ),
                if (action != null)
                  Padding(
                    padding: EdgeInsets.only(top: spacing.sm),
                    child: action!,
                  ),
              ],
            ),
          ),
          if (onDismiss != null)
            GestureDetector(
              onTap: onDismiss,
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Padding(
                  padding: EdgeInsets.only(left: spacing.sm),
                  child: Icon(
                    UiIcons.close,
                    size: 16,
                    color: colors.onSurface.withValues(alpha: 0.4),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
