// lib/models/interaction_model.dart

class PostInteraction {
  final String postId;
  final List<String> likedBy; // 點讚用戶ID列表
  final List<String> sharedBy; // 分享用戶ID列表
  final List<String> bookmarkedBy; // 收藏用戶ID列表
  final DateTime lastUpdated;

  PostInteraction({
    required this.postId,
    this.likedBy = const [],
    this.sharedBy = const [],
    this.bookmarkedBy = const [],
    DateTime? lastUpdated,
  }) : lastUpdated = lastUpdated ?? DateTime.now();

  factory PostInteraction.fromMap(Map<String, dynamic> map) {
    return PostInteraction(
      postId: map['postId'] ?? '',
      likedBy: List<String>.from(map['likedBy'] ?? []),
      sharedBy: List<String>.from(map['sharedBy'] ?? []),
      bookmarkedBy: List<String>.from(map['bookmarkedBy'] ?? []),
      lastUpdated: map['lastUpdated'] != null
          ? DateTime.parse(map['lastUpdated'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'postId': postId,
      'likedBy': likedBy,
      'sharedBy': sharedBy,
      'bookmarkedBy': bookmarkedBy,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  PostInteraction copyWith({
    String? postId,
    List<String>? likedBy,
    List<String>? sharedBy,
    List<String>? bookmarkedBy,
    DateTime? lastUpdated,
  }) {
    return PostInteraction(
      postId: postId ?? this.postId,
      likedBy: likedBy ?? this.likedBy,
      sharedBy: sharedBy ?? this.sharedBy,
      bookmarkedBy: bookmarkedBy ?? this.bookmarkedBy,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  int get likesCount => likedBy.length;
  int get sharesCount => sharedBy.length;
  int get bookmarksCount => bookmarkedBy.length;

  bool isLikedBy(String userId) => likedBy.contains(userId);
  bool isSharedBy(String userId) => sharedBy.contains(userId);
  bool isBookmarkedBy(String userId) => bookmarkedBy.contains(userId);

  @override
  String toString() {
    return 'PostInteraction(postId: $postId, likes: $likesCount, shares: $sharesCount, bookmarks: $bookmarksCount)';
  }
}

class UserFollow {
  final String followerId; // 關注者ID
  final String followingId; // 被關注者ID
  final DateTime followedAt;

  UserFollow({
    required this.followerId,
    required this.followingId,
    DateTime? followedAt,
  }) : followedAt = followedAt ?? DateTime.now();

  factory UserFollow.fromMap(Map<String, dynamic> map) {
    return UserFollow(
      followerId: map['followerId'] ?? '',
      followingId: map['followingId'] ?? '',
      followedAt: map['followedAt'] != null
          ? DateTime.parse(map['followedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'followerId': followerId,
      'followingId': followingId,
      'followedAt': followedAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'UserFollow(followerId: $followerId, followingId: $followingId)';
  }
}
