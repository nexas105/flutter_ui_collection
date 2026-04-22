import 'package:flutter/widgets.dart';

import 'ui_chat_models.dart';

/// A [ChangeNotifier] that manages chat state for a single conversation.
///
/// Holds the message list, typing/loading indicators, and reply state.
/// Consumers should listen to this controller (e.g. via
/// [ListenableBuilder]) to rebuild when state changes.
class UiChatController extends ChangeNotifier {
  UiChatController({
    required this.currentUser,
    List<UiChatMessage>? messages,
  }) : _messages = messages ?? [];

  /// The currently authenticated user.
  final UiChatUser currentUser;

  List<UiChatMessage> _messages;
  bool _isTyping = false;
  bool _isLoading = false;
  String? _replyingTo;

  /// Scroll controller used by the chat list view.
  final ScrollController scrollController = ScrollController();

  // ---------------------------------------------------------------------------
  // Getters
  // ---------------------------------------------------------------------------

  /// All messages in the current conversation, ordered as stored.
  List<UiChatMessage> get messages => List.unmodifiable(_messages);

  /// Whether another user is currently typing.
  bool get isTyping => _isTyping;

  /// Whether older messages are being loaded.
  bool get isLoading => _isLoading;

  /// The message currently being replied to, or `null`.
  UiChatMessage? get replyingToMessage {
    if (_replyingTo == null) return null;
    try {
      return _messages.firstWhere((m) => m.id == _replyingTo);
    } on StateError {
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  /// Appends [message] to the list, notifies listeners, and scrolls to the
  /// bottom of the chat.
  void addMessage(UiChatMessage message) {
    _messages.add(message);
    notifyListeners();
    scrollToBottom();
  }

  /// Replaces the message identified by [id] with [updated].
  ///
  /// Useful for updating delivery status or editing content.
  void updateMessage(String id, UiChatMessage updated) {
    final index = _messages.indexWhere((m) => m.id == id);
    if (index == -1) return;
    _messages[index] = updated;
    notifyListeners();
  }

  /// Removes the message identified by [id].
  void removeMessage(String id) {
    _messages.removeWhere((m) => m.id == id);
    notifyListeners();
  }

  /// Replaces the entire message list (e.g. for an initial load).
  void setMessages(List<UiChatMessage> messages) {
    _messages = List.of(messages);
    notifyListeners();
  }

  /// Prepends [older] messages to the beginning of the list (e.g. when
  /// paginating backwards).
  void addMessages(List<UiChatMessage> older) {
    _messages.insertAll(0, older);
    notifyListeners();
  }

  /// Sets whether another participant is typing.
  void setTyping(bool typing) {
    if (_isTyping == typing) return;
    _isTyping = typing;
    notifyListeners();
  }

  /// Sets whether older messages are being fetched.
  void setLoading(bool loading) {
    if (_isLoading == loading) return;
    _isLoading = loading;
    notifyListeners();
  }

  /// Begins replying to the message identified by [messageId].
  void startReply(String messageId) {
    _replyingTo = messageId;
    notifyListeners();
  }

  /// Cancels the current reply.
  void cancelReply() {
    if (_replyingTo == null) return;
    _replyingTo = null;
    notifyListeners();
  }

  /// Scrolls the chat list to the bottom.
  ///
  /// When [animated] is `true` (the default), uses a smooth scroll animation;
  /// otherwise jumps instantly.
  void scrollToBottom({bool animated = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!scrollController.hasClients) return;
      final target = scrollController.position.maxScrollExtent;
      if (animated) {
        scrollController.animateTo(
          target,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      } else {
        scrollController.jumpTo(target);
      }
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }
}
