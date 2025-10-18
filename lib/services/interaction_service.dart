// lib/services/interaction_service.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/comment_model.dart';
import '../models/interaction_model.dart';
import '../models/post_model.dart';
import 'notification_service.dart';

class InteractionService {
  static const String _interactionsKey = 'post_interactions';
  static const String _commentsKey = 'post_comments';
  static const String _followsKey = 'user_follows';
  
  // 點讚相關方法
  
  /// 切換文章的點讚狀態
  static Future<PostInteraction> toggleLike(String postId, String userId) async {
    try {
      final interaction = await getPostInteraction(postId);
      final isLiked = interaction.isLikedBy(userId);
      
      List<String> newLikedBy = List.from(interaction.likedBy);
      if (isLiked) {
        newLikedBy.remove(userId);
      } else {
        newLikedBy.add(userId);
        
        // 發送點讚通知（如果用戶不是文章作者）
        await NotificationService.createNotification(
          type: NotificationService.typeLike,
          title: '收到新的讚',
          body: '有人讚了您的文章',
          userId: userId,
          postId: postId,
        );
      }
      
      final updatedInteraction = interaction.copyWith(
        likedBy: newLikedBy,
        lastUpdated: DateTime.now(),
      );
      
      await _savePostInteraction(updatedInteraction);
      return updatedInteraction;
    } catch (e) {
      throw Exception('點讚操作失敗: ${e.toString()}');
    }
  }
  
