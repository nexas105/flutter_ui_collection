import 'package:flutter/widgets.dart';

import '../theme/ui_theme.dart';
import 'ui_social_models.dart';

/// Displays a nested comment thread with avatar, text, timestamps,
/// like buttons, and reply affordance.
///
/// Supports nested replies up to [maxDepth] levels with indentation
/// and vertical connector lines. Collapsed replies can be expanded
/// via a "Show N more replies" button.
///
/// ```dart
/// UiCommentThread(
///   comments: comments,
///   onLike: (commentId) => toggleLike(commentId),
///   onReply: (commentId) => openReplySheet(commentId),
///   currentUserId: myUserId,
/// )
/// ```
class UiCommentThread extends StatelessWidget {
  const UiCommentThread({
    super.key,
    required this.comments,
    this.onLike,
    this.onReply,
    this.onUserTap,
    this.currentUserId,
    this.maxDepth = 3,
  });

  /// Top-level comments to display.
  final List<UiComment> comments;

  /// Called with the comment id when the like button is tapped.
  final ValueChanged<String>? onLike;

  /// Called with the comment id when the reply button is tapped.
  final ValueChanged<String>? onReply;

  /// Called when a user avatar or name is tapped.
  final ValueChanged<UiSocialUser>? onUserTap;

  /// The current user's id, used for potential styling.
  final String? currentUserId;

  /// Maximum nesting depth for replies (default 3).
  final int maxDepth;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final comment in comments)
          _CommentNode(
            comment: comment,
            depth: 0,
            maxDepth: maxDepth,
            onLike: onLike,
            onReply: onReply,
            onUserTap: onUserTap,
          ),
      ],
    );
  }
}

class _CommentNode extends StatefulWidget {
  const _CommentNode({
    required this.comment,
    required this.depth,
    required this.maxDepth,
    this.onLike,
    this.onReply,
    this.onUserTap,
  });

  final UiComment comment;
  final int depth;
  final int maxDepth;
  final ValueChanged<String>? onLike;
  final ValueChanged<String>? onReply;
  final ValueChanged<UiSocialUser>? onUserTap;

  @override
  State<_CommentNode> createState() => _CommentNodeState();
}

class _CommentNodeState extends State<_CommentNode> {
  bool _repliesExpanded = false;

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

    final comment = widget.comment;
    final author = comment.author;
    final initial =
        author.name.isNotEmpty ? author.name[0].toUpperCase() : '?';
    final hasReplies = comment.replies.isNotEmpty;
    final canNest = widget.depth < widget.maxDepth;
    final indent = widget.depth * (spacing.md + spacing.sm);

    return Padding(
      padding: EdgeInsets.only(left: indent),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Connector line for nested comments.
          if (widget.depth > 0)
            CustomPaint(
              size: Size(spacing.md, 0),
              painter: _ConnectorPainter(
                color: colors.border,
                strokeWidth: theme.borderWidth,
              ),
            ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: spacing.sm),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar.
                GestureDetector(
                  onTap: widget.onUserTap != null
                      ? () => widget.onUserTap!(author)
                      : null,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: colors.secondary,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      initial,
                      style: typo.labelSmall.copyWith(
                        color: colors.onSecondary,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: spacing.sm),
                // Comment body.
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Name + timestamp.
                      Row(
                        children: [
                          GestureDetector(
                            onTap: widget.onUserTap != null
                                ? () => widget.onUserTap!(author)
                                : null,
                            child: Text(
                              author.name,
                              style: typo.labelMedium.copyWith(
                                color: colors.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          SizedBox(width: spacing.xs),
                          Text(
                            _timeAgo(comment.timestamp),
                            style: typo.labelSmall.copyWith(
                              color: colors.onSurface.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: spacing.xs / 2),
                      // Content.
                      Text(
                        comment.content,
                        style: typo.bodySmall.copyWith(
                          color: colors.onSurface,
                        ),
                      ),
                      SizedBox(height: spacing.xs),
                      // Actions: like, reply.
                      Row(
                        children: [
                          GestureDetector(
                            onTap: widget.onLike != null
                                ? () => widget.onLike!(comment.id)
                                : null,
                            behavior: HitTestBehavior.opaque,
                            child: Padding(
                              padding:
                                  EdgeInsets.symmetric(vertical: spacing.xs),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    comment.isLiked ? '\u2764' : '\u2661',
                                    style: typo.bodySmall.copyWith(
                                      color: comment.isLiked
                                          ? colors.error
                                          : colors.onSurface
                                              .withValues(alpha: 0.5),
                                    ),
                                  ),
                                  if (comment.likeCount > 0) ...[
                                    SizedBox(width: spacing.xs / 2),
                                    Text(
                                      '${comment.likeCount}',
                                      style: typo.labelSmall.copyWith(
                                        color: colors.onSurface
                                            .withValues(alpha: 0.6),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: spacing.md),
                          GestureDetector(
                            onTap: widget.onReply != null
                                ? () => widget.onReply!(comment.id)
                                : null,
                            behavior: HitTestBehavior.opaque,
                            child: Padding(
                              padding:
                                  EdgeInsets.symmetric(vertical: spacing.xs),
                              child: Text(
                                'Reply',
                                style: typo.labelSmall.copyWith(
                                  color:
                                      colors.onSurface.withValues(alpha: 0.5),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Replies.
          if (hasReplies && canNest) ...[
            if (!_repliesExpanded)
              GestureDetector(
                onTap: () => setState(() => _repliesExpanded = true),
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: EdgeInsets.only(
                    left: spacing.md + 32 + spacing.sm,
                    bottom: spacing.sm,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: spacing.lg,
                        height: 1,
                        color: colors.border,
                      ),
                      SizedBox(width: spacing.xs),
                      Text(
                        'Show ${comment.replies.length} '
                        '${comment.replies.length == 1 ? 'reply' : 'replies'}',
                        style: typo.labelSmall.copyWith(
                          color: colors.onSurface.withValues(alpha: 0.5),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...comment.replies.map(
                (reply) => _CommentNode(
                  comment: reply,
                  depth: widget.depth + 1,
                  maxDepth: widget.maxDepth,
                  onLike: widget.onLike,
                  onReply: widget.onReply,
                  onUserTap: widget.onUserTap,
                ),
              ),
          ],
        ],
      ),
    );
  }
}

/// Draws a small vertical connector line for nested comments.
class _ConnectorPainter extends CustomPainter {
  _ConnectorPainter({
    required this.color,
    required this.strokeWidth,
  });

  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(0, -size.height),
      Offset(0, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(_ConnectorPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
}
