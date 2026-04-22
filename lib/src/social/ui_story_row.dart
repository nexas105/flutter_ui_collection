import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../theme/ui_theme.dart';
import 'ui_social_models.dart';

/// A horizontally scrollable row of story circles, inspired by
/// Instagram's story tray.
///
/// Each circle shows the user's avatar initial with a gradient ring
/// (unseen stories) or a grey ring (seen stories). The first slot
/// is reserved for "Your story" with a plus icon overlay.
///
/// ```dart
/// UiStoryRow(
///   stories: myStories,
///   onStoryTap: (story) => viewStory(story),
///   onAddStory: () => createStory(),
/// )
/// ```
class UiStoryRow extends StatelessWidget {
  const UiStoryRow({
    super.key,
    required this.stories,
    this.onStoryTap,
    this.onAddStory,
    this.height = 90,
    this.avatarRadius = 32,
    this.ringWidth = 2.5,
  });

  /// The list of stories to display.
  final List<UiStory> stories;

  /// Called when a story circle is tapped.
  final ValueChanged<UiStory>? onStoryTap;

  /// Called when the "Your story" add button is tapped.
  final VoidCallback? onAddStory;

  /// Height of the story row.
  final double height;

  /// Radius of each avatar circle.
  final double avatarRadius;

  /// Width of the ring around each avatar.
  final double ringWidth;

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final spacing = theme.spacing;

    return SizedBox(
      height: height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: spacing.md),
        itemCount: stories.length + 1, // +1 for "Your story".
        separatorBuilder: (_, _) => SizedBox(width: spacing.sm),
        itemBuilder: (context, index) {
          if (index == 0) {
            return _AddStoryCircle(
              avatarRadius: avatarRadius,
              ringWidth: ringWidth,
              onTap: onAddStory,
            );
          }
          final story = stories[index - 1];
          return _StoryCircle(
            story: story,
            avatarRadius: avatarRadius,
            ringWidth: ringWidth,
            onTap: onStoryTap != null ? () => onStoryTap!(story) : null,
          );
        },
      ),
    );
  }
}

/// The "Your Story" circle with a plus overlay.
class _AddStoryCircle extends StatelessWidget {
  const _AddStoryCircle({
    required this.avatarRadius,
    required this.ringWidth,
    this.onTap,
  });

  final double avatarRadius;
  final double ringWidth;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final colors = theme.colorScheme;
    final typo = theme.typography;
    final diameter = avatarRadius * 2;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: diameter + ringWidth * 2 + 4,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: diameter + ringWidth * 2 + 4,
              height: diameter + ringWidth * 2 + 4,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Dashed ring placeholder.
                  Container(
                    width: diameter + ringWidth * 2,
                    height: diameter + ringWidth * 2,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: colors.border,
                        width: ringWidth,
                      ),
                    ),
                  ),
                  // Avatar.
                  Container(
                    width: diameter,
                    height: diameter,
                    decoration: BoxDecoration(
                      color: colors.surface,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: colors.border,
                        width: 1,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '+',
                      style: typo.titleMedium.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Your story',
              style: typo.labelSmall.copyWith(
                color: colors.onSurface.withValues(alpha: 0.7),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

/// A single story circle with gradient or grey ring.
class _StoryCircle extends StatelessWidget {
  const _StoryCircle({
    required this.story,
    required this.avatarRadius,
    required this.ringWidth,
    this.onTap,
  });

  final UiStory story;
  final double avatarRadius;
  final double ringWidth;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final colors = theme.colorScheme;
    final typo = theme.typography;
    final diameter = avatarRadius * 2;
    final author = story.user;
    final initial =
        author.name.isNotEmpty ? author.name[0].toUpperCase() : '?';

    final ringColor = story.seen
        ? colors.border
        : null; // null means use gradient ring.

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: diameter + ringWidth * 2 + 4,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: diameter + ringWidth * 2 + 4,
              height: diameter + ringWidth * 2 + 4,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Ring: gradient for unseen, solid for seen.
                  if (ringColor != null)
                    Container(
                      width: diameter + ringWidth * 2,
                      height: diameter + ringWidth * 2,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: ringColor,
                          width: ringWidth,
                        ),
                      ),
                    )
                  else
                    CustomPaint(
                      size: Size(
                        diameter + ringWidth * 2,
                        diameter + ringWidth * 2,
                      ),
                      painter: _GradientRingPainter(
                        colors: colors.gradient ??
                            [colors.primary, colors.secondary],
                        strokeWidth: ringWidth,
                      ),
                    ),
                  // Avatar circle.
                  Container(
                    width: diameter,
                    height: diameter,
                    decoration: BoxDecoration(
                      color: colors.secondary,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      initial,
                      style: typo.titleSmall.copyWith(
                        color: colors.onSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 4),
            Text(
              author.name.split(' ').first,
              style: typo.labelSmall.copyWith(
                color: colors.onSurface.withValues(alpha: 0.7),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

/// Paints a gradient ring (circle stroke with a sweep gradient).
class _GradientRingPainter extends CustomPainter {
  _GradientRingPainter({
    required this.colors,
    required this.strokeWidth,
  });

  final List<Color> colors;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final gradient = SweepGradient(
      startAngle: 0,
      endAngle: math.pi * 2,
      colors: colors.length >= 2
          ? colors
          : [colors.first, colors.first],
    );

    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final radius = (size.width - strokeWidth) / 2;
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      radius,
      paint,
    );
  }

  @override
  bool shouldRepaint(_GradientRingPainter oldDelegate) =>
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.colors.length != colors.length;
}
