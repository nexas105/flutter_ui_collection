import 'package:flutter/widgets.dart';

import '../theme/ui_theme.dart';

/// A row of social action buttons: like, comment, share, and bookmark.
///
/// The like button features an animated scale bounce and color transition.
/// Counts are shown next to each button when non-zero.
///
/// ```dart
/// UiSocialActionBar(
///   likeCount: 42,
///   commentCount: 7,
///   isLiked: false,
///   onLike: () => toggleLike(),
///   onComment: () => openComments(),
/// )
/// ```
class UiSocialActionBar extends StatefulWidget {
  const UiSocialActionBar({
    super.key,
    this.likeCount = 0,
    this.commentCount = 0,
    this.shareCount = 0,
    this.isLiked = false,
    this.isBookmarked = false,
    this.onLike,
    this.onComment,
    this.onShare,
    this.onBookmark,
  });

  /// Number of likes.
  final int likeCount;

  /// Number of comments.
  final int commentCount;

  /// Number of shares.
  final int shareCount;

  /// Whether the current user has liked this item.
  final bool isLiked;

  /// Whether the current user has bookmarked this item.
  final bool isBookmarked;

  /// Called when the like button is tapped.
  final VoidCallback? onLike;

  /// Called when the comment button is tapped.
  final VoidCallback? onComment;

  /// Called when the share button is tapped.
  final VoidCallback? onShare;

  /// Called when the bookmark button is tapped.
  final VoidCallback? onBookmark;

  @override
  State<UiSocialActionBar> createState() => _UiSocialActionBarState();
}

class _UiSocialActionBarState extends State<UiSocialActionBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _likeController;
  late final Animation<double> _likeScale;

  @override
  void initState() {
    super.initState();
    _likeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _likeScale =
        TweenSequence<double>([
          TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3), weight: 50),
          TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0), weight: 50),
        ]).animate(
          CurvedAnimation(parent: _likeController, curve: Curves.easeInOut),
        );
  }

  @override
  void didUpdateWidget(UiSocialActionBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLiked && !oldWidget.isLiked) {
      _likeController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _likeController.dispose();
    super.dispose();
  }

  void _handleLike() {
    if (!widget.isLiked) {
      _likeController.forward(from: 0.0);
    }
    widget.onLike?.call();
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    }
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return '$count';
  }

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final colors = theme.colorScheme;
    final spacing = theme.spacing;
    final typo = theme.typography;

    final countStyle = typo.labelSmall.copyWith(
      color: colors.resolvedOnSurfaceMuted,
    );

    return Row(
      children: [
        // Like button.
        GestureDetector(
          onTap: _handleLike,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: spacing.xs,
              horizontal: spacing.xs,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedBuilder(
                  animation: _likeScale,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _likeScale.value,
                      child: child,
                    );
                  },
                  child: _HeartIcon(
                    filled: widget.isLiked,
                    color: widget.isLiked
                        ? colors.error
                        : colors.resolvedOnSurfaceMuted,
                    size: 20,
                  ),
                ),
                if (widget.likeCount > 0) ...[
                  SizedBox(width: spacing.xs),
                  Text(_formatCount(widget.likeCount), style: countStyle),
                ],
              ],
            ),
          ),
        ),
        SizedBox(width: spacing.md),
        // Comment button.
        GestureDetector(
          onTap: widget.onComment,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: spacing.xs,
              horizontal: spacing.xs,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _CommentIcon(color: colors.resolvedOnSurfaceMuted, size: 20),
                if (widget.commentCount > 0) ...[
                  SizedBox(width: spacing.xs),
                  Text(_formatCount(widget.commentCount), style: countStyle),
                ],
              ],
            ),
          ),
        ),
        SizedBox(width: spacing.md),
        // Share button.
        GestureDetector(
          onTap: widget.onShare,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: spacing.xs,
              horizontal: spacing.xs,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ShareIcon(color: colors.resolvedOnSurfaceMuted, size: 20),
                if (widget.shareCount > 0) ...[
                  SizedBox(width: spacing.xs),
                  Text(_formatCount(widget.shareCount), style: countStyle),
                ],
              ],
            ),
          ),
        ),
        const Spacer(),
        // Bookmark button.
        GestureDetector(
          onTap: widget.onBookmark,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: spacing.xs,
              horizontal: spacing.xs,
            ),
            child: _BookmarkIcon(
              filled: widget.isBookmarked,
              color: widget.isBookmarked
                  ? colors.primary
                  : colors.resolvedOnSurfaceMuted,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }
}

/// Animated wrapper that rebuilds when the animation ticks.
class AnimatedBuilder extends StatelessWidget {
  const AnimatedBuilder({
    super.key,
    required this.animation,
    required this.builder,
    this.child,
  });

  final Animation<double> animation;
  final Widget Function(BuildContext context, Widget? child) builder;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder._internal(
      animation: animation,
      builder: builder,
      child: child,
    );
  }

  // Use the framework's AnimatedBuilder via a static helper.
  static Widget _internal({
    required Animation<double> animation,
    required Widget Function(BuildContext, Widget?) builder,
    Widget? child,
  }) {
    return _AnimatedBuilderWidget(
      animation: animation,
      builder: builder,
      child: child,
    );
  }
}

