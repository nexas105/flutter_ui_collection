import 'package:flutter/widgets.dart';

import '../theme/ui_theme.dart';
import '../theme/ui_theme_data.dart';
import 'ui_chat_controller.dart';
import 'ui_chat_input_bar.dart';
import 'ui_chat_message_widget.dart';
import 'ui_chat_models.dart';
import 'ui_date_separator.dart';
import 'ui_reply_preview.dart';
import 'ui_typing_indicator.dart';

/// A complete chat room widget that assembles all chat sub-components.
///
/// Displays an optional app bar, a reverse-scrolling message list grouped by
/// date, a typing indicator, a reply preview, and an input bar.
///
/// ```dart
/// UiChatRoomView(
///   controller: chatController,
///   currentUserId: 'user-1',
///   roomName: 'General',
///   onSend: (text) => sendMessage(text),
/// )
/// ```
class UiChatRoomView extends StatefulWidget {
  const UiChatRoomView({
    super.key,
    required this.controller,
    required this.currentUserId,
    this.roomName,
    required this.onSend,
    this.onAttach,
    this.onLoadMore,
    this.showAppBar = true,
    this.appBarLeading,
    this.appBarActions,
  });

  /// Controller that manages messages, scroll position, typing, and reply
  /// state.
  final UiChatController controller;

  /// The id of the local user, used to determine message alignment.
  final String currentUserId;

  /// Optional room name displayed in the app bar.
  final String? roomName;

  /// Called when the user submits a message from the input bar.
  final ValueChanged<String> onSend;

  /// Called when the attachment button is tapped.
  final VoidCallback? onAttach;

  /// Called when the user scrolls to the top of the list (to lazy-load older
  /// messages).
  final VoidCallback? onLoadMore;

  /// Whether to show the top app bar. Defaults to `true`.
  final bool showAppBar;

  /// Optional leading widget for the app bar (e.g. a back button).
  final Widget? appBarLeading;

  /// Optional trailing actions for the app bar.
  final List<Widget>? appBarActions;

  @override
  State<UiChatRoomView> createState() => _UiChatRoomViewState();
}

class _UiChatRoomViewState extends State<UiChatRoomView> {
  @override
  void initState() {
    super.initState();
    widget.controller.scrollController.addListener(_handleScroll);
  }

  @override
  void didUpdateWidget(UiChatRoomView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.scrollController.removeListener(_handleScroll);
      widget.controller.scrollController.addListener(_handleScroll);
    }
  }

  @override
  void dispose() {
    widget.controller.scrollController.removeListener(_handleScroll);
    super.dispose();
  }

  void _handleScroll() {
    final sc = widget.controller.scrollController;
    if (widget.onLoadMore != null &&
        sc.hasClients &&
        sc.position.pixels >= sc.position.maxScrollExtent - 50) {
      widget.onLoadMore!();
    }
  }

  // ── Date grouping helpers ──────────────────────────────────────────────

  bool _isDifferentDay(DateTime a, DateTime b) {
    return a.year != b.year || a.month != b.month || a.day != b.day;
  }

  // ── Build helpers ──────────────────────────────────────────────────────

  Widget _buildAppBar(UiThemeData theme) {
    final colors = theme.colorScheme;
    final spacing = theme.spacing;

    return Container(
      height: theme.components.controlHeightLarge,
      padding: EdgeInsets.symmetric(horizontal: spacing.md),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(
          bottom: BorderSide(color: colors.border, width: theme.borderWidth),
        ),
        boxShadow: theme.surfaceShadows(),
      ),
      child: Row(
        children: [
          if (widget.appBarLeading != null) ...[
            widget.appBarLeading!,
            SizedBox(width: spacing.sm),
          ],
          if (widget.roomName != null)
            Expanded(
              child: Text(
                widget.roomName!,
                style: theme.typography.titleMedium.copyWith(
                  color: colors.onSurface,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            )
          else
            const Spacer(),
          if (widget.appBarActions != null)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (int i = 0; i < widget.appBarActions!.length; i++) ...[
                  if (i > 0) SizedBox(width: spacing.xs),
                  widget.appBarActions![i],
                ],
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildMessageList(UiThemeData theme, List<UiChatMessage> messages) {
    return Expanded(
      child: ListView.builder(
        controller: widget.controller.scrollController,
        reverse: true,
        padding: EdgeInsets.symmetric(
          horizontal: theme.spacing.md,
          vertical: theme.spacing.sm,
        ),
        itemCount: messages.length,
        itemBuilder: (context, index) {
          final message = messages[index];

          // Because the list is reversed, index 0 is the newest message.
          // We show a date separator *after* a message when the next
          // (chronologically older) message is on a different day.
          final bool showDateSeparator =
              index == messages.length - 1 ||
              _isDifferentDay(message.timestamp, messages[index + 1].timestamp);

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showDateSeparator)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: theme.spacing.sm),
                  child: UiChatDateSeparator(date: message.timestamp),
                ),
              GestureDetector(
                onLongPress: () {
                  widget.controller.startReply(message.id);
                },
                child: UiChatMessageWidget(
                  message: message,
                  currentUserId: widget.currentUserId,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = UiTheme.of(context);
    final colors = theme.colorScheme;

    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final messages = widget.controller.messages;
        final replyingTo = widget.controller.replyingToMessage;

        return Container(
          color: colors.background,
          child: Column(
            children: [
              // ── App bar ──
              if (widget.showAppBar) _buildAppBar(theme),

              // ── Message list ──
              _buildMessageList(theme, messages),

              // ── Typing indicator ──
              if (widget.controller.isTyping)
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: theme.spacing.md,
                    vertical: theme.spacing.xs,
                  ),
                  child: const Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: UiTypingIndicator(),
                  ),
                ),

              // ── Reply preview ──
              if (replyingTo != null)
                UiChatReplyPreview(
                  message: replyingTo,
                  onDismiss: () => widget.controller.cancelReply(),
                ),

              // ── Input bar ──
              UiChatInputBar(onSend: widget.onSend, onAttach: widget.onAttach),
            ],
          ),
        );
      },
    );
  }
}
