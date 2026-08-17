import 'package:flutter/widgets.dart';

import '../icons/ui_icons.dart';
import '../theme/ui_theme.dart';
import 'ui_mention_text.dart';
import 'ui_social_action_bar.dart';
import 'ui_social_models.dart';

/// A social media post card inspired by Instagram, Twitter/X, and Facebook.
///
/// Displays a post with author header, text content with highlighted
/// mentions/hashtags, optional image grid, and an action bar for
/// like, comment, share, and bookmark.
///
/// ```dart
/// UiPostCard(
///   post: myPost,
///   onLike: () => toggleLike(myPost.id),
///   onComment: () => openComments(myPost.id),
///   onUserTap: (user) => openProfile(user),
/// )
/// ```
class UiPostCard extends StatelessWidget {
  const UiPostCard({
    super.key,
    required this.post,
    this.onLike,
    this.onComment,
    this.onShare,
    this.onBookmark,
    this.onUserTap,
    this.onMoreTap,
    this.onMentionTap,
    this.onHashtagTap,
    this.showActions = true,
  });

  /// The post data to display.
  final UiPost post;

  /// Called when the like button is tapped.
  final VoidCallback? onLike;

  /// Called when the comment button is tapped.
  final VoidCallback? onComment;

  /// Called when the share button is tapped.
  final VoidCallback? onShare;

  /// Called when the bookmark button is tapped.
  final VoidCallback? onBookmark;

  /// Called when the author avatar or name is tapped.
  final ValueChanged<UiSocialUser>? onUserTap;

  /// Called when the more (...) button is tapped.
  final VoidCallback? onMoreTap;

  /// Called when a @mention in the content is tapped.
  final ValueChanged<String>? onMentionTap;

  /// Called when a #hashtag in the content is tapped.
  final ValueChanged<String>? onHashtagTap;

  /// Whether to show the action bar (like, comment, share, bookmark).
  final bool showActions;

