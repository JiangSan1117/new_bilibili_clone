// lib/services/data_service.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/post_model.dart';
import '../models/user_model.dart';
import '../constants/mock_data.dart';

class DataService {
  static const String _postsKey = 'saved_posts';
  static const String _userKey = 'current_user';
  
  // 文章相關方法
  
  // 獲取所有文章
  static Future<List<Post>> getAllPosts() async {
    try {
      // 首先嘗試從本地存儲獲取
      final localPosts = await _getLocalPosts();
      if (localPosts.isNotEmpty) {
        return localPosts;
      }
      
      // 如果本地沒有數據，返回模擬數據
      return kMockPosts.map((postData) => Post.fromMap(postData)).toList();
    } catch (e) {
      // 如果出錯，返回模擬數據
      return kMockPosts.map((postData) => Post.fromMap(postData)).toList();
    }
  }
  
  // 根據主標籤獲取文章
  static Future<List<Post>> getPostsByMainTab(String mainTab) async {
    final allPosts = await getAllPosts();
    return allPosts.where((post) => post.mainTab == mainTab).toList();
  }
  
  // 根據分類獲取文章
  static Future<List<Post>> getPostsByCategory(String category) async {
    final allPosts = await getAllPosts();
    return allPosts.where((post) => post.category == category).toList();
  }
  
  // 獲取熱門文章（按點閱數排序）
  static Future<List<Post>> getHotPosts() async {
    final allPosts = await getAllPosts();
    allPosts.sort((a, b) => b.views.compareTo(a.views));
    return allPosts;
  }
  
  // 搜索文章
  static Future<List<Post>> searchPosts(String query) async {
    final allPosts = await getAllPosts();
    return allPosts.where((post) => 
      post.title.toLowerCase().contains(query.toLowerCase()) ||
      post.username.toLowerCase().contains(query.toLowerCase()) ||
      post.category.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }
  
  // 保存新文章
  static Future<void> savePost(Post post) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existingPosts = await _getLocalPosts();
      existingPosts.insert(0, post); // 插入到最前面
      
      final postsJson = existingPosts.map((p) => p.toMap()).toList();
      await prefs.setString(_postsKey, jsonEncode(postsJson));
    } catch (e) {
      throw Exception('保存文章失敗: ${e.toString()}');
    }
  }
  
  // 更新文章
  static Future<void> updatePost(Post post) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existingPosts = await _getLocalPosts();
      
      final index = existingPosts.indexWhere((p) => p.id == post.id);
      if (index != -1) {
        existingPosts[index] = post;
        
        final postsJson = existingPosts.map((p) => p.toMap()).toList();
        await prefs.setString(_postsKey, jsonEncode(postsJson));
      }
    } catch (e) {
      throw Exception('更新文章失敗: ${e.toString()}');
    }
  }
  
  // 刪除文章
  static Future<void> deletePost(String postId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existingPosts = await _getLocalPosts();
      
      existingPosts.removeWhere((post) => post.id == postId);
      
      final postsJson = existingPosts.map((p) => p.toMap()).toList();
      await prefs.setString(_postsKey, jsonEncode(postsJson));
    } catch (e) {
      throw Exception('刪除文章失敗: ${e.toString()}');
    }
  }
  
  // 用戶相關方法
  
  // 獲取當前用戶
  static Future<User?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userKey);
      
      if (userJson != null) {
        final userData = jsonDecode(userJson);
        return User.fromMap(userData);
      }
      
      // 如果沒有本地用戶數據，返回模擬用戶
      return User.fromMap(kMockUserData);
    } catch (e) {
      // 如果出錯，返回模擬用戶
      return User.fromMap(kMockUserData);
    }
  }
  
  // 保存用戶資料
  static Future<void> saveUser(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, jsonEncode(user.toMap()));
    } catch (e) {
      throw Exception('保存用戶資料失敗: ${e.toString()}');
    }
  }
  
  // 更新用戶資料
  static Future<void> updateUser(User user) async {
    await saveUser(user);
  }
  
  // 清除所有數據
  static Future<void> clearAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_postsKey);
      await prefs.remove(_userKey);
    } catch (e) {
      throw Exception('清除數據失敗: ${e.toString()}');
    }
  }
  
  // 私有方法：從本地存儲獲取文章
  static Future<List<Post>> _getLocalPosts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final postsJson = prefs.getString(_postsKey);
      
      if (postsJson != null) {
        final List<dynamic> postsList = jsonDecode(postsJson);
        return postsList.map((postData) => Post.fromMap(postData)).toList();
      }
      
      return [];
    } catch (e) {
      return [];
    }
  }
  
  // 獲取用戶統計數據
  static Future<Map<String, int>> getUserStats() async {
    final user = await getCurrentUser();
    if (user == null) {
      return {
        'posts': 0,
        'followers': 0,
        'following': 0,
        'collections': 0,
      };
    }
    
    return {
      'posts': user.posts,
      'followers': user.friends, // 假設 friends 代表關注者
      'following': user.follows,
      'collections': user.collections,
    };
  }
  
  // 獲取用戶發布的文章
  static Future<List<Post>> getUserPosts(String userId) async {
    final allPosts = await getAllPosts();
    return allPosts.where((post) => post.username == userId).toList();
  }
  
  // 獲取用戶收藏的文章
  static Future<List<Post>> getUserCollections(String userId) async {
    // 這裡可以實現收藏功能
    // 暫時返回空列表
    return [];
  }
}

