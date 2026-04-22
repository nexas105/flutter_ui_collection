import 'package:flutter/widgets.dart';

import '../../theme/ui_theme.dart';

/// Displays a row of overlapping avatar widgets with an overflow indicator.
///
/// ```dart
/// UiAvatarGroup(
///   avatars: [
///     Image.network('https://i.pravatar.cc/150?img=1'),
///     Image.network('https://i.pravatar.cc/150?img=2'),
///     Image.network('https://i.pravatar.cc/150?img=3'),
///     Image.network('https://i.pravatar.cc/150?img=4'),
///   ],
///   maxVisible: 3,
/// )
/// ```
class UiAvatarGroup extends StatelessWidget {
  const UiAvatarGroup({
    super.key,
    required this.avatars,
    this.maxVisible = 3,
    this.overlap = 8.0,
    this.size = 36.0,
  });

  /// The avatar widgets to display.
  final List<Widget> avatars;

  /// Maximum number of avatars to show before the "+N" overflow indicator.
  final int maxVisible;

  /// How many pixels each avatar overlaps the previous one.
  final double overlap;

  /// The diameter of each avatar circle.
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final colors = theme.colorScheme;
    final typo = theme.typography;

    final visibleCount =
        avatars.length > maxVisible ? maxVisible : avatars.length;
    final overflowCount = avatars.length - visibleCount;
    final totalItems = visibleCount + (overflowCount > 0 ? 1 : 0);
    final step = size - overlap;
    final totalWidth = totalItems > 0 ? step * (totalItems - 1) + size : 0.0;

    return SizedBox(
      width: totalWidth,
      height: size,
      child: Stack(
        children: [
          for (int i = 0; i < visibleCount; i++)
            Positioned(
              left: i * step,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colors.surface,
                    width: 2.0,
                  ),
                ),
                child: ClipOval(
                  child: SizedBox(
                    width: size,
                    height: size,
                    child: avatars[i],
                  ),
                ),
              ),
            ),
          if (overflowCount > 0)
            Positioned(
              left: visibleCount * step,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: colors.surface,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colors.border,
                    width: theme.borderWidth,
                  ),
                ),
                child: Center(
                  child: Text(
                    '+$overflowCount',
                    style: typo.labelSmall.copyWith(
                      color: colors.onSurface,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
