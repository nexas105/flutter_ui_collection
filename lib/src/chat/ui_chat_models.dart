/// Message types supported by the chat module.
enum UiMessageType { text, image, system, voice }

/// Delivery status of a chat message.
enum UiMessageStatus { sending, sent, delivered, read, failed }

/// A chat user.
class UiChatUser {
  const UiChatUser({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.isOnline = false,
  });

  /// Unique identifier for this user.
  final String id;

  /// Display name.
  final String name;

  /// Optional URL pointing to the user's avatar image.
  final String? avatarUrl;

  /// Whether the user is currently online.
  final bool isOnline;

  /// Returns a copy of this user with the given fields replaced.
  UiChatUser copyWith({
    String? id,
    String? name,
    String? avatarUrl,
    bool? isOnline,
  }) {
    return UiChatUser(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isOnline: isOnline ?? this.isOnline,
    );
  }
}

/// A single chat message.
class UiChatMessage {
  const UiChatMessage({
    required this.id,
    required this.roomId,
    required this.sender,
    required this.content,
    this.type = UiMessageType.text,
    this.status = UiMessageStatus.sending,
    required this.timestamp,
    this.replyTo,
    this.metadata,
  });

  /// Unique identifier for this message.
  final String id;

  /// The room this message belongs to.
  final String roomId;

  /// The user who sent this message.
  final UiChatUser sender;

  /// Text content or image URL depending on [type].
  final String content;

  /// The type of this message.
  final UiMessageType type;

  /// Current delivery status.
  final UiMessageStatus status;

  /// When the message was created.
  final DateTime timestamp;

  /// The message this message is replying to, if any.
  final UiChatMessage? replyTo;

  /// Extensible metadata map for custom data.
  final Map<String, dynamic>? metadata;

  /// Returns a copy of this message with the given fields replaced.
  UiChatMessage copyWith({
    String? id,
    String? roomId,
    UiChatUser? sender,
    String? content,
    UiMessageType? type,
    UiMessageStatus? status,
    DateTime? timestamp,
    UiChatMessage? replyTo,
    Map<String, dynamic>? metadata,
  }) {
    return UiChatMessage(
      id: id ?? this.id,
      roomId: roomId ?? this.roomId,
      sender: sender ?? this.sender,
      content: content ?? this.content,
      type: type ?? this.type,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
      replyTo: replyTo ?? this.replyTo,
      metadata: metadata ?? this.metadata,
    );
  }
}

/// A chat room or conversation.
class UiChatRoom {
  const UiChatRoom({
    required this.id,
    required this.name,
    this.imageUrl,
    this.participants = const [],
    this.lastMessage,
    this.unreadCount = 0,
    this.lastActivity,
    this.isGroup = false,
  });

  /// Unique identifier for this room.
  final String id;

  /// Display name of the room.
  final String name;

  /// Optional URL for the room's image or avatar.
  final String? imageUrl;

  /// Users participating in this room.
  final List<UiChatUser> participants;

  /// The most recent message in the room, if any.
  final UiChatMessage? lastMessage;

  /// Number of unread messages for the current user.
  final int unreadCount;

  /// Timestamp of the last activity in this room.
  final DateTime? lastActivity;

  /// Whether this room is a group conversation.
  final bool isGroup;

  /// Returns a copy of this room with the given fields replaced.
  UiChatRoom copyWith({
    String? id,
    String? name,
    String? imageUrl,
    List<UiChatUser>? participants,
    UiChatMessage? lastMessage,
    int? unreadCount,
    DateTime? lastActivity,
    bool? isGroup,
  }) {
    return UiChatRoom(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      participants: participants ?? this.participants,
      lastMessage: lastMessage ?? this.lastMessage,
      unreadCount: unreadCount ?? this.unreadCount,
      lastActivity: lastActivity ?? this.lastActivity,
      isGroup: isGroup ?? this.isGroup,
    );
  }
}
