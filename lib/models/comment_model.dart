// lib/models/comment_model.dart

class Comment {
  final String id;
  final String postId;
  final String userId;
  final String username;
  final String content;
  final DateTime createdAt;
  final int likes;
  final List<String> likedBy; // 點讚用戶ID列表
  final String? parentId; // 回覆的評論ID，null表示頂級評論
  final List<Comment> replies; // 回覆列表

  Comment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.username,
    required this.content,
    required this.createdAt,
    this.likes = 0,
    this.likedBy = const [],
    this.parentId,
    this.replies = const [],
  });

  factory Comment.fromMap(Map<String, dynamic> map, {String? id}) {
    return Comment(
      id: id ?? map['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      postId: map['postId'] ?? '',
      userId: map['userId'] ?? '',
      username: map['username'] ?? '',
      content: map['content'] ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      likes: map['likes'] ?? 0,
      likedBy: List<String>.from(map['likedBy'] ?? []),
      parentId: map['parentId'],
      replies: (map['replies'] as List<dynamic>?)
          ?.map((reply) => Comment.fromMap(reply))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'postId': postId,
      'userId': userId,
      'username': username,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'likes': likes,
      'likedBy': likedBy,
      'parentId': parentId,
      'replies': replies.map((reply) => reply.toMap()).toList(),
    };
  }

  Comment copyWith({
    String? id,
    String? postId,
    String? userId,
    String? username,
    String? content,
    DateTime? createdAt,
    int? likes,
    List<String>? likedBy,
    String? parentId,
    List<Comment>? replies,
  }) {
    return Comment(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      likes: likes ?? this.likes,
      likedBy: likedBy ?? this.likedBy,
      parentId: parentId ?? this.parentId,
      replies: replies ?? this.replies,
    );
  }

  bool get isLiked => likedBy.isNotEmpty; // 簡化判斷，實際應該檢查當前用戶ID

  @override
  String toString() {
    return 'Comment(id: $id, username: $username, content: $content, likes: $likes)';
  }
}
