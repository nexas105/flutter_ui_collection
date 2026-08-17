import 'package:flutter/widgets.dart';

import '../theme/ui_theme.dart';
import 'ui_chat_models.dart';
import 'ui_message_status_icon.dart';
import 'ui_reply_preview.dart';

/// Renders a single chat message as a themed bubble.
///
/// Handles text, image, and system message types. Supports directional
/// rounding based on whether the message is from the current user, reply
/// previews, sender names for group chats, and delivery status indicators.
///
/// ```dart
/// UiChatMessageWidget(
///   message: msg,
///   currentUserId: myId,
///   showAvatar: true,
///   onLongPress: () => showActions(msg),
/// )
/// ```
class UiChatMessageWidget extends StatelessWidget {
  const UiChatMessageWidget({
    super.key,
    required this.message,
    required this.currentUserId,
    this.onLongPress,
    this.onReplyTap,
    this.showAvatar = true,
  });

  /// The message to render.
  final UiChatMessage message;

  /// The current user's ID. Used to determine bubble alignment.
  final String currentUserId;

  /// Called on long press of the bubble.
  final VoidCallback? onLongPress;

  /// Called when the reply preview is tapped.
  final VoidCallback? onReplyTap;

  /// Whether to show the sender's avatar. Defaults to true.
  final bool showAvatar;

  bool get _isMe => message.sender.id == currentUserId;

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final colors = theme.colorScheme;
    final spacing = theme.spacing;
    final typo = theme.typography;

    // System messages are rendered as centered italic text.
    if (message.type == UiMessageType.system) {
      return Padding(
        padding: EdgeInsets.symmetric(
          vertical: spacing.xs,
          horizontal: spacing.lg,
        ),
        child: Center(
          child: Text(
            message.content,
            style: typo.bodySmall.copyWith(
              color: colors.resolvedOnSurfaceSubtle,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final bubbleColor = _isMe ? colors.primary : colors.surface;
    final textColor = _isMe ? colors.onPrimary : colors.onSurface;
    final alignment = _isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final mainAlignment = _isMe
        ? MainAxisAlignment.end
        : MainAxisAlignment.start;

    // Directional rounding: sharp corner on the sender's side.
    final radius = Radius.circular(spacing.borderRadiusLg);
    final sharpRadius = Radius.circular(spacing.borderRadiusSm);
    final borderRadius = _isMe
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

    final shadows = theme.surfaceShadows();

    // Time label.
    final hour = message.timestamp.hour.toString().padLeft(2, '0');
    final minute = message.timestamp.minute.toString().padLeft(2, '0');
    final timeLabel = '$hour:$minute';

    // Avatar placeholder.
    Widget avatarWidget;
    if (showAvatar && !_isMe) {
      final initials = message.sender.name.isNotEmpty
          ? message.sender.name[0].toUpperCase()
          : '?';
      avatarWidget = Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: colors.secondary,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Text(
          initials,
          style: typo.labelSmall.copyWith(color: colors.onSecondary),
        ),
      );
    } else {
      avatarWidget = const SizedBox(width: 32);
    }

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: spacing.sm,
        vertical: spacing.xs / 2,
      ),
      child: Row(
        mainAxisAlignment: mainAlignment,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!_isMe) ...[avatarWidget, SizedBox(width: spacing.xs)],
          Flexible(
            child: GestureDetector(
              onLongPress: onLongPress,
              child: Column(
                crossAxisAlignment: alignment,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    constraints: const BoxConstraints(maxWidth: 280),
                    padding: EdgeInsets.symmetric(
                      horizontal: spacing.sm + 2,
                      vertical: spacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: bubbleColor,
                      borderRadius: borderRadius,
                      border: _isMe
                          ? null
                          : Border.all(
                              color: colors.border,
                              width: theme.borderWidth,
                            ),
                      boxShadow: shadows,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Sender name for group messages (non-me).
                        if (!_isMe) ...[
                          Text(
                            message.sender.name,
                            style: typo.labelSmall.copyWith(
                              color: colors.primary,
                            ),
                          ),
                          SizedBox(height: spacing.xs / 2),
                        ],
                        // Reply preview.
                        if (message.replyTo != null) ...[
                          UiChatReplyPreview(
                            message: message.replyTo!,
                            onTap: onReplyTap,
                          ),
                          SizedBox(height: spacing.xs),
                        ],
                        // Content.
                        if (message.type == UiMessageType.image)
                          ClipRRect(
                            borderRadius: spacing.radiusSm,
                            child: Image.network(
                              message.content,
                              width: 220,
                              fit: BoxFit.cover,
                            ),
                          )
                        else
                          Text(
                            message.content,
                            style: typo.bodyMedium.copyWith(color: textColor),
                          ),
                        SizedBox(height: spacing.xs / 2),
                        // Timestamp + status.
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
                            if (_isMe) ...[
                              SizedBox(width: spacing.xs / 2),
                              UiMessageStatusIcon(status: message.status),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
