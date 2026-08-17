import 'package:flutter/widgets.dart';

import '../../icons/ui_icons.dart';
import '../../theme/ui_theme.dart';

/// Delivery status of a chat message.
enum UiChatBubbleStatus { sent, delivered, read }

/// A chat message bubble with optional avatar and timestamp.
///
/// ```dart
/// UiChatBubble(
///   message: 'Hello!',
///   isMe: true,
///   timestamp: '10:30 AM',
///   status: UiChatBubbleStatus.read,
/// )
/// ```
class UiChatBubble extends StatelessWidget {
  const UiChatBubble({
    super.key,
    required this.message,
    this.isMe = false,
    this.timestamp,
    this.avatar,
    this.status,
  });

  /// The message text to display.
  final String message;

  /// Whether this message was sent by the current user.
  final bool isMe;

  /// Optional timestamp label (e.g. `'10:30 AM'`).
  final String? timestamp;

  /// Optional avatar widget shown beside the bubble.
  final Widget? avatar;

  /// Delivery status indicator (only shown for `isMe` messages).
  final UiChatBubbleStatus? status;

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final colors = theme.colorScheme;
    final spacing = theme.spacing;
    final typo = theme.typography;

    final bgColor = isMe ? colors.primary : colors.surface;
    final fgColor = isMe ? colors.onPrimary : colors.onSurface;

    // Rounded corners with a "tail" on the sender's side.
    final radius = Radius.circular(spacing.borderRadiusMd);
    final tailRadius = const Radius.circular(2);

    final borderRadius = isMe
        ? BorderRadius.only(
            topLeft: radius,
            topRight: radius,
            bottomLeft: radius,
            bottomRight: tailRadius,
          )
        : BorderRadius.only(
            topLeft: tailRadius,
            topRight: radius,
            bottomLeft: radius,
            bottomRight: radius,
          );

    List<BoxShadow>? shadows;
    if (theme.useGlow && colors.glow != null) {
      shadows = [
        BoxShadow(
          color: (isMe ? colors.primary : colors.glow!).withValues(alpha: 0.2),
          blurRadius: 8,
        ),
      ];
    } else if (theme.useShadows) {
      shadows = [
        BoxShadow(
          color: colors.shadow.withValues(alpha: 0.1),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ];
    }

    // Status icon for sent messages.
    Widget? statusIcon;
    if (isMe && status != null) {
      final IconData iconData;
      final Color iconColor;
      switch (status!) {
        case UiChatBubbleStatus.sent:
          iconData = UiIcons.check;
          iconColor = fgColor.withValues(alpha: 0.5);
        case UiChatBubbleStatus.delivered:
          iconData = UiIcons.circle;
          iconColor = fgColor.withValues(alpha: 0.7);
        case UiChatBubbleStatus.read:
          iconData = UiIcons.circle;
          iconColor = colors.success;
      }
      statusIcon = Icon(iconData, size: 12, color: iconColor);
    }

    final bubble = Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.7,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: spacing.sm + 4,
        vertical: spacing.sm,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: borderRadius,
        border: isMe
            ? null
            : Border.all(color: colors.border, width: theme.borderWidth),
        boxShadow: shadows,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, style: typo.bodyMedium.copyWith(color: fgColor)),
          if (timestamp != null || statusIcon != null) ...[
            SizedBox(height: spacing.xs / 2),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (timestamp != null)
                  Text(
                    timestamp!,
                    style: typo.labelSmall.copyWith(
                      color: fgColor.withValues(alpha: 0.6),
                      fontSize: 10,
                    ),
                  ),
                if (statusIcon != null) ...[
                  SizedBox(width: spacing.xs / 2),
                  statusIcon,
                ],
              ],
            ),
          ],
        ],
      ),
    );

    final row = Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (!isMe && avatar != null) ...[avatar!, SizedBox(width: spacing.sm)],
        Flexible(child: bubble),
        if (isMe && avatar != null) ...[SizedBox(width: spacing.sm), avatar!],
      ],
    );

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: spacing.sm,
        vertical: spacing.xs,
      ),
      child: row,
    );
  }
}