  /// 獲取文章的互動數據
  static Future<PostInteraction> getPostInteraction(String postId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final interactionsJson = prefs.getString(_interactionsKey);
      
      if (interactionsJson != null) {
        final Map<String, dynamic> interactionsMap = jsonDecode(interactionsJson);
        if (interactionsMap.containsKey(postId)) {
          return PostInteraction.fromMap(interactionsMap[postId]);
        }
      }
      
      // 如果沒有找到，返回默認的互動數據
      return PostInteraction(postId: postId);
    } catch (e) {
      return PostInteraction(postId: postId);
    }
  }
  
  /// 分享文章
  static Future<PostInteraction> sharePost(String postId, String userId) async {
    try {
      final interaction = await getPostInteraction(postId);
      final isShared = interaction.isSharedBy(userId);
      
      List<String> newSharedBy = List.from(interaction.sharedBy);
      if (!isShared) {
        newSharedBy.add(userId);
      }
      
      final updatedInteraction = interaction.copyWith(
        sharedBy: newSharedBy,
        lastUpdated: DateTime.now(),
      );
      
      await _savePostInteraction(updatedInteraction);
      return updatedInteraction;
    } catch (e) {
      throw Exception('分享操作失敗: ${e.toString()}');
    }
  }
  
  /// 收藏文章
  static Future<PostInteraction> bookmarkPost(String postId, String userId) async {
    try {
      final interaction = await getPostInteraction(postId);
      final isBookmarked = interaction.isBookmarkedBy(userId);
      
      List<String> newBookmarkedBy = List.from(interaction.bookmarkedBy);
      if (isBookmarked) {
        newBookmarkedBy.remove(userId);
      } else {
        newBookmarkedBy.add(userId);
      }
      
      final updatedInteraction = interaction.copyWith(
        bookmarkedBy: newBookmarkedBy,
        lastUpdated: DateTime.now(),
      );
      
      await _savePostInteraction(updatedInteraction);
      return updatedInteraction;
    } catch (e) {
      throw Exception('收藏操作失敗: ${e.toString()}');
    }
  }
  
  // 評論相關方法
  
  /// 添加評論
  static Future<Comment> addComment({
    required String postId,
    required String userId,
    required String username,
    required String content,
    String? parentId,
  }) async {
    try {
      final comment = Comment(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        postId: postId,
        userId: userId,
        username: username,
        content: content,
        createdAt: DateTime.now(),
        parentId: parentId,
      );
      
      await _saveComment(comment);
      
      // 發送評論通知
      await NotificationService.createNotification(
        type: NotificationService.typeComment,
        title: '新的評論',
        body: '$username 評論了您的文章：「${content.length > 20 ? content.substring(0, 20) + '...' : content}」',
        userId: userId,
        postId: postId,
      );
      
      return comment;
    } catch (e) {
      throw Exception('添加評論失敗: ${e.toString()}');
    }
  }
  
  /// 獲取文章的所有評論
  static Future<List<Comment>> getPostComments(String postId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final commentsJson = prefs.getString(_commentsKey);
      
      if (commentsJson != null) {
        final Map<String, dynamic> commentsMap = jsonDecode(commentsJson);
        if (commentsMap.containsKey(postId)) {
          final List<dynamic> commentsList = commentsMap[postId];
          return commentsList.map((commentData) => Comment.fromMap(commentData)).toList();
        }
      }
      
      return [];
    } catch (e) {
      return [];
    }
  }
  
  /// 點讚評論
  static Future<Comment> toggleCommentLike(String commentId, String userId, String postId) async {
    try {
      final comments = await getPostComments(postId);
      final commentIndex = comments.indexWhere((c) => c.id == commentId);
      
      if (commentIndex == -1) {
        throw Exception('評論不存在');
      }
      
      final comment = comments[commentIndex];
      final isLiked = comment.likedBy.contains(userId);
      
      List<String> newLikedBy = List.from(comment.likedBy);
      if (isLiked) {
        newLikedBy.remove(userId);
      } else {
        newLikedBy.add(userId);
      }
      
      final updatedComment = comment.copyWith(
        likedBy: newLikedBy,
        likes: newLikedBy.length,
      );
      
      comments[commentIndex] = updatedComment;
      await _savePostComments(postId, comments);
      
      return updatedComment;
    } catch (e) {
      throw Exception('點讚評論失敗: ${e.toString()}');
    }
  }
  
  // 關注相關方法
  
  /// 切換關注狀態
  static Future<bool> toggleFollow(String followerId, String followingId) async {
    try {
      final follows = await getAllFollows();
      final existingFollow = follows.firstWhere(
        (follow) => follow.followerId == followerId && follow.followingId == followingId,
        orElse: () => UserFollow(followerId: '', followingId: ''), // 空對象作為默認值
      );
      
      bool isFollowing = existingFollow.followerId.isNotEmpty;
      
      if (isFollowing) {
        // 取消關注
        follows.removeWhere(
          (follow) => follow.followerId == followerId && follow.followingId == followingId,
        );
      } else {
        // 添加關注
        follows.add(UserFollow(
          followerId: followerId,
          followingId: followingId,
        ));
        
        // 發送關注通知
        await NotificationService.createNotification(
          type: NotificationService.typeFollow,
          title: '新的關注者',
          body: '有人開始關注您',
          userId: followerId,
        );
      }
      
      await _saveAllFollows(follows);
      return !isFollowing; // 返回新的關注狀態
    } catch (e) {
      throw Exception('關注操作失敗: ${e.toString()}');
    }
  }
  
  /// 檢查是否已關注
  static Future<bool> isFollowing(String followerId, String followingId) async {
    try {
      final follows = await getAllFollows();
      return follows.any(
        (follow) => follow.followerId == followerId && follow.followingId == followingId,
      );
    } catch (e) {
      return false;
    }
  }
  
  /// 獲取用戶的關注列表
  static Future<List<String>> getFollowingList(String userId) async {
    try {
      final follows = await getAllFollows();
      return follows
          .where((follow) => follow.followerId == userId)
          .map((follow) => follow.followingId)
          .toList();
    } catch (e) {
      return [];
    }
  }
  
  /// 獲取用戶的粉絲列表
  static Future<List<String>> getFollowersList(String userId) async {
    try {
      final follows = await getAllFollows();
      return follows
          .where((follow) => follow.followingId == userId)
          .map((follow) => follow.followerId)
          .toList();
    } catch (e) {
      return [];
    }
  }
  
  /// 獲取用戶的關注數和粉絲數
  static Future<Map<String, int>> getUserFollowStats(String userId) async {
    try {
      final followingList = await getFollowingList(userId);
      final followersList = await getFollowersList(userId);
      
      return {
        'following': followingList.length,
        'followers': followersList.length,
      };
    } catch (e) {
      return {'following': 0, 'followers': 0};
    }
  }
  
  // 私有方法
  
  static Future<void> _savePostInteraction(PostInteraction interaction) async {
    final prefs = await SharedPreferences.getInstance();
    final interactionsJson = prefs.getString(_interactionsKey);
    
    Map<String, dynamic> interactionsMap = {};
    if (interactionsJson != null) {
      interactionsMap = jsonDecode(interactionsJson);
    }
    
    interactionsMap[interaction.postId] = interaction.toMap();
    await prefs.setString(_interactionsKey, jsonEncode(interactionsMap));
  }
  
  static Future<void> _saveComment(Comment comment) async {
    final prefs = await SharedPreferences.getInstance();
    final commentsJson = prefs.getString(_commentsKey);
    
    Map<String, dynamic> commentsMap = {};
    if (commentsJson != null) {
      commentsMap = jsonDecode(commentsJson);
    }
    
    if (!commentsMap.containsKey(comment.postId)) {
      commentsMap[comment.postId] = [];
    }
    
    final commentsList = List<Map<String, dynamic>>.from(commentsMap[comment.postId]);
    commentsList.insert(0, comment.toMap()); // 新評論插入到最前面
    
    commentsMap[comment.postId] = commentsList;
    await prefs.setString(_commentsKey, jsonEncode(commentsMap));
  }
  
  static Future<void> _savePostComments(String postId, List<Comment> comments) async {
    final prefs = await SharedPreferences.getInstance();
    final commentsJson = prefs.getString(_commentsKey);
    
    Map<String, dynamic> commentsMap = {};
    if (commentsJson != null) {
      commentsMap = jsonDecode(commentsJson);
    }
    
    commentsMap[postId] = comments.map((comment) => comment.toMap()).toList();
    await prefs.setString(_commentsKey, jsonEncode(commentsMap));
  }
  
  static Future<List<UserFollow>> getAllFollows() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final followsJson = prefs.getString(_followsKey);
      
      if (followsJson != null) {
        final List<dynamic> followsList = jsonDecode(followsJson);
        return followsList.map((followData) => UserFollow.fromMap(followData)).toList();
      }
      
      return [];
    } catch (e) {
      return [];
    }
  }
  
  static Future<void> _saveAllFollows(List<UserFollow> follows) async {
    final prefs = await SharedPreferences.getInstance();
    final followsJson = jsonEncode(follows.map((follow) => follow.toMap()).toList());
    await prefs.setString(_followsKey, followsJson);
  }
}
