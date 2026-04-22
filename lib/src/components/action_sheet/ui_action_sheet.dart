import 'package:flutter/widgets.dart';

import '../../theme/ui_theme.dart';

/// Describes a single action in a [UiActionSheet].
class UiActionSheetItem {
  const UiActionSheetItem({
    required this.label,
    this.icon,
    this.destructive = false,
  });

  /// Display label for this action.
  final String label;

  /// Optional leading icon.
  final IconData? icon;

  /// If true, the item is styled with the error color.
  final bool destructive;
}

/// An iOS-style bottom action sheet.
///
/// Use the static [show] method to present the sheet and get a result.
///
/// ```dart
/// final index = await UiActionSheet.show(
///   context: context,
///   items: [
///     UiActionSheetItem(label: 'Edit', icon: someIcon),
///     UiActionSheetItem(label: 'Delete', icon: someIcon, destructive: true),
///   ],
/// );
/// ```
class UiActionSheet extends StatelessWidget {
  const UiActionSheet({
    super.key,
    required this.items,
    this.cancelLabel = 'Cancel',
  });

  final List<UiActionSheetItem> items;
  final String cancelLabel;

  /// Shows the action sheet and returns the selected item index, or null.
  static Future<int?> show({
    required BuildContext context,
    required List<UiActionSheetItem> items,
    String cancelLabel = 'Cancel',
  }) {
    final theme = UiTheme.of(context);

    return Navigator.of(context).push<int?>(
      PageRouteBuilder<int?>(
        opaque: false,
        barrierDismissible: true,
        barrierColor: const Color(0x88000000),
        transitionDuration: theme.animationDuration,
        reverseTransitionDuration: theme.animationDuration,
        pageBuilder: (context, animation, secondaryAnimation) {
          return UiActionSheet(
            items: items,
            cancelLabel: cancelLabel,
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: theme.animationCurve,
            )),
            child: child,
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
    List<BoxShadow>? shadows;
    if (theme.useGlow && colors.glow != null) {
      shadows = [
        BoxShadow(
          color: colors.glow!.withValues(alpha: 0.15),
          blurRadius: 20,
          offset: const Offset(0, -4),
        ),
      ];
    } else if (theme.useShadows) {
      shadows = [
        BoxShadow(
          color: colors.shadow,
          blurRadius: 20,
          offset: const Offset(0, -4),
        ),
      ];
    }

    return Align(
      alignment: Alignment.bottomCenter,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.all(spacing.sm),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Action items container
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: spacing.radiusLg,
                  border: Border.all(
                      color: colors.border, width: theme.borderWidth),
                  boxShadow: shadows,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (int i = 0; i < items.length; i++) ...[
                      if (i > 0)
                        Container(
                          height: theme.borderWidth,
                          color: colors.border,
                        ),
                      _ActionSheetRow(
                        item: items[i],
                        onTap: () => Navigator.of(context).pop(i),
                        isFirst: i == 0,
                        isLast: i == items.length - 1,
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(height: spacing.sm),
              // Cancel button
              _CancelButton(
                label: cancelLabel,
                onTap: () => Navigator.of(context).pop(null),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionSheetRow extends StatefulWidget {
  const _ActionSheetRow({
    required this.item,
    required this.onTap,
    required this.isFirst,
    required this.isLast,
  });

  final UiActionSheetItem item;
  final VoidCallback onTap;
  final bool isFirst;
  final bool isLast;

  @override
  State<_ActionSheetRow> createState() => _ActionSheetRowState();
}

class _ActionSheetRowState extends State<_ActionSheetRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final colors = theme.colorScheme;
    final spacing = theme.spacing;
    final typo = theme.typography;

    final fgColor =
        widget.item.destructive ? colors.error : colors.onSurface;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: theme.animationDuration,
          curve: theme.animationCurve,
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            vertical: spacing.md,
            horizontal: spacing.lg,
          ),
          decoration: BoxDecoration(
            color: _hovered
                ? colors.onSurface.withValues(alpha: 0.05)
                : const Color(0x00000000),
          ),
          child: Row(
            children: [
              if (widget.item.icon != null) ...[
                Icon(widget.item.icon, size: 20, color: fgColor),
                SizedBox(width: spacing.md),
              ],
              Expanded(
                child: Text(
                  widget.item.label,
                  style: typo.bodyLarge.copyWith(color: fgColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CancelButton extends StatefulWidget {
  const _CancelButton({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  State<_CancelButton> createState() => _CancelButtonState();
}

class _CancelButtonState extends State<_CancelButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final colors = theme.colorScheme;
    final spacing = theme.spacing;
    final typo = theme.typography;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: theme.animationDuration,
          curve: theme.animationCurve,
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            vertical: spacing.md,
            horizontal: spacing.lg,
          ),
          decoration: BoxDecoration(
            color: _hovered
                ? colors.onSurface.withValues(alpha: 0.05)
                : colors.surface,
            borderRadius: spacing.radiusLg,
            border: Border.all(
                color: colors.border, width: theme.borderWidth),
          ),
          alignment: Alignment.center,
          child: Text(
            widget.label,
            style: typo.labelLarge.copyWith(color: colors.onSurface),
          ),
        ),
      ),
    );
  }
}
