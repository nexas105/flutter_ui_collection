import 'package:flutter/widgets.dart';

import '../theme/ui_theme.dart';
import 'ui_chat_models.dart';

/// A single conversation row for the chat list.
///
/// Shows avatar with online indicator, room name, last message preview,
/// timestamp, and unread badge. Includes a hover/pressed state.
///
/// ```dart
/// UiChatListTile(
///   room: room,
///   currentUserId: myId,
///   onTap: () => openRoom(room),
/// )
/// ```
class UiChatListTile extends StatefulWidget {
  const UiChatListTile({
    super.key,
    required this.room,
    required this.currentUserId,
    this.onTap,
  });

  /// The chat room to display.
  final UiChatRoom room;

  /// The current user's id, used for formatting last message preview.
  final String currentUserId;

  /// Called when this tile is tapped.
  final VoidCallback? onTap;

  @override
  State<UiChatListTile> createState() => _UiChatListTileState();
}

class _UiChatListTileState extends State<UiChatListTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final colors = theme.colorScheme;
    final spacing = theme.spacing;
    final typo = theme.typography;

    // Determine the "other" user for the avatar in 1:1 chats.
    final participants = widget.room.participants;
    final otherUser = participants.isNotEmpty
        ? participants.firstWhere(
            (u) => u.id != widget.currentUserId,
            orElse: () => participants.first,
          )
        : null;

    final isOnline = otherUser?.isOnline ?? false;
    final initial = widget.room.name.isNotEmpty
        ? widget.room.name[0].toUpperCase()
        : '?';

    // Last message preview.
    String? lastPreview;
    if (widget.room.lastMessage != null) {
      final lm = widget.room.lastMessage!;
      final prefix =
          lm.sender.id == widget.currentUserId ? 'You: ' : '';
      final body = lm.type == UiMessageType.image
          ? '[Image]'
          : lm.content;
      final truncated = body.length > 40 ? '${body.substring(0, 40)}...' : body;
      lastPreview = '$prefix$truncated';
    }

    // Time label.
    String? timeLabel;
    final lastActivity =
        widget.room.lastActivity ?? widget.room.lastMessage?.timestamp;
    if (lastActivity != null) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final msgDay = DateTime(
        lastActivity.year,
        lastActivity.month,
        lastActivity.day,
      );
      if (msgDay == today) {
        final h = lastActivity.hour.toString().padLeft(2, '0');
        final m = lastActivity.minute.toString().padLeft(2, '0');
        timeLabel = '$h:$m';
      } else if (today.difference(msgDay).inDays == 1) {
        timeLabel = 'Yesterday';
      } else {
        timeLabel =
            '${lastActivity.day}/${lastActivity.month}/${lastActivity.year}';
      }
    }

    final hasUnread = widget.room.unreadCount > 0;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: theme.animationDuration,
          curve: theme.animationCurve,
          padding: EdgeInsets.symmetric(
            horizontal: spacing.md,
            vertical: spacing.sm,
          ),
          decoration: BoxDecoration(
            color: _hovered
                ? colors.primary.withValues(alpha: 0.06)
                : colors.surface,
          ),
          child: Row(
            children: [
              // Avatar with online dot.
              SizedBox(
                width: 48,
                height: 48,
                child: Stack(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
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
                    if (isOnline)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: colors.success,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: colors.surface,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(width: spacing.sm),
              // Name + last message.
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.room.name,
                      style: typo.titleSmall.copyWith(
                        color: colors.onSurface,
                        fontWeight:
                            hasUnread ? FontWeight.w700 : FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (lastPreview != null) ...[
                      SizedBox(height: spacing.xs / 2),
                      Text(
                        lastPreview,
                        style: typo.bodySmall.copyWith(
                          color: hasUnread
                              ? colors.onSurface
                              : colors.onSurface.withValues(alpha: 0.6),
                          fontWeight:
                              hasUnread ? FontWeight.w600 : FontWeight.w400,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(width: spacing.sm),
              // Time + unread badge column.
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (timeLabel != null)
                    Text(
                      timeLabel,
                      style: typo.labelSmall.copyWith(
                        color: hasUnread
                            ? colors.primary
                            : colors.onSurface.withValues(alpha: 0.5),
                        fontSize: 11,
                      ),
                    ),
                  if (hasUnread) ...[
                    SizedBox(height: spacing.xs),
                    Container(
                      constraints: const BoxConstraints(minWidth: 20),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: colors.primary,
                        borderRadius: spacing.radiusFull,
                      ),
                      child: Text(
                        widget.room.unreadCount > 99
                            ? '99+'
                            : '${widget.room.unreadCount}',
                        style: typo.labelSmall.copyWith(
                          color: colors.onPrimary,
                          fontSize: 11,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
