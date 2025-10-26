// lib/models/post_model.dart
class Post {
  final String id;
  final String title;
  final String content;
  final String author;
  final String authorId;
  final String username;
  final String category;
  final String mainTab;
  final List<String> images;
  final List<String> videos;
  final int likes;
  final int comments;
  final int views;
  final String city;
  final String type;
  final String? postImageUrl;
  final DateTime? createdAt;

  Post({
    required this.id,
    required this.title,
    required this.content,
    required this.author,
    required this.authorId,
    required this.username,
    required this.category,
    required this.mainTab,
    required this.images,
    required this.videos,
    required this.likes,
    required this.comments,
    required this.views,
    required this.city,
    required this.type,
    this.postImageUrl,
    this.createdAt,
  });

  // 从 Map 转换
  factory Post.fromMap(Map<String, dynamic> map, {String? id}) {
    // 優先使用 MongoDB 的 _id 字段
    String postId;
    
    if (id != null) {
      postId = id;
      print('📝 Post.fromMap: 使用傳入的 id=$id');
    } else if (map['_id'] != null) {
      // 如果 _id 是 Map 類型（如 {"$oid": "..."}），提取其字符串值
      if (map['_id'] is Map && map['_id']['\$oid'] != null) {
        postId = map['_id']['\$oid'];
        print('📝 Post.fromMap: 從 Map 提取 _id=${postId}');
      } else {
        postId = map['_id'].toString();
        print('📝 Post.fromMap: 使用 _id=${postId}');
      }
    } else if (map['id'] != null) {
      postId = map['id'].toString();
      print('📝 Post.fromMap: 使用 id=${postId}');
    } else {
      postId = DateTime.now().millisecondsSinceEpoch.toString();
      print('⚠️ Post.fromMap: 生成臨時 ID=${postId}');
    }
    
    return Post(
      id: postId,
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      author: map['author'] ?? '',
      authorId: map['authorId'] ?? '',
      username: map['username'] ?? map['author'] ?? '',
      category: map['category'] ?? '',
      mainTab: map['mainTab'] ?? '',
      images: List<String>.from(map['images'] ?? []),
      videos: List<String>.from(map['videos'] ?? []),
      likes: map['likes'] ?? 0,
      comments: map['comments'] ?? 0,
      views: map['views'] ?? 0,
      city: map['city'] ?? '',
      type: map['type'] ?? '',
      postImageUrl: map['postImageUrl'],
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
    );
  }

  // 转换为 Map
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'author': author,
      'authorId': authorId,
      'username': username,
      'category': category,
      'mainTab': mainTab,
      'images': images,
      'videos': videos,
      'likes': likes,
      'comments': comments,
      'views': views,
      'city': city,
      'type': type,
      'postImageUrl': postImageUrl,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  // 复制方法
  Post copyWith({
    String? id,
    String? title,
    String? content,
    String? author,
    String? authorId,
    String? username,
    String? category,
    String? mainTab,
    List<String>? images,
    List<String>? videos,
    int? likes,
    int? comments,
    int? views,
    String? city,
    String? type,
    String? postImageUrl,
    DateTime? createdAt,
  }) {
    return Post(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      author: author ?? this.author,
      authorId: authorId ?? this.authorId,
      username: username ?? this.username,
      category: category ?? this.category,
      mainTab: mainTab ?? this.mainTab,
      images: images ?? this.images,
      videos: videos ?? this.videos,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      views: views ?? this.views,
      city: city ?? this.city,
      type: type ?? this.type,
      postImageUrl: postImageUrl ?? this.postImageUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Post(id: $id, title: $title, username: $username, likes: $likes)';
  }
}