  String _timeAgo(DateTime timestamp) {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inSeconds < 60) return '${diff.inSeconds}s';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    if (diff.inDays < 365) return '${(diff.inDays / 7).floor()}w';
    return '${(diff.inDays / 365).floor()}y';
  }

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final colors = theme.colorScheme;
    final spacing = theme.spacing;
    final typo = theme.typography;

    final shadows = theme.surfaceShadows();

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: spacing.radiusMd,
        border: Border.all(color: colors.border, width: theme.borderWidth),
        boxShadow: shadows,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header row: avatar, name, username, verified, time, more.
          _buildHeader(context, theme, colors, spacing, typo),
          // Text content.
          if (post.content.isNotEmpty)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: spacing.md),
              child: UiMentionText(
                text: post.content,
                style: typo.bodyMedium.copyWith(color: colors.onSurface),
                onMentionTap: onMentionTap,
                onHashtagTap: onHashtagTap,
              ),
            ),
          // Images.
          if (post.images.isNotEmpty) ...[
            SizedBox(height: spacing.sm),
            _buildImageGrid(context, colors, spacing),
          ],
          // Action bar.
          if (showActions) ...[
            SizedBox(height: spacing.sm),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: spacing.md),
              child: UiSocialActionBar(
                likeCount: post.likeCount,
                commentCount: post.commentCount,
                shareCount: post.shareCount,
                isLiked: post.isLiked,
                isBookmarked: post.isBookmarked,
                onLike: onLike,
                onComment: onComment,
                onShare: onShare,
                onBookmark: onBookmark,
              ),
            ),
          ],
          SizedBox(height: spacing.sm),
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    dynamic theme,
    dynamic colors,
    dynamic spacing,
    dynamic typo,
  ) {
    final author = post.author;
    final initial = author.name.isNotEmpty ? author.name[0].toUpperCase() : '?';

    return Padding(
      padding: EdgeInsets.all(spacing.md as double),
      child: Row(
        children: [
          // Avatar.
          GestureDetector(
            onTap: onUserTap != null ? () => onUserTap!(author) : null,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: (colors.secondary as Color),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                initial,
                style: (typo.titleSmall as TextStyle).copyWith(
                  color: colors.onSecondary as Color,
                ),
              ),
            ),
          ),
          SizedBox(width: spacing.sm as double),
          // Name, username, timestamp.
          Expanded(
            child: GestureDetector(
              onTap: onUserTap != null ? () => onUserTap!(author) : null,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          author.name,
                          style: (typo.titleSmall as TextStyle).copyWith(
                            color: colors.onSurface as Color,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (author.isVerified) ...[
                        SizedBox(width: spacing.xs as double),
                        _VerifiedBadge(
                          color: colors.primary as Color,
                          size: 14,
                        ),
                      ],
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        '@${author.username}',
                        style: (typo.bodySmall as TextStyle).copyWith(
                          color: (colors.onSurface as Color).withValues(
                            alpha: 0.6,
                          ),
                        ),
                      ),
                      Text(
                        ' \u00B7 ${_timeAgo(post.timestamp)}',
                        style: (typo.bodySmall as TextStyle).copyWith(
                          color: (colors.onSurface as Color).withValues(
                            alpha: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // More button.
          GestureDetector(
            onTap: onMoreTap,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: EdgeInsets.all(spacing.xs as double),
              child: Text(
                '\u2026',
                style: (typo.titleMedium as TextStyle).copyWith(
                  color: colors.resolvedOnSurfaceSubtle,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageGrid(
    BuildContext context,
    dynamic colors,
    dynamic spacing,
  ) {
    final theme = UiTheme.of(context);
    final images = post.images;
    final count = images.length.clamp(0, 4);
    if (count == 0) return const SizedBox.shrink();

    final gap = (spacing.xs as double);

    // Build placeholder colored boxes representing images.
    Widget imageSlot(int index) {
      return Container(
        decoration: BoxDecoration(
          color: (colors.secondary as Color).withValues(
            alpha: theme.components.strongTintOpacity,
          ),
          borderRadius: BorderRadius.circular(spacing.borderRadiusSm as double),
        ),
        alignment: Alignment.center,
        child: UiIcon(
          UiIcons.image,
          size: theme.components.iconSizeLarge,
          color: colors.resolvedOnSurfaceSubtle,
        ),
      );
    }

    Widget grid;
    if (count == 1) {
      grid = AspectRatio(aspectRatio: 16 / 9, child: imageSlot(0));
    } else if (count == 2) {
      grid = AspectRatio(
        aspectRatio: 2 / 1,
        child: Row(
          children: [
            Expanded(child: imageSlot(0)),
            SizedBox(width: gap),
            Expanded(child: imageSlot(1)),
          ],
        ),
      );
    } else if (count == 3) {
      grid = AspectRatio(
        aspectRatio: 3 / 2,
        child: Row(
          children: [
            Expanded(flex: 2, child: imageSlot(0)),
            SizedBox(width: gap),
            Expanded(
              child: Column(
                children: [
                  Expanded(child: imageSlot(1)),
                  SizedBox(height: gap),
                  Expanded(child: imageSlot(2)),
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      // 4 images: 2x2 grid.
      grid = AspectRatio(
        aspectRatio: 1,
        child: Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  Expanded(child: imageSlot(0)),
                  SizedBox(width: gap),
                  Expanded(child: imageSlot(1)),
                ],
              ),
            ),
            SizedBox(height: gap),
            Expanded(
              child: Row(
                children: [
                  Expanded(child: imageSlot(2)),
                  SizedBox(width: gap),
                  Expanded(child: imageSlot(3)),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: spacing.md as double),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(spacing.borderRadiusMd as double),
        child: grid,
      ),
    );
  }
}

/// Custom-painted verified badge (checkmark in circle).
class _VerifiedBadge extends StatelessWidget {
  const _VerifiedBadge({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _VerifiedPainter(color: color),
    );
  }
}

class _VerifiedPainter extends CustomPainter {
  _VerifiedPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Circle background.
    final bgPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w / 2, h / 2), w / 2, bgPaint);

    // Checkmark.
    final checkPaint = Paint()
      ..color = const Color(0xFFFFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path()
      ..moveTo(w * 0.28, h * 0.5)
      ..lineTo(w * 0.44, h * 0.66)
      ..lineTo(w * 0.72, h * 0.34);

    canvas.drawPath(path, checkPaint);
  }

  @override
  bool shouldRepaint(_VerifiedPainter oldDelegate) =>
      oldDelegate.color != color;
}
