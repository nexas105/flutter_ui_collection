import 'package:flutter/widgets.dart';

import '../theme/ui_theme.dart';
import 'ui_chat_models.dart';

/// A compact quoted-message preview with a left accent border.
///
/// Used inside chat bubbles to show the message being replied to,
/// and above the input bar when composing a reply.
///
/// ```dart
/// UiChatReplyPreview(
///   message: repliedMessage,
///   onTap: () => scrollToMessage(repliedMessage),
///   onDismiss: () => setState(() => _replyTo = null),
/// )
/// ```
class UiChatReplyPreview extends StatelessWidget {
  const UiChatReplyPreview({
    super.key,
    required this.message,
    this.onTap,
    this.onDismiss,
  });

  /// The message being quoted.
  final UiChatMessage message;

  /// Called when the preview is tapped (e.g. to scroll to original).
  final VoidCallback? onTap;

  /// Called when the dismiss button is tapped. When non-null, an X button
  /// is shown on the trailing side.
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final colors = theme.colorScheme;
    final spacing = theme.spacing;
    final typo = theme.typography;

    final content = message.type == UiMessageType.image
        ? '[Image]'
        : message.content;
    final truncated =
        content.length > 80 ? '${content.substring(0, 80)}...' : content;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: spacing.sm,
          vertical: spacing.xs,
        ),
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: colors.primary,
              width: 3.0,
            ),
          ),
          color: colors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(spacing.borderRadiusSm),
            bottomRight: Radius.circular(spacing.borderRadiusSm),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    message.sender.name,
                    style: typo.labelSmall.copyWith(
                      color: colors.primary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: spacing.xs / 2),
                  Text(
                    truncated,
                    style: typo.bodySmall.copyWith(
                      color: colors.onSurface.withValues(alpha: 0.7),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (onDismiss != null)
              GestureDetector(
                onTap: onDismiss,
                child: Padding(
                  padding: EdgeInsets.only(left: spacing.sm),
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CustomPaint(
                      painter: _ClosePainter(
                        color: colors.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ClosePainter extends CustomPainter {
  _ClosePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(size.width * 0.25, size.height * 0.25),
      Offset(size.width * 0.75, size.height * 0.75),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.75, size.height * 0.25),
      Offset(size.width * 0.25, size.height * 0.75),
      paint,
    );
  }

  @override
  bool shouldRepaint(_ClosePainter oldDelegate) => color != oldDelegate.color;
}
