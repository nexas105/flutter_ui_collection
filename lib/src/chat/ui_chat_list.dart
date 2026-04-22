import 'package:flutter/widgets.dart';

import '../theme/ui_theme.dart';
import 'ui_chat_models.dart';
import 'ui_chat_list_tile.dart';

/// A scrollable list of chat conversation tiles.
///
/// Renders each [UiChatRoom] as a [UiChatListTile] inside a [ListView].
///
/// ```dart
/// UiChatList(
///   rooms: rooms,
///   currentUserId: myId,
///   onRoomTap: (room) => openRoom(room),
/// )
/// ```
class UiChatList extends StatelessWidget {
  const UiChatList({
    super.key,
    required this.rooms,
    required this.onRoomTap,
    required this.currentUserId,
  });

  /// The list of chat rooms to display.
  final List<UiChatRoom> rooms;

  /// Called when a room tile is tapped.
  final ValueChanged<UiChatRoom> onRoomTap;

  /// The current user's ID. Forwarded to each tile for formatting.
  final String currentUserId;

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final colors = theme.colorScheme;

    return Container(
      color: colors.surface,
      child: ListView.separated(
        itemCount: rooms.length,
        separatorBuilder: (context, index) => Container(
          height: theme.borderWidth,
          margin: EdgeInsets.only(
            left: theme.spacing.md + 48 + theme.spacing.sm,
          ),
          color: colors.border.withValues(alpha: 0.3),
        ),
        itemBuilder: (context, index) {
          final room = rooms[index];
          return UiChatListTile(
            room: room,
            currentUserId: currentUserId,
            onTap: () => onRoomTap(room),
          );
        },
      ),
    );
  }
}
