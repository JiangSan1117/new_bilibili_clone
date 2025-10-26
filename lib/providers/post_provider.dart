// lib/providers/post_provider.dart
import 'package:flutter/foundation.dart';

/// PostProvider - 管理文章的點讚狀態
/// 當用戶在文章詳情頁點讚後，列表頁也會自動更新
class PostProvider with ChangeNotifier {
  // 儲存文章ID對應的點讚數
  final Map<String, int> _postLikes = {};
  
  // 儲存文章ID對應的評論數
  final Map<String, int> _postComments = {};

  /// 更新文章的點讚數
  void updatePostLikes(String postId, int newLikeCount) {
    _postLikes[postId] = newLikeCount;
    debugPrint('🔔 PostProvider: 更新點讚數 - postId=$postId, likes=$newLikeCount');
    debugPrint('🔔 PostProvider: 當前所有點讚狀態: $_postLikes');
    notifyListeners();
  }

  /// 獲取文章的點讚數
  /// 如果沒有更新過，返回默認值
  int getPostLikes(String postId, {int defaultLikes = 0}) {
    final likes = _postLikes[postId] ?? defaultLikes;
    debugPrint('🔔 PostProvider: 獲取點讚數 - postId=$postId, likes=$likes');
    return likes;
  }

  /// 檢查是否有更新的點讚數
  bool hasUpdatedLikes(String postId) {
    return _postLikes.containsKey(postId);
  }

  /// 更新文章的評論數
  void updatePostComments(String postId, int newCommentCount) {
    _postComments[postId] = newCommentCount;
    debugPrint('🔔 PostProvider: 更新評論數 - postId=$postId, comments=$newCommentCount');
    notifyListeners();
  }

  /// 獲取文章的評論數
  int getPostComments(String postId, {int defaultComments = 0}) {
    return _postComments[postId] ?? defaultComments;
  }

  /// 清除所有狀態（用於登出等場景）
  void clear() {
    _postLikes.clear();
    _postComments.clear();
    debugPrint('🧹 PostProvider: 清除所有狀態');
    notifyListeners();
  }

  /// 批量初始化文章數據（可選）
  void initializePosts(List<Map<String, dynamic>> posts) {
    for (var post in posts) {
      final postId = post['_id'] ?? post['id'];
      if (postId != null) {
        _postLikes[postId] = post['likes'] ?? 0;
        _postComments[postId] = post['comments'] ?? 0;
      }
    }
    debugPrint('🔔 PostProvider: 初始化 ${posts.length} 篇文章數據');
    notifyListeners(); // 添加這行確保初始化後通知監聽者
  }
}
