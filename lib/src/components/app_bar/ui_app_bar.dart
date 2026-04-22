import 'package:flutter/widgets.dart';

import '../../theme/ui_theme.dart';

/// A themed top navigation bar.
///
/// Fully custom, independent of Material's AppBar.
///
/// ```dart
/// UiAppBar(
///   title: Text('My App'),
///   leading: Icon(Icons.menu),
///   actions: [Icon(Icons.settings)],
/// )
/// ```
class UiAppBar extends StatelessWidget {
  const UiAppBar({
    super.key,
    this.title,
    this.leading,
    this.actions,
    this.height = 56.0,
    this.backgroundColor,
    this.showBorder = true,
  });

  final Widget? title;
  final Widget? leading;
  final List<Widget>? actions;
  final double height;
  final Color? backgroundColor;
  final bool showBorder;

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final colors = theme.colorScheme;
    final spacing = theme.spacing;

    List<BoxShadow>? shadows;
    if (theme.useShadows) {
      shadows = [
        BoxShadow(
          color: colors.shadow.withValues(alpha: 0.1),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];
    }

    return Container(
      height: height,
      padding: EdgeInsets.symmetric(horizontal: spacing.md),
      decoration: BoxDecoration(
        color: backgroundColor ?? colors.surface,
        border: showBorder
            ? Border(bottom: BorderSide(color: colors.border, width: theme.borderWidth))
            : null,
        boxShadow: shadows,
      ),
      child: Row(
        children: [
          if (leading != null) ...[
            leading!,
            SizedBox(width: spacing.sm),
          ],
          if (title != null)
            Expanded(
              child: DefaultTextStyle(
                style: theme.typography.titleMedium.copyWith(
                  color: colors.onSurface,
                ),
                child: title!,
              ),
            )
          else
            const Spacer(),
          if (actions != null)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (int i = 0; i < actions!.length; i++) ...[
                  if (i > 0) SizedBox(width: spacing.xs),
                  actions![i],
                ],
              ],
            ),
        ],
      ),
    );
  }
}