class _AnimatedBuilderWidget extends StatefulWidget {
  const _AnimatedBuilderWidget({
    required this.animation,
    required this.builder,
    this.child,
  });

  final Animation<double> animation;
  final Widget Function(BuildContext, Widget?) builder;
  final Widget? child;

  @override
  State<_AnimatedBuilderWidget> createState() => _AnimatedBuilderWidgetState();
}

class _AnimatedBuilderWidgetState extends State<_AnimatedBuilderWidget> {
  @override
  void initState() {
    super.initState();
    widget.animation.addListener(_onTick);
  }

  @override
  void didUpdateWidget(_AnimatedBuilderWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animation != widget.animation) {
      oldWidget.animation.removeListener(_onTick);
      widget.animation.addListener(_onTick);
    }
  }

  @override
  void dispose() {
    widget.animation.removeListener(_onTick);
    super.dispose();
  }

  void _onTick() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, widget.child);
  }
}

/// Custom-painted heart icon.
class _HeartIcon extends StatelessWidget {
  const _HeartIcon({
    required this.filled,
    required this.color,
    required this.size,
  });

  final bool filled;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _HeartPainter(filled: filled, color: color),
    );
  }
}

class _HeartPainter extends CustomPainter {
  _HeartPainter({required this.filled, required this.color});

  final bool filled;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = filled ? PaintingStyle.fill : PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final h = size.height;

    final path = Path()
      ..moveTo(w * 0.5, h * 0.85)
      ..cubicTo(w * 0.15, h * 0.65, -w * 0.05, h * 0.3, w * 0.25, h * 0.15)
      ..cubicTo(w * 0.35, h * 0.08, w * 0.45, h * 0.12, w * 0.5, h * 0.25)
      ..cubicTo(w * 0.55, h * 0.12, w * 0.65, h * 0.08, w * 0.75, h * 0.15)
      ..cubicTo(w * 1.05, h * 0.3, w * 0.85, h * 0.65, w * 0.5, h * 0.85)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_HeartPainter oldDelegate) =>
      oldDelegate.filled != filled || oldDelegate.color != color;
}

/// Custom-painted comment bubble icon.
class _CommentIcon extends StatelessWidget {
  const _CommentIcon({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _CommentPainter(color: color),
    );
  }
}

class _CommentPainter extends CustomPainter {
  _CommentPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final h = size.height;
    final r = w * 0.15;

    final path = Path()
      ..moveTo(r, h * 0.15)
      ..lineTo(w - r, h * 0.15)
      ..arcToPoint(Offset(w, h * 0.15 + r), radius: Radius.circular(r))
      ..lineTo(w, h * 0.6 - r)
      ..arcToPoint(Offset(w - r, h * 0.6), radius: Radius.circular(r))
      ..lineTo(w * 0.45, h * 0.6)
      ..lineTo(w * 0.25, h * 0.82)
      ..lineTo(w * 0.25, h * 0.6)
      ..lineTo(r, h * 0.6)
      ..arcToPoint(Offset(0, h * 0.6 - r), radius: Radius.circular(r))
      ..lineTo(0, h * 0.15 + r)
      ..arcToPoint(Offset(r, h * 0.15), radius: Radius.circular(r))
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_CommentPainter oldDelegate) => oldDelegate.color != color;
}

/// Custom-painted share/forward icon.
class _ShareIcon extends StatelessWidget {
  const _ShareIcon({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _SharePainter(color: color),
    );
  }
}

class _SharePainter extends CustomPainter {
  _SharePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final h = size.height;

    // Arrow pointing right-up.
    final path = Path()
      ..moveTo(w * 0.6, h * 0.1)
      ..lineTo(w * 0.95, h * 0.35)
      ..lineTo(w * 0.6, h * 0.6)
      ..moveTo(w * 0.95, h * 0.35)
      ..lineTo(w * 0.4, h * 0.35)
      ..cubicTo(w * 0.15, h * 0.35, w * 0.05, h * 0.55, w * 0.05, h * 0.7)
      ..lineTo(w * 0.05, h * 0.9);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_SharePainter oldDelegate) => oldDelegate.color != color;
}

/// Custom-painted bookmark icon.
class _BookmarkIcon extends StatelessWidget {
  const _BookmarkIcon({
    required this.filled,
    required this.color,
    required this.size,
  });

  final bool filled;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _BookmarkPainter(filled: filled, color: color),
    );
  }
}

class _BookmarkPainter extends CustomPainter {
  _BookmarkPainter({required this.filled, required this.color});

  final bool filled;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = filled ? PaintingStyle.fill : PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final h = size.height;

    final path = Path()
      ..moveTo(w * 0.2, h * 0.05)
      ..lineTo(w * 0.8, h * 0.05)
      ..lineTo(w * 0.8, h * 0.95)
      ..lineTo(w * 0.5, h * 0.7)
      ..lineTo(w * 0.2, h * 0.95)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_BookmarkPainter oldDelegate) =>
      oldDelegate.filled != filled || oldDelegate.color != color;
}
