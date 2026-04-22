import 'package:flutter/widgets.dart';

import '../../theme/ui_theme.dart';

/// A themed drawer overlay that slides in from the side.
///
/// ```dart
/// UiDrawer.show(
///   context: context,
///   builder: (context) => UiDrawer(
///     child: UiSidebar(...),
///   ),
/// );
/// ```
class UiDrawer extends StatelessWidget {
  const UiDrawer({
    super.key,
    required this.child,
    this.width = 280,
    this.side = UiDrawerSide.left,
  });

  final Widget child;
  final double width;
  final UiDrawerSide side;

  /// Shows a drawer as an overlay.
  static Future<void> show({
    required BuildContext context,
    required WidgetBuilder builder,
    bool barrierDismissible = true,
  }) {
    final theme = UiTheme.of(context);

    return Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: barrierDismissible,
        barrierColor: const Color(0x88000000),
        transitionDuration: theme.animationDuration,
        reverseTransitionDuration: theme.animationDuration,
        pageBuilder: (context, animation, secondaryAnimation) {
          return builder(context);
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Determine slide direction from the UiDrawer if possible
          var begin = const Offset(-1, 0);
          if (child is UiDrawer && child.side == UiDrawerSide.right) {
            begin = const Offset(1, 0);
          }

          return SlideTransition(
            position: Tween<Offset>(begin: begin, end: Offset.zero).animate(
              CurvedAnimation(parent: animation, curve: theme.animationCurve),
            ),
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

    List<BoxShadow>? shadows;
    if (theme.useShadows) {
      shadows = [
        BoxShadow(
          color: colors.shadow,
          blurRadius: 24,
          offset: side == UiDrawerSide.left
              ? const Offset(4, 0)
              : const Offset(-4, 0),
        ),
      ];
    }

    return Align(
      alignment: side == UiDrawerSide.left
          ? Alignment.centerLeft
          : Alignment.centerRight,
      child: Container(
        width: width,
        height: double.infinity,
        decoration: BoxDecoration(
          color: colors.surface,
          border: Border(
            right: side == UiDrawerSide.left
                ? BorderSide(color: colors.border, width: theme.borderWidth)
                : BorderSide.none,
            left: side == UiDrawerSide.right
                ? BorderSide(color: colors.border, width: theme.borderWidth)
                : BorderSide.none,
          ),
          boxShadow: shadows,
        ),
        child: child,
      ),
    );
  }
}

/// Which side the drawer slides in from.
enum UiDrawerSide { left, right }
