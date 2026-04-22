import 'package:flutter/widgets.dart';

import '../../theme/ui_theme.dart';

/// A themed modal dialog.
///
/// Use [UiDialog.show] to present a dialog as an overlay.
///
/// ```dart
/// UiDialog.show(
///   context: context,
///   builder: (context) => UiDialog(
///     title: 'Confirm',
///     content: Text('Are you sure?'),
///     actions: [
///       UiButton(label: 'Cancel', variant: UiButtonVariant.ghost, onPressed: () => Navigator.pop(context)),
///       UiButton(label: 'OK', onPressed: () => Navigator.pop(context, true)),
///     ],
///   ),
/// );
/// ```
class UiDialog extends StatelessWidget {
  const UiDialog({
    super.key,
    this.title,
    this.content,
    this.actions,
    this.width,
    this.padding,
    this.showCloseButton = false,
    this.onClose,
  });

  final String? title;
  final Widget? content;
  final List<Widget>? actions;
  final double? width;
  final EdgeInsets? padding;
  final bool showCloseButton;
  final VoidCallback? onClose;

  /// Shows this dialog as a modal overlay.
  ///
  /// Returns a [Future] that completes with the value passed to
  /// [Navigator.pop] when the dialog is dismissed.
  static Future<T?> show<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    bool barrierDismissible = true,
  }) {
    final theme = UiTheme.of(context);

    return Navigator.of(context).push<T>(
      PageRouteBuilder<T>(
        opaque: false,
        barrierDismissible: barrierDismissible,
        barrierColor: const Color(0x88000000),
        transitionDuration: theme.animationDuration,
        reverseTransitionDuration: theme.animationDuration,
        pageBuilder: (context, animation, secondaryAnimation) {
          return builder(context);
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.9, end: 1.0).animate(
                CurvedAnimation(parent: animation, curve: theme.animationCurve),
              ),
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final colors = theme.colorScheme;
    final spacing = theme.spacing;
    final typo = theme.typography;

    List<BoxShadow>? shadows;
    if (theme.useGlow && colors.glow != null) {
      shadows = [
        BoxShadow(
          color: colors.glow!.withValues(alpha: 0.2),
          blurRadius: 24,
          spreadRadius: 2,
        ),
      ];
    } else if (theme.useShadows) {
      shadows = [
        BoxShadow(
          color: colors.shadow,
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ];
    }

    return Center(
      child: Container(
        width: width ?? 400,
        margin: spacing.paddingLg,
        padding: padding ?? spacing.paddingLg,
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: spacing.radiusLg,
          border: Border.all(color: colors.border, width: theme.borderWidth),
          boxShadow: shadows,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (title != null || showCloseButton)
              Row(
                children: [
                  if (title != null)
                    Expanded(
                      child: Text(
                        title!,
                        style: typo.titleLarge.copyWith(color: colors.onSurface),
                      ),
                    ),
                  if (showCloseButton)
                    GestureDetector(
                      onTap: onClose ?? () => Navigator.of(context).pop(),
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: Padding(
                          padding: EdgeInsets.all(spacing.xs),
                          child: Text(
                            '\u2715',
                            style: typo.titleMedium.copyWith(
                              color: colors.onSurface.withValues(alpha: 0.5),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            if (title != null && content != null)
              SizedBox(height: spacing.md),
            if (content != null)
              DefaultTextStyle(
                style: typo.bodyMedium.copyWith(color: colors.onSurface),
                child: content!,
              ),
            if (actions != null && actions!.isNotEmpty) ...[
              SizedBox(height: spacing.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  for (int i = 0; i < actions!.length; i++) ...[
                    if (i > 0) SizedBox(width: spacing.sm),
                    actions![i],
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
