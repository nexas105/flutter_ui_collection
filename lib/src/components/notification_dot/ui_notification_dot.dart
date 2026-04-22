import 'package:flutter/widgets.dart';

import '../../theme/ui_theme.dart';

/// Wraps a child (typically an icon) with a notification badge dot or count.
///
/// ```dart
/// UiNotificationDot(
///   count: 5,
///   child: UiIcon(UiIcons.notifications),
/// )
///
/// UiNotificationDot(
///   show: hasNew,  // dot-only mode
///   child: UiIcon(UiIcons.email),
/// )
/// ```
class UiNotificationDot extends StatelessWidget {
  const UiNotificationDot({
    super.key,
    required this.child,
    this.count,
    this.show = true,
    this.color,
    this.size = 18.0,
    this.offset = const Offset(0, 0),
  });

  final Widget child;

  /// If set, shows the count. If null and [show] is true, shows a simple dot.
  final int? count;

  /// Whether to show the indicator.
  final bool show;

  /// Badge color. Defaults to theme's error color.
  final Color? color;

  /// Badge size (for count). Dot mode uses size * 0.5.
  final double size;

  /// Position offset from top-right.
  final Offset offset;

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final colors = theme.colorScheme;
    final typo = theme.typography;
    final badgeColor = color ?? colors.error;

    if (!show && (count == null || count! <= 0)) return child;

    final showCount = count != null && count! > 0;
    final dotSize = showCount ? size : size * 0.45;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          right: -dotSize / 3 + offset.dx,
          top: -dotSize / 3 + offset.dy,
          child: Container(
            height: dotSize,
            constraints: BoxConstraints(minWidth: dotSize),
            padding: showCount
                ? const EdgeInsets.symmetric(horizontal: 4)
                : EdgeInsets.zero,
            decoration: BoxDecoration(
              color: badgeColor,
              borderRadius: BorderRadius.circular(dotSize / 2),
              border: Border.all(color: colors.surface, width: 1.5),
            ),
            alignment: Alignment.center,
            child: showCount
                ? Text(
                    count! > 99 ? '99+' : '$count',
                    style: typo.labelSmall.copyWith(
                      color: colors.onError,
                      fontSize: dotSize * 0.55,
                      height: 1.0,
                    ),
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
