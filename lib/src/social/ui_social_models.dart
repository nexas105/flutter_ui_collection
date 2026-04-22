/// Post content type.
enum UiPostType { text, image, link }

/// A social media user.
class UiSocialUser {
  const UiSocialUser({
    required this.id,
    required this.name,
    required this.username,
    this.avatarUrl,
    this.isVerified = false,
  });

  /// Unique identifier.
  final String id;

  /// Display name.
  final String name;

  /// Username handle (without @).
  final String username;

  /// Optional avatar image URL.
  final String? avatarUrl;

  /// Whether the user has a verified badge.
  final bool isVerified;

  UiSocialUser copyWith({
    String? id,
    String? name,
    String? username,
    String? avatarUrl,
    bool? isVerified,
  }) {
    return UiSocialUser(
      id: id ?? this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isVerified: isVerified ?? this.isVerified,
    );
  }
}

/// A social media post.
class UiPost {
  const UiPost({
    required this.id,
    required this.author,
    required this.content,
    this.images = const [],
    this.likeCount = 0,
    this.commentCount = 0,
    this.shareCount = 0,
    this.isLiked = false,
    this.isBookmarked = false,
    required this.timestamp,
    this.type = UiPostType.text,
  });

  /// Unique identifier.
  final String id;

  /// The user who authored this post.
  final UiSocialUser author;

  /// Text content of the post.
  final String content;

  /// Image URLs attached to this post.
  final List<String> images;

  /// Number of likes.
  final int likeCount;

  /// Number of comments.
  final int commentCount;

  /// Number of shares.
  final int shareCount;

  /// Whether the current user has liked this post.
  final bool isLiked;

  /// Whether the current user has bookmarked this post.
  final bool isBookmarked;

  /// When the post was created.
  final DateTime timestamp;

  /// The type of post content.
  final UiPostType type;

  UiPost copyWith({
    String? id,
    UiSocialUser? author,
    String? content,
    List<String>? images,
    int? likeCount,
    int? commentCount,
    int? shareCount,
    bool? isLiked,
    bool? isBookmarked,
    DateTime? timestamp,
    UiPostType? type,
  }) {
    return UiPost(
      id: id ?? this.id,
      author: author ?? this.author,
      content: content ?? this.content,
      images: images ?? this.images,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      shareCount: shareCount ?? this.shareCount,
      isLiked: isLiked ?? this.isLiked,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
    );
  }
}

/// A comment on a post.
class UiComment {
  const UiComment({
    required this.id,
    required this.author,
    required this.content,
    required this.timestamp,
    this.likeCount = 0,
    this.isLiked = false,
    this.replies = const [],
  });

  /// Unique identifier.
  final String id;

  /// The user who wrote this comment.
  final UiSocialUser author;

  /// Text content of the comment.
  final String content;

  /// When the comment was created.
  final DateTime timestamp;

  /// Number of likes on this comment.
  final int likeCount;

  /// Whether the current user has liked this comment.
  final bool isLiked;

  /// Nested replies to this comment.
  final List<UiComment> replies;

  UiComment copyWith({
    String? id,
    UiSocialUser? author,
    String? content,
    DateTime? timestamp,
    int? likeCount,
    bool? isLiked,
    List<UiComment>? replies,
  }) {
    return UiComment(
      id: id ?? this.id,
      author: author ?? this.author,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      likeCount: likeCount ?? this.likeCount,
      isLiked: isLiked ?? this.isLiked,
      replies: replies ?? this.replies,
    );
  }
}

/// A story entry for the story row.
class UiStory {
  const UiStory({
    required this.user,
    this.hasNew = false,
    this.seen = false,
  });

  /// The user who posted this story.
  final UiSocialUser user;

  /// Whether there is new (unseen) story content.
  final bool hasNew;

  /// Whether the current user has seen this story.
  final bool seen;

  UiStory copyWith({
    UiSocialUser? user,
    bool? hasNew,
    bool? seen,
  }) {
    return UiStory(
      user: user ?? this.user,
      hasNew: hasNew ?? this.hasNew,
      seen: seen ?? this.seen,
    );
  }
}
