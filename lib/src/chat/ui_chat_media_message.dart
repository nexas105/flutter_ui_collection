import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../theme/ui_theme.dart';
import 'ui_chat_models.dart';
import 'ui_message_status_icon.dart';

/// Renders an image or video message bubble with optional caption.
///
/// Displays a rounded image container with an optional play button overlay
/// for video content, a caption area, and timestamp with delivery status.
///
/// ```dart
/// UiChatMediaMessage(
///   imageUrl: 'https://example.com/photo.jpg',
///   isMe: true,
///   timestamp: DateTime.now(),
///   status: UiMessageStatus.delivered,
///   caption: 'Check this out!',
///   onTap: () => openImage(),
/// )
/// ```
class UiChatMediaMessage extends StatelessWidget {
  const UiChatMediaMessage({
    super.key,
    required this.imageUrl,
    this.caption,
    this.isVideo = false,
    required this.isMe,
    required this.timestamp,
    required this.status,
    this.onTap,
  });

  /// URL of the image to display.
  final String imageUrl;

  /// Optional caption text below the image.
  final String? caption;

  /// Whether this is a video message (shows play button overlay).
  final bool isVideo;

  /// Whether this message was sent by the current user.
  final bool isMe;

  /// When the message was sent.
  final DateTime timestamp;

  /// Delivery status of the message.
  final UiMessageStatus status;

  /// Called when the media is tapped.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final colors = theme.colorScheme;
    final spacing = theme.spacing;
    final typo = theme.typography;

    final bubbleColor = isMe ? colors.primary : colors.surface;
    final textColor = isMe ? colors.onPrimary : colors.onSurface;

    final radius = Radius.circular(spacing.borderRadiusLg);
    final sharpRadius = Radius.circular(spacing.borderRadiusSm);
    final borderRadius = isMe
        ? BorderRadius.only(
            topLeft: radius,
            topRight: radius,
            bottomLeft: radius,
            bottomRight: sharpRadius,
          )
        : BorderRadius.only(
            topLeft: radius,
            topRight: radius,
            bottomLeft: sharpRadius,
            bottomRight: radius,
          );

    List<BoxShadow>? shadows;
    if (theme.useGlow && colors.glow != null) {
      shadows = [
        BoxShadow(
          color: colors.glow!.withValues(alpha: 0.2),
          blurRadius: 8,
        ),
      ];
    } else if (theme.useShadows) {
      shadows = [
        BoxShadow(
          color: colors.shadow.withValues(alpha: 0.1),
          offset: const Offset(0, 1),
          blurRadius: 3,
        ),
      ];
    }

    final hour = timestamp.hour.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');
    final timeLabel = '$hour:$minute';

    return Container(
      constraints: const BoxConstraints(maxWidth: 260),
      decoration: BoxDecoration(
        color: bubbleColor,
        borderRadius: borderRadius,
        border: isMe
            ? null
            : Border.all(color: colors.border, width: theme.borderWidth),
        boxShadow: shadows,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Image area.
          GestureDetector(
            onTap: onTap,
            child: Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: radius,
                    topRight: radius,
                  ),
                  child: Image.network(
                    imageUrl,
                    width: 260,
                    height: 180,
                    fit: BoxFit.cover,
                  ),
                ),
                if (isVideo)
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: colors.onSurface.withValues(alpha: 0.6),
                      shape: BoxShape.circle,
                    ),
                    child: CustomPaint(
                      painter: _PlayIconPainter(color: colors.surface),
                      size: const Size(48, 48),
                    ),
                  ),
              ],
            ),
          ),
          // Caption + timestamp area.
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: spacing.sm + 2,
              vertical: spacing.sm,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (caption != null && caption!.isNotEmpty) ...[
                  Text(
                    caption!,
                    style: typo.bodyMedium.copyWith(color: textColor),
                  ),
                  SizedBox(height: spacing.xs / 2),
                ],
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      timeLabel,
                      style: typo.labelSmall.copyWith(
                        color: textColor.withValues(alpha: 0.6),
                        fontSize: 10,
                      ),
                    ),
                    if (isMe) ...[
                      SizedBox(width: spacing.xs / 2),
                      UiMessageStatusIcon(status: status),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Paints a triangle (play icon) centered in its canvas.
class _PlayIconPainter extends CustomPainter {
  _PlayIconPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = math.min(size.width, size.height) * 0.22;

    final path = Path()
      ..moveTo(cx - r * 0.7, cy - r)
      ..lineTo(cx + r, cy)
      ..lineTo(cx - r * 0.7, cy + r)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_PlayIconPainter oldDelegate) =>
      color != oldDelegate.color;
}
