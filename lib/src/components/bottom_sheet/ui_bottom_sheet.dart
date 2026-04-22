import 'package:flutter/widgets.dart';

import '../../theme/ui_theme.dart';

/// A themed bottom sheet that slides up from the bottom.
///
/// ```dart
/// UiBottomSheet.show(
///   context: context,
///   builder: (context) => UiBottomSheet(
///     title: 'Options',
///     child: Column(children: [...]),
///   ),
/// );
/// ```
class UiBottomSheet extends StatelessWidget {
  const UiBottomSheet({
    super.key,
    this.title,
    required this.child,
    this.showHandle = true,
    this.padding,
    this.maxHeight,
  });

  final String? title;
  final Widget child;
  final bool showHandle;
  final EdgeInsets? padding;

  /// Maximum height as fraction of screen height (0.0 - 1.0).
  final double? maxHeight;

  /// Shows a bottom sheet as a modal overlay.
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
    final typo = theme.typography;
    final mediaQuery = MediaQuery.of(context);

    final resolvedMaxHeight = maxHeight ?? 0.85;

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
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: mediaQuery.size.height * resolvedMaxHeight,
        ),
        child: Container(
          width: double.infinity,
          padding: padding ?? spacing.paddingLg,
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(spacing.borderRadiusXl),
              topRight: Radius.circular(spacing.borderRadiusXl),
            ),
            border: Border.all(color: colors.border, width: theme.borderWidth),
            boxShadow: shadows,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showHandle)
                Padding(
                  padding: EdgeInsets.only(bottom: spacing.md),
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colors.onSurface.withValues(alpha: 0.2),
                      borderRadius: spacing.radiusFull,
                    ),
                  ),
                ),
              if (title != null) ...[
                Text(
                  title!,
                  style: typo.titleLarge.copyWith(color: colors.onSurface),
                ),
                SizedBox(height: spacing.md),
              ],
              Flexible(child: child),
            ],
          ),
        ),
      ),
    );
  }
}
