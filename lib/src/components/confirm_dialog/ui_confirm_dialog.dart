import 'package:flutter/widgets.dart';

import '../../theme/ui_theme.dart';

/// A one-liner themed confirmation dialog.
///
/// Use the static [show] method to present the dialog and get a result.
///
/// ```dart
/// final confirmed = await UiConfirmDialog.show(
///   context: context,
///   title: 'Delete item?',
///   message: 'This action cannot be undone.',
///   destructive: true,
/// );
/// ```
class UiConfirmDialog extends StatelessWidget {
  const UiConfirmDialog({
    super.key,
    required this.title,
    this.message,
    this.confirmLabel = 'Confirm',
    this.cancelLabel = 'Cancel',
    this.destructive = false,
  });

  final String title;
  final String? message;
  final String confirmLabel;
  final String cancelLabel;
  final bool destructive;

  /// Shows a confirm dialog and returns `true` if confirmed, `false` otherwise.
  static Future<bool> show({
    required BuildContext context,
    required String title,
    String? message,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    bool destructive = false,
  }) async {
    final theme = UiTheme.of(context);

    final result = await Navigator.of(context).push<bool>(
      PageRouteBuilder<bool>(
        opaque: false,
        barrierDismissible: true,
        barrierColor: const Color(0x88000000),
        transitionDuration: theme.animationDuration,
        reverseTransitionDuration: theme.animationDuration,
        pageBuilder: (context, animation, secondaryAnimation) {
          return UiConfirmDialog(
            title: title,
            message: message,
            confirmLabel: confirmLabel,
            cancelLabel: cancelLabel,
            destructive: destructive,
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.9, end: 1.0).animate(
                CurvedAnimation(
                    parent: animation, curve: theme.animationCurve),
              ),
              child: child,
            ),
          );
        },
      ),
    );

    return result ?? false;
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
        width: 380,
        margin: spacing.paddingLg,
        padding: spacing.paddingLg,
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
            Text(
              title,
              style: typo.titleLarge.copyWith(color: colors.onSurface),
            ),
            if (message != null) ...[
              SizedBox(height: spacing.sm),
              Text(
                message!,
                style: typo.bodyMedium.copyWith(
                  color: colors.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
            SizedBox(height: spacing.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _DialogButton(
                  label: cancelLabel,
                  onTap: () => Navigator.of(context).pop(false),
                  variant: _DialogButtonVariant.ghost,
                ),
                SizedBox(width: spacing.sm),
                _DialogButton(
                  label: confirmLabel,
                  onTap: () => Navigator.of(context).pop(true),
                  variant: destructive
                      ? _DialogButtonVariant.destructive
                      : _DialogButtonVariant.primary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

enum _DialogButtonVariant { primary, destructive, ghost }

class _DialogButton extends StatefulWidget {
  const _DialogButton({
    required this.label,
    required this.onTap,
    required this.variant,
  });

  final String label;
  final VoidCallback onTap;
  final _DialogButtonVariant variant;

  @override
  State<_DialogButton> createState() => _DialogButtonState();
}

class _DialogButtonState extends State<_DialogButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final colors = theme.colorScheme;
    final spacing = theme.spacing;
    final typo = theme.typography;

    final Color bgColor;
    final Color fgColor;

    switch (widget.variant) {
      case _DialogButtonVariant.primary:
        bgColor = _hovered
            ? colors.primary.withValues(alpha: 0.9)
            : colors.primary;
        fgColor = colors.onPrimary;
      case _DialogButtonVariant.destructive:
        bgColor = _hovered
            ? colors.error.withValues(alpha: 0.9)
            : colors.error;
        fgColor = colors.onError;
      case _DialogButtonVariant.ghost:
        bgColor = _hovered
            ? colors.onSurface.withValues(alpha: 0.08)
            : const Color(0x00000000);
        fgColor = colors.onSurface;
    }

    List<BoxShadow>? shadows;
    if (widget.variant != _DialogButtonVariant.ghost &&
        theme.useGlow &&
        colors.glow != null) {
      final glowBase = widget.variant == _DialogButtonVariant.destructive
          ? colors.error
          : colors.glow!;
      shadows = [
        BoxShadow(
          color: glowBase.withValues(alpha: _hovered ? 0.5 : 0.3),
          blurRadius: _hovered ? 12 : 8,
        ),
      ];
    }

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: theme.animationDuration,
          curve: theme.animationCurve,
          padding: EdgeInsets.symmetric(
            vertical: spacing.sm,
            horizontal: spacing.md,
          ),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: spacing.radiusMd,
            boxShadow: shadows,
          ),
          child: Text(
            widget.label,
            style: typo.labelMedium.copyWith(color: fgColor),
          ),
        ),
      ),
    );
  }
}
